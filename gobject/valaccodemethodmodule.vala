/* valaccodemethodmodule.vala
 *
 * Copyright (C) 2007-2008  Jürg Billeter
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jürg Billeter <j@bitron.ch>
 *	Raffaele Sandrini <raffaele@sandrini.ch>
 */

using GLib;
using Gee;

/**
 * The link between a method and generated code.
 */
public class Vala.CCodeMethodModule : CCodeStructModule {
	public CCodeMethodModule (CCodeGenerator codegen, CCodeModule? next) {
		base (codegen, next);
	}

	public override bool method_has_wrapper (Method method) {
		return (method.get_attribute ("NoWrapper") == null);
	}

	public override string? get_custom_creturn_type (Method m) {
		if (m.coroutine) {
			return "gboolean";
		}

		var attr = m.get_attribute ("CCode");
		if (attr != null) {
			string type = attr.get_string ("type");
			if (type != null) {
				return type;
			}
		}
		return null;
	}

	string get_creturn_type (Method m, string default_value) {
		string type = get_custom_creturn_type (m);
		if (type == null) {
			return default_value;
		}
		return type;
	}

	public override void visit_method (Method m) {
		Method old_method = current_method;
		DataType old_return_type = current_return_type;
		bool old_method_inner_error = current_method_inner_error;
		int old_next_temp_var_id = next_temp_var_id;
		current_symbol = m;
		current_method = m;
		current_return_type = m.return_type;
		current_method_inner_error = false;
		next_temp_var_id = 0;

		bool in_gtypeinstance_creation_method = false;
		bool in_gobject_creation_method = false;
		bool in_fundamental_creation_method = false;

		var creturn_type = current_return_type;

		if (m is CreationMethod) {
			in_creation_method = true;
			var cl = current_type_symbol as Class;
			if (cl != null && !cl.is_compact) {
				in_gtypeinstance_creation_method = true;
				if (cl.base_class == null) {
					in_fundamental_creation_method = true;
				} else if (cl.is_subtype_of (gobject_type)) {
					in_gobject_creation_method = true;
				}
			}

			if (cl != null) {
				creturn_type = new ObjectType (cl);
			}
		}

		m.accept_children (codegen);

		if (m is CreationMethod) {
			if (in_gobject_creation_method && m.body != null) {
				var cblock = new CCodeBlock ();

				if (!((CreationMethod) m).chain_up) {
					// set construct properties
					foreach (CodeNode stmt in m.body.get_statements ()) {
						var expr_stmt = stmt as ExpressionStatement;
						if (expr_stmt != null) {
							var prop = expr_stmt.assigned_property ();
							if (prop != null && prop.set_accessor.construction) {
								if (stmt.ccodenode is CCodeFragment) {
									foreach (CCodeNode cstmt in ((CCodeFragment) stmt.ccodenode).get_children ()) {
										cblock.add_statement (cstmt);
									}
								} else {
									cblock.add_statement (stmt.ccodenode);
								}
							}
						}
					}

					add_object_creation (cblock, ((CreationMethod) m).n_construction_params > 0 || current_class.get_type_parameters ().size > 0);
				} else {
					var cdeclaration = new CCodeDeclaration ("%s *".printf (((Class) current_type_symbol).get_cname ()));
					cdeclaration.add_declarator (new CCodeVariableDeclarator ("self"));
		
					cblock.add_statement (cdeclaration);
				}

				// other initialization code
				foreach (CodeNode stmt in m.body.get_statements ()) {
					var expr_stmt = stmt as ExpressionStatement;
					if (expr_stmt != null) {
						var prop = expr_stmt.assigned_property ();
						if (prop != null && prop.set_accessor.construction) {
							continue;
						}
					}
					if (stmt.ccodenode is CCodeFragment) {
						foreach (CCodeNode cstmt in ((CCodeFragment) stmt.ccodenode).get_children ()) {
							cblock.add_statement (cstmt);
						}
					} else {
						cblock.add_statement (stmt.ccodenode);
					}
				}
				
				m.body.ccodenode = cblock;
			}

			in_creation_method = false;
		}

		bool inner_error = current_method_inner_error;

		current_symbol = current_symbol.parent_symbol;
		current_method = old_method;
		current_return_type = old_return_type;
		current_method_inner_error = old_method_inner_error;
		next_temp_var_id = old_next_temp_var_id;

		function = new CCodeFunction (m.get_real_cname (), get_creturn_type (m, creturn_type.get_cname ()));
		m.ccodenode = function;

		if (m.is_inline) {
			function.modifiers |= CCodeModifiers.INLINE;
		}

		var cparam_map = new HashMap<int,CCodeFormalParameter> (direct_hash, direct_equal);

		CCodeFunctionDeclarator vdeclarator = null;

		if (m.parent_symbol is Class && m is CreationMethod) {
			var cl = (Class) m.parent_symbol;
			if (!cl.is_compact) {
				cparam_map.set (get_param_pos (m.cinstance_parameter_position), new CCodeFormalParameter ("object_type", "GType"));
			}
		} else if (m.binding == MemberBinding.INSTANCE || (m.parent_symbol is Struct && m is CreationMethod)) {
			TypeSymbol parent_type = find_parent_type (m);
			DataType this_type;
			if (parent_type is Class) {
				this_type = new ObjectType ((Class) parent_type);
			} else if (parent_type is Interface) {
				this_type = new ObjectType ((Interface) parent_type);
			} else {
				this_type = new ValueType (parent_type);
			}

			CCodeFormalParameter instance_param = null;
			if (m.base_interface_method != null && !m.is_abstract && !m.is_virtual) {
				var base_type = new ObjectType ((Interface) m.base_interface_method.parent_symbol);
				instance_param = new CCodeFormalParameter ("base", base_type.get_cname ());
			} else if (m.overrides) {
				var base_type = new ObjectType ((Class) m.base_method.parent_symbol);
				instance_param = new CCodeFormalParameter ("base", base_type.get_cname ());
			} else {
				if (m.parent_symbol is Struct && !((Struct) m.parent_symbol).is_simple_type ()) {
					instance_param = new CCodeFormalParameter ("*self", this_type.get_cname ());
				} else {
					instance_param = new CCodeFormalParameter ("self", this_type.get_cname ());
				}
			}
			cparam_map.set (get_param_pos (m.cinstance_parameter_position), instance_param);

			if (m.is_abstract || m.is_virtual) {
				var vdecl = new CCodeDeclaration (get_creturn_type (m, creturn_type.get_cname ()));
				vdeclarator = new CCodeFunctionDeclarator (m.vfunc_name);
				vdecl.add_declarator (vdeclarator);
				type_struct.add_declaration (vdecl);
			}
		} else if (m.binding == MemberBinding.CLASS) {
			TypeSymbol parent_type = find_parent_type (m);
			DataType this_type;
			this_type = new ClassType ((Class) parent_type);
			var class_param = new CCodeFormalParameter ("klass", this_type.get_cname ());
			cparam_map.set (get_param_pos (m.cinstance_parameter_position), class_param);
		}

		if (!m.coroutine) {
			generate_cparameters (m, creturn_type, in_gtypeinstance_creation_method, cparam_map, function, vdeclarator);
		} else {
			// data struct to hold parameters, local variables, and the return value
			cparam_map.set (get_param_pos (0), new CCodeFormalParameter ("data", Symbol.lower_case_to_camel_case (m.get_cname ()) + "Data*"));

			generate_cparameters (m, creturn_type, in_gtypeinstance_creation_method, cparam_map, function, vdeclarator, null, null, 0);
		}

		bool visible = !m.is_internal_symbol ();

		// generate *_real_* functions for virtual methods
		// also generate them for abstract methods of classes to prevent faulty subclassing
		if (!m.is_abstract || (m.is_abstract && current_type_symbol is Class)) {
			if (visible && m.base_method == null && m.base_interface_method == null) {
				/* public methods need function declaration in
				 * header file except virtual/overridden methods */
				header_type_member_declaration.append (function.copy ());
			} else {
				/* declare all other functions in source file to
				 * avoid dependency on order within source file */
				function.modifiers |= CCodeModifiers.STATIC;
				source_type_member_declaration.append (function.copy ());
			}
		
			/* Methods imported from a plain C file don't
			 * have a body, e.g. Vala.Parser.parse_file () */
			if (m.body != null) {
				function.block = (CCodeBlock) m.body.ccodenode;
				function.block.line = function.line;

				var cinit = new CCodeFragment ();
				function.block.prepend_statement (cinit);

				if (m.coroutine) {
					var cswitch = new CCodeSwitchStatement (new CCodeMemberAccess.pointer (new CCodeIdentifier ("data"), "state"));

					// initial coroutine state
					cswitch.add_statement (new CCodeCaseStatement (new CCodeConstant ("0")));

					// coroutine body
					cswitch.add_statement (function.block);

					// complete async call by invoking callback
					var object_creation = new CCodeFunctionCall (new CCodeIdentifier ("g_object_newv"));
					object_creation.add_argument (new CCodeConstant ("G_TYPE_OBJECT"));
					object_creation.add_argument (new CCodeConstant ("0"));
					object_creation.add_argument (new CCodeConstant ("NULL"));

					var async_result_creation = new CCodeFunctionCall (new CCodeIdentifier ("g_simple_async_result_new"));
					async_result_creation.add_argument (object_creation);
					async_result_creation.add_argument (new CCodeMemberAccess.pointer (new CCodeIdentifier ("data"), "callback"));
					async_result_creation.add_argument (new CCodeMemberAccess.pointer (new CCodeIdentifier ("data"), "user_data"));
					async_result_creation.add_argument (new CCodeIdentifier ("data"));

					var completecall = new CCodeFunctionCall (new CCodeIdentifier ("g_simple_async_result_complete"));
					completecall.add_argument (async_result_creation);
					cswitch.add_statement (new CCodeExpressionStatement (completecall));

					cswitch.add_statement (new CCodeReturnStatement (new CCodeConstant ("FALSE")));

					function.block = new CCodeBlock ();
					function.block.add_statement (cswitch);
				}

				if (m.parent_symbol is Class) {
					var cl = (Class) m.parent_symbol;
					if (m.overrides || (m.base_interface_method != null && !m.is_abstract && !m.is_virtual)) {
						Method base_method;
						ReferenceType base_expression_type;
						if (m.overrides) {
							base_method = m.base_method;
							base_expression_type = new ObjectType ((Class) base_method.parent_symbol);
						} else {
							base_method = m.base_interface_method;
							base_expression_type = new ObjectType ((Interface) base_method.parent_symbol);
						}
						var self_target_type = new ObjectType (cl);
						CCodeExpression cself = transform_expression (new CCodeIdentifier ("base"), base_expression_type, self_target_type);

						var cdecl = new CCodeDeclaration ("%s *".printf (cl.get_cname ()));
						cdecl.add_declarator (new CCodeVariableDeclarator.with_initializer ("self", cself));
					
						cinit.append (cdecl);
					} else if (m.binding == MemberBinding.INSTANCE
					           && !(m is CreationMethod)) {
						var ccheckstmt = create_method_type_check_statement (m, creturn_type, cl, true, "self");
						ccheckstmt.line = function.line;
						cinit.append (ccheckstmt);
					}
				}
				foreach (FormalParameter param in m.get_parameters ()) {
					if (param.ellipsis) {
						break;
					}

					var t = param.parameter_type.data_type;
					if (t != null && t.is_reference_type ()) {
						if (param.direction != ParameterDirection.OUT) {
							var type_check = create_method_type_check_statement (m, creturn_type, t, (context.non_null && !param.parameter_type.nullable), param.name);
							if (type_check != null) {
								type_check.line = function.line;
								cinit.append (type_check);
							}
						} else {
							// ensure that the passed reference for output parameter is cleared
							var a = new CCodeAssignment (new CCodeUnaryExpression (CCodeUnaryOperator.POINTER_INDIRECTION, new CCodeIdentifier (param.name)), new CCodeConstant ("NULL"));
							cinit.append (new CCodeExpressionStatement (a));
						}
					}
				}

				if (inner_error) {
					/* always separate error parameter and inner_error local variable
					 * as error may be set to NULL but we're always interested in inner errors
					 */
					var cdecl = new CCodeDeclaration ("GError *");
					cdecl.add_declarator (new CCodeVariableDeclarator.with_initializer ("inner_error", new CCodeConstant ("NULL")));
					cinit.append (cdecl);
				}

				if (m.source_reference != null && m.source_reference.comment != null) {
					source_type_member_definition.append (new CCodeComment (m.source_reference.comment));
				}
				source_type_member_definition.append (function);
			
				if (m is CreationMethod) {
					if (in_gobject_creation_method) {
						int n_params = ((CreationMethod) m).n_construction_params;

						if (n_params > 0 || current_class.get_type_parameters ().size > 0) {
							// declare construction parameter array
							var cparamsinit = new CCodeFunctionCall (new CCodeIdentifier ("g_new0"));
							cparamsinit.add_argument (new CCodeIdentifier ("GParameter"));
							cparamsinit.add_argument (new CCodeConstant ((n_params + 3 * current_class.get_type_parameters ().size).to_string ()));
						
							var cdecl = new CCodeDeclaration ("GParameter *");
							cdecl.add_declarator (new CCodeVariableDeclarator.with_initializer ("__params", cparamsinit));
							cinit.append (cdecl);
						
							cdecl = new CCodeDeclaration ("GParameter *");
							cdecl.add_declarator (new CCodeVariableDeclarator.with_initializer ("__params_it", new CCodeIdentifier ("__params")));
							cinit.append (cdecl);
						}

						/* type, dup func, and destroy func properties for generic types */
						foreach (TypeParameter type_param in current_class.get_type_parameters ()) {
							CCodeConstant prop_name;
							CCodeIdentifier param_name;

							prop_name = new CCodeConstant ("\"%s-type\"".printf (type_param.name.down ()));
							param_name = new CCodeIdentifier ("%s_type".printf (type_param.name.down ()));
							cinit.append (new CCodeExpressionStatement (get_construct_property_assignment (prop_name, new ValueType (gtype_type), param_name)));

							prop_name = new CCodeConstant ("\"%s-dup-func\"".printf (type_param.name.down ()));
							param_name = new CCodeIdentifier ("%s_dup_func".printf (type_param.name.down ()));
							cinit.append (new CCodeExpressionStatement (get_construct_property_assignment (prop_name, new PointerType (new VoidType ()), param_name)));

							prop_name = new CCodeConstant ("\"%s-destroy-func\"".printf (type_param.name.down ()));
							param_name = new CCodeIdentifier ("%s_destroy_func".printf (type_param.name.down ()));
							cinit.append (new CCodeExpressionStatement (get_construct_property_assignment (prop_name, new PointerType (new VoidType ()), param_name)));
						}
					} else if (in_gtypeinstance_creation_method) {
						var cl = (Class) m.parent_symbol;
						var cdeclaration = new CCodeDeclaration (cl.get_cname () + "*");
						var cdecl = new CCodeVariableDeclarator ("self");
						cdeclaration.add_declarator (cdecl);
						cinit.append (cdeclaration);

						if (!((CreationMethod) m).chain_up) {
							// TODO implicitly chain up to base class as in add_object_creation
							var ccall = new CCodeFunctionCall (new CCodeIdentifier ("g_type_create_instance"));
							ccall.add_argument (new CCodeIdentifier ("object_type"));
							cdecl.initializer = new CCodeCastExpression (ccall, cl.get_cname () + "*");
						}

						/* type, dup func, and destroy func fields for generic types */
						foreach (TypeParameter type_param in current_class.get_type_parameters ()) {
							CCodeIdentifier param_name;
							CCodeAssignment assign;

							var priv_access = new CCodeMemberAccess.pointer (new CCodeIdentifier ("self"), "priv");

							param_name = new CCodeIdentifier ("%s_type".printf (type_param.name.down ()));
							assign = new CCodeAssignment (new CCodeMemberAccess.pointer (priv_access, param_name.name), param_name);
							cinit.append (new CCodeExpressionStatement (assign));

							param_name = new CCodeIdentifier ("%s_dup_func".printf (type_param.name.down ()));
							assign = new CCodeAssignment (new CCodeMemberAccess.pointer (priv_access, param_name.name), param_name);
							cinit.append (new CCodeExpressionStatement (assign));

							param_name = new CCodeIdentifier ("%s_destroy_func".printf (type_param.name.down ()));
							assign = new CCodeAssignment (new CCodeMemberAccess.pointer (priv_access, param_name.name), param_name);
							cinit.append (new CCodeExpressionStatement (assign));
						}
					} else if (current_type_symbol is Class) {
						var cl = (Class) m.parent_symbol;
						var cdecl = new CCodeDeclaration (cl.get_cname () + "*");
						var ccall = new CCodeFunctionCall (new CCodeIdentifier ("g_slice_new0"));
						ccall.add_argument (new CCodeIdentifier (cl.get_cname ()));
						cdecl.add_declarator (new CCodeVariableDeclarator.with_initializer ("self", ccall));
						cinit.append (cdecl);

						var cinitcall = new CCodeFunctionCall (new CCodeIdentifier ("%s_instance_init".printf (cl.get_lower_case_cname (null))));
						cinitcall.add_argument (new CCodeIdentifier ("self"));
						cinit.append (new CCodeExpressionStatement (cinitcall));
					} else {
						var st = (Struct) m.parent_symbol;

						// memset needs string.h
						string_h_needed = true;
						var czero = new CCodeFunctionCall (new CCodeIdentifier ("memset"));
						czero.add_argument (new CCodeIdentifier ("self"));
						czero.add_argument (new CCodeConstant ("0"));
						czero.add_argument (new CCodeIdentifier ("sizeof (%s)".printf (st.get_cname ())));
						cinit.append (new CCodeExpressionStatement (czero));
					}
				}

				if (context.module_init_method == m && in_plugin) {
					// GTypeModule-based plug-in, register types
					cinit.append (module_init_fragment);
				}

				foreach (Expression precondition in m.get_preconditions ()) {
					cinit.append (create_precondition_statement (m, creturn_type, precondition));
				}
			} else if (m.is_abstract) {
				// generate helpful error message if a sublcass does not implement an abstract method.
				// This is only meaningful for subclasses implemented in C since the vala compiler would
				// complain during compile time of such en error.

				var cblock = new CCodeBlock ();

				// add a typecheck statement for "self"
				cblock.add_statement (create_method_type_check_statement (m, creturn_type, current_type_symbol, true, "self"));

				// add critical warning that this method should not have been called
				var type_from_instance_call = new CCodeFunctionCall (new CCodeIdentifier ("G_TYPE_FROM_INSTANCE"));
				type_from_instance_call.add_argument (new CCodeIdentifier ("self"));
			
				var type_name_call = new CCodeFunctionCall (new CCodeIdentifier ("g_type_name"));
				type_name_call.add_argument (type_from_instance_call);

				var error_string = "\"Type `%%s' does not implement abstract method `%s'\"".printf (m.get_cname ());

				var cerrorcall = new CCodeFunctionCall (new CCodeIdentifier ("g_critical"));
				cerrorcall.add_argument (new CCodeConstant (error_string));
				cerrorcall.add_argument (type_name_call);

				cblock.add_statement (new CCodeExpressionStatement (cerrorcall));

				// add return statement
				cblock.add_statement (new CCodeReturnStatement (default_value_for_type (creturn_type, false)));

				function.block = cblock;
				source_type_member_definition.append (function);
			}
		}

		if (m.is_abstract || m.is_virtual) {
			var vfunc = new CCodeFunction (m.get_cname (), creturn_type.get_cname ());
			vfunc.line = function.line;

			ReferenceType this_type;
			if (m.parent_symbol is Class) {
				this_type = new ObjectType ((Class) m.parent_symbol);
			} else {
				this_type = new ObjectType ((Interface) m.parent_symbol);
			}

			cparam_map = new HashMap<int,CCodeFormalParameter> (direct_hash, direct_equal);
			var carg_map = new HashMap<int,CCodeExpression> (direct_hash, direct_equal);

			var cparam = new CCodeFormalParameter ("self", this_type.get_cname ());
			cparam_map.set (get_param_pos (m.cinstance_parameter_position), cparam);
			
			var vblock = new CCodeBlock ();

			foreach (Expression precondition in m.get_preconditions ()) {
				vblock.add_statement (create_precondition_statement (m, creturn_type, precondition));
			}

			CCodeFunctionCall vcast = null;
			if (m.parent_symbol is Interface) {
				var iface = (Interface) m.parent_symbol;

				vcast = new CCodeFunctionCall (new CCodeIdentifier ("%s_GET_INTERFACE".printf (iface.get_upper_case_cname (null))));
			} else {
				var cl = (Class) m.parent_symbol;

				vcast = new CCodeFunctionCall (new CCodeIdentifier ("%s_GET_CLASS".printf (cl.get_upper_case_cname (null))));
			}
			vcast.add_argument (new CCodeIdentifier ("self"));
		
			var vcall = new CCodeFunctionCall (new CCodeMemberAccess.pointer (vcast, m.vfunc_name));
			carg_map.set (get_param_pos (m.cinstance_parameter_position), new CCodeIdentifier ("self"));

			generate_cparameters (m, creturn_type, in_gtypeinstance_creation_method, cparam_map, vfunc, null, carg_map, vcall);

			CCodeStatement cstmt;
			if (creturn_type is VoidType) {
				cstmt = new CCodeExpressionStatement (vcall);
			} else if (m.get_postconditions ().size == 0) {
				/* pass method return value */
				cstmt = new CCodeReturnStatement (vcall);
			} else {
				/* store method return value for postconditions */
				var cdecl = new CCodeDeclaration (get_creturn_type (m, creturn_type.get_cname ()));
				cdecl.add_declarator (new CCodeVariableDeclarator.with_initializer ("result", vcall));
				cstmt = cdecl;
			}
			cstmt.line = vfunc.line;
			vblock.add_statement (cstmt);

			if (m.get_postconditions ().size > 0) {
				foreach (Expression postcondition in m.get_postconditions ()) {
					vblock.add_statement (create_postcondition_statement (postcondition));
				}

				if (!(creturn_type is VoidType)) {
					var cret_stmt = new CCodeReturnStatement (new CCodeIdentifier ("result"));
					cret_stmt.line = vfunc.line;
					vblock.add_statement (cret_stmt);
				}
			}

			if (visible) {
				header_type_member_declaration.append (vfunc.copy ());
			} else {
				vfunc.modifiers |= CCodeModifiers.STATIC;
				source_type_member_declaration.append (vfunc.copy ());
			}
			
			vfunc.block = vblock;

			if (m.is_abstract && m.source_reference != null && m.source_reference.comment != null) {
				source_type_member_definition.append (new CCodeComment (m.source_reference.comment));
			}
			source_type_member_definition.append (vfunc);
		}

		if (m is CreationMethod) {
			if (current_class != null && !current_class.is_compact) {
				var vfunc = new CCodeFunction (m.get_cname (), creturn_type.get_cname ());
				vfunc.line = function.line;

				cparam_map = new HashMap<int,CCodeFormalParameter> (direct_hash, direct_equal);
				var carg_map = new HashMap<int,CCodeExpression> (direct_hash, direct_equal);

				var vblock = new CCodeBlock ();

				var vcall = new CCodeFunctionCall (new CCodeIdentifier (m.get_real_cname ()));
				vcall.add_argument (new CCodeIdentifier (current_class.get_type_id ()));

				generate_cparameters (m, creturn_type, in_gtypeinstance_creation_method, cparam_map, vfunc, null, carg_map, vcall);
				CCodeStatement cstmt = new CCodeReturnStatement (vcall);
				cstmt.line = vfunc.line;
				vblock.add_statement (cstmt);

				if (visible) {
					header_type_member_declaration.append (vfunc.copy ());
				} else {
					vfunc.modifiers |= CCodeModifiers.STATIC;
					source_type_member_declaration.append (vfunc.copy ());
				}
			
				vfunc.block = vblock;

				source_type_member_definition.append (vfunc);
			}

			if (current_class != null && current_class.is_subtype_of (gobject_type)
			    && (((CreationMethod) m).n_construction_params > 0 || current_class.get_type_parameters ().size > 0)) {
				var ccond = new CCodeBinaryExpression (CCodeBinaryOperator.GREATER_THAN, new CCodeIdentifier ("__params_it"), new CCodeIdentifier ("__params"));
				var cdofreeparam = new CCodeBlock ();
				cdofreeparam.add_statement (new CCodeExpressionStatement (new CCodeUnaryExpression (CCodeUnaryOperator.PREFIX_DECREMENT, new CCodeIdentifier ("__params_it"))));
				var cunsetcall = new CCodeFunctionCall (new CCodeIdentifier ("g_value_unset"));
				cunsetcall.add_argument (new CCodeUnaryExpression (CCodeUnaryOperator.ADDRESS_OF, new CCodeMemberAccess.pointer (new CCodeIdentifier ("__params_it"), "value")));
				cdofreeparam.add_statement (new CCodeExpressionStatement (cunsetcall));
				function.block.add_statement (new CCodeWhileStatement (ccond, cdofreeparam));

				var cfreeparams = new CCodeFunctionCall (new CCodeIdentifier ("g_free"));
				cfreeparams.add_argument (new CCodeIdentifier ("__params"));
				function.block.add_statement (new CCodeExpressionStatement (cfreeparams));
			}

			if (current_type_symbol is Class) {
				CCodeExpression cresult = new CCodeIdentifier ("self");
				if (get_custom_creturn_type (m) != null) {
					cresult = new CCodeCastExpression (cresult, get_custom_creturn_type (m));
				}

				var creturn = new CCodeReturnStatement ();
				creturn.return_expression = cresult;
				function.block.add_statement (creturn);
			}
		}
		
		if (m.entry_point) {
			// m is possible entry point, add appropriate startup code
			var cmain = new CCodeFunction ("main", "int");
			cmain.line = function.line;
			cmain.add_parameter (new CCodeFormalParameter ("argc", "int"));
			cmain.add_parameter (new CCodeFormalParameter ("argv", "char **"));
			var main_block = new CCodeBlock ();

			if (context.thread) {
				var thread_init_call = new CCodeFunctionCall (new CCodeIdentifier ("g_thread_init"));
				thread_init_call.line = cmain.line;
				thread_init_call.add_argument (new CCodeConstant ("NULL"));
				main_block.add_statement (new CCodeExpressionStatement (thread_init_call)); 
			}

			var type_init_call = new CCodeExpressionStatement (new CCodeFunctionCall (new CCodeIdentifier ("g_type_init")));
			type_init_call.line = cmain.line;
			main_block.add_statement (type_init_call);

			var main_call = new CCodeFunctionCall (new CCodeIdentifier (function.name));
			if (m.get_parameters ().size == 1) {
				main_call.add_argument (new CCodeIdentifier ("argv"));
				main_call.add_argument (new CCodeIdentifier ("argc"));
			}
			if (m.return_type is VoidType) {
				// method returns void, always use 0 as exit code
				var main_stmt = new CCodeExpressionStatement (main_call);
				main_stmt.line = cmain.line;
				main_block.add_statement (main_stmt);
				var ret_stmt = new CCodeReturnStatement (new CCodeConstant ("0"));
				ret_stmt.line = cmain.line;
				main_block.add_statement (ret_stmt);
			} else {
				var main_stmt = new CCodeReturnStatement (main_call);
				main_stmt.line = cmain.line;
				main_block.add_statement (main_stmt);
			}
			cmain.block = main_block;
			source_type_member_definition.append (cmain);
		}
	}

	public override void generate_cparameters (Method m, DataType creturn_type, bool in_gtypeinstance_creation_method, Map<int,CCodeFormalParameter> cparam_map, CCodeFunction func, CCodeFunctionDeclarator? vdeclarator = null, Map<int,CCodeExpression>? carg_map = null, CCodeFunctionCall? vcall = null, int direction = 3) {
		if (in_gtypeinstance_creation_method) {
			// memory management for generic types
			int type_param_index = 0;
			foreach (TypeParameter type_param in current_class.get_type_parameters ()) {
				cparam_map.set (get_param_pos (0.1 * type_param_index + 0.01), new CCodeFormalParameter ("%s_type".printf (type_param.name.down ()), "GType"));
				cparam_map.set (get_param_pos (0.1 * type_param_index + 0.02), new CCodeFormalParameter ("%s_dup_func".printf (type_param.name.down ()), "GBoxedCopyFunc"));
				cparam_map.set (get_param_pos (0.1 * type_param_index + 0.03), new CCodeFormalParameter ("%s_destroy_func".printf (type_param.name.down ()), "GDestroyNotify"));
				if (carg_map != null) {
					carg_map.set (get_param_pos (0.1 * type_param_index + 0.01), new CCodeIdentifier ("%s_type".printf (type_param.name.down ())));
					carg_map.set (get_param_pos (0.1 * type_param_index + 0.02), new CCodeIdentifier ("%s_dup_func".printf (type_param.name.down ())));
					carg_map.set (get_param_pos (0.1 * type_param_index + 0.03), new CCodeIdentifier ("%s_destroy_func".printf (type_param.name.down ())));
				}
				type_param_index++;
			}
		}

		foreach (FormalParameter param in m.get_parameters ()) {
			if (param.direction != ParameterDirection.OUT) {
				if ((direction & 1) == 0) {
					// no in paramters
					continue;
				}
			} else {
				if ((direction & 2) == 0) {
					// no out paramters
					continue;
				}
			}

			if (!param.no_array_length && param.parameter_type is ArrayType) {
				var array_type = (ArrayType) param.parameter_type;
				
				var length_ctype = "int";
				if (param.direction != ParameterDirection.IN) {
					length_ctype = "int*";
				}
				
				for (int dim = 1; dim <= array_type.rank; dim++) {
					var cparam = new CCodeFormalParameter (head.get_array_length_cname (param.name, dim), length_ctype);
					cparam_map.set (get_param_pos (param.carray_length_parameter_position + 0.01 * dim), cparam);
					if (carg_map != null) {
						carg_map.set (get_param_pos (param.carray_length_parameter_position + 0.01 * dim), new CCodeIdentifier (cparam.name));
					}
				}
			}

			cparam_map.set (get_param_pos (param.cparameter_position), (CCodeFormalParameter) param.ccodenode);
			if (carg_map != null) {
				carg_map.set (get_param_pos (param.cparameter_position), new CCodeIdentifier (param.name));
			}

			if (param.parameter_type is DelegateType) {
				var deleg_type = (DelegateType) param.parameter_type;
				var d = deleg_type.delegate_symbol;
				if (d.has_target) {
					var cparam = new CCodeFormalParameter (get_delegate_target_cname (param.name), "void*");
					cparam_map.set (get_param_pos (param.cdelegate_target_parameter_position), cparam);
					if (carg_map != null) {
						carg_map.set (get_param_pos (param.cdelegate_target_parameter_position), new CCodeIdentifier (cparam.name));
					}
					if (deleg_type.value_owned) {
						cparam = new CCodeFormalParameter (get_delegate_target_destroy_notify_cname (param.name), "GDestroyNotify");
						cparam_map.set (get_param_pos (param.cdelegate_target_parameter_position + 0.01), cparam);
						if (carg_map != null) {
							carg_map.set (get_param_pos (param.cdelegate_target_parameter_position + 0.01), new CCodeIdentifier (cparam.name));
						}
					}
				}
			} else if (param.parameter_type is MethodType) {
				var cparam = new CCodeFormalParameter (get_delegate_target_cname (param.name), "void*");
				cparam_map.set (get_param_pos (param.cdelegate_target_parameter_position), cparam);
				if (carg_map != null) {
					carg_map.set (get_param_pos (param.cdelegate_target_parameter_position), new CCodeIdentifier (cparam.name));
				}
			}
		}

		if ((direction & 2) != 0) {
			if (!m.no_array_length && creturn_type is ArrayType) {
				// return array length if appropriate
				var array_type = (ArrayType) creturn_type;

				for (int dim = 1; dim <= array_type.rank; dim++) {
					var cparam = new CCodeFormalParameter (head.get_array_length_cname ("result", dim), "int*");
					cparam_map.set (get_param_pos (m.carray_length_parameter_position + 0.01 * dim), cparam);
					if (carg_map != null) {
						carg_map.set (get_param_pos (m.carray_length_parameter_position + 0.01 * dim), new CCodeIdentifier (cparam.name));
					}
				}
			} else if (creturn_type is DelegateType) {
				// return delegate target if appropriate
				var deleg_type = (DelegateType) creturn_type;
				var d = deleg_type.delegate_symbol;
				if (d.has_target) {
					var cparam = new CCodeFormalParameter (get_delegate_target_cname ("result"), "void*");
					cparam_map.set (get_param_pos (m.cdelegate_target_parameter_position), cparam);
					if (carg_map != null) {
						carg_map.set (get_param_pos (m.cdelegate_target_parameter_position), new CCodeIdentifier (cparam.name));
					}
				}
			}

			if (m.get_error_types ().size > 0) {
				var cparam = new CCodeFormalParameter ("error", "GError**");
				cparam_map.set (get_param_pos (-1), cparam);
				if (carg_map != null) {
					carg_map.set (get_param_pos (-1), new CCodeIdentifier (cparam.name));
				}
			}
		}

		// append C parameters in the right order
		int last_pos = -1;
		int min_pos;
		while (true) {
			min_pos = -1;
			foreach (int pos in cparam_map.get_keys ()) {
				if (pos > last_pos && (min_pos == -1 || pos < min_pos)) {
					min_pos = pos;
				}
			}
			if (min_pos == -1) {
				break;
			}
			func.add_parameter (cparam_map.get (min_pos));
			if (vdeclarator != null) {
				vdeclarator.add_parameter (cparam_map.get (min_pos));
			}
			if (vcall != null) {
				vcall.add_argument (carg_map.get (min_pos));
			}
			last_pos = min_pos;
		}
	}

	private CCodeStatement create_method_type_check_statement (Method m, DataType return_type, TypeSymbol t, bool non_null, string var_name) {
		return create_type_check_statement (m, return_type, t, non_null, var_name);
	}

	private CCodeStatement create_precondition_statement (CodeNode method_node, DataType ret_type, Expression precondition) {
		var ccheck = new CCodeFunctionCall ();

		ccheck.add_argument ((CCodeExpression) precondition.ccodenode);

		if (ret_type is VoidType) {
			/* void function */
			ccheck.call = new CCodeIdentifier ("g_return_if_fail");
		} else {
			ccheck.call = new CCodeIdentifier ("g_return_val_if_fail");

			var cdefault = default_value_for_type (ret_type, false);
			if (cdefault != null) {
				ccheck.add_argument (cdefault);
			} else {
				return new CCodeExpressionStatement (new CCodeConstant ("0"));
			}
		}
		
		return new CCodeExpressionStatement (ccheck);
	}

	private CCodeStatement create_postcondition_statement (Expression postcondition) {
		var cassert = new CCodeFunctionCall (new CCodeIdentifier ("g_assert"));

		cassert.add_argument ((CCodeExpression) postcondition.ccodenode);

		return new CCodeExpressionStatement (cassert);
	}

	private TypeSymbol? find_parent_type (Symbol sym) {
		while (sym != null) {
			if (sym is TypeSymbol) {
				return (TypeSymbol) sym;
			}
			sym = sym.parent_symbol;
		}
		return null;
	}

	private void add_object_creation (CCodeBlock b, bool has_params) {
		var cl = (Class) current_type_symbol;

		bool chain_up = false;
		CreationMethod cm = null;
		if (cl.base_class != null) {
			cm = cl.base_class.default_construction_method as CreationMethod;
			if (cm != null && cm.get_parameters ().size == 0
			    && cm.has_construct_function) {
				 if (!has_params) {
					chain_up = true;
				 }
			}
		}

		if (!has_params && !chain_up
		    && cl.base_class != gobject_type) {
			// possibly report warning or error about missing base call
		}

		var cdecl = new CCodeVariableDeclarator ("self");
		if (chain_up) {
			var ccall = new CCodeFunctionCall (new CCodeIdentifier (cm.get_real_cname ()));
			ccall.add_argument (new CCodeIdentifier ("object_type"));
			cdecl.initializer = new CCodeCastExpression (ccall, "%s*".printf (cl.get_cname ()));
		} else {
			var ccall = new CCodeFunctionCall (new CCodeIdentifier ("g_object_newv"));
			ccall.add_argument (new CCodeIdentifier ("object_type"));
			if (has_params) {
				ccall.add_argument (new CCodeConstant ("__params_it - __params"));
				ccall.add_argument (new CCodeConstant ("__params"));
			} else {
				ccall.add_argument (new CCodeConstant ("0"));
				ccall.add_argument (new CCodeConstant ("NULL"));
			}
			cdecl.initializer = ccall;
		}
		
		var cdeclaration = new CCodeDeclaration ("%s *".printf (cl.get_cname ()));
		cdeclaration.add_declarator (cdecl);
		
		b.add_statement (cdeclaration);
	}

	public override void visit_creation_method (CreationMethod m) {
		if (m.body != null && current_type_symbol is Class && current_class.is_subtype_of (gobject_type)) {
			int n_params = 0;
			foreach (Statement stmt in m.body.get_statements ()) {
				var expr_stmt = stmt as ExpressionStatement;
				if (expr_stmt != null) {
					Property prop = expr_stmt.assigned_property ();
					if (prop != null && prop.set_accessor.construction) {
						n_params++;
					}
				}
			}
			m.n_construction_params = n_params;
		}

		head.visit_method (m);
	}
}
