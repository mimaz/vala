/* polkit-gobject-1.vapi generated by vapigen, do not modify. */

[CCode (cprefix = "Polkit", gir_namespace = "Polkit", gir_version = "1.0", lower_case_cprefix = "polkit_")]
namespace Polkit {
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_action_description_get_type ()")]
	public class ActionDescription : GLib.Object {
		[CCode (has_construct_function = false)]
		protected ActionDescription ();
		public unowned string get_action_id ();
		public unowned string? get_annotation (string key);
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[] get_annotation_keys ();
		public unowned string get_description ();
		public unowned string get_icon_name ();
		public Polkit.ImplicitAuthorization get_implicit_active ();
		public Polkit.ImplicitAuthorization get_implicit_any ();
		public Polkit.ImplicitAuthorization get_implicit_inactive ();
		public unowned string get_message ();
		public unowned string get_vendor_name ();
		public unowned string get_vendor_url ();
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_authority_get_type ()")]
	public class Authority : GLib.Object, GLib.AsyncInitable, GLib.Initable {
		[CCode (has_construct_function = false)]
		protected Authority ();
		public async bool authentication_agent_response (string cookie, Polkit.Identity identity, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public bool authentication_agent_response_sync (string cookie, Polkit.Identity identity, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public async Polkit.AuthorizationResult check_authorization (Polkit.Subject subject, string action_id, Polkit.Details? details, Polkit.CheckAuthorizationFlags flags, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public Polkit.AuthorizationResult check_authorization_sync (Polkit.Subject subject, string action_id, Polkit.Details? details, Polkit.CheckAuthorizationFlags flags, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public async GLib.List<Polkit.ActionDescription> enumerate_actions (GLib.Cancellable? cancellable = null) throws GLib.Error;
		public GLib.List<Polkit.ActionDescription> enumerate_actions_sync (GLib.Cancellable? cancellable = null) throws GLib.Error;
		public async GLib.List<Polkit.TemporaryAuthorization> enumerate_temporary_authorizations (Polkit.Subject subject, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public GLib.List<Polkit.TemporaryAuthorization> enumerate_temporary_authorizations_sync (Polkit.Subject subject, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public static Polkit.Authority @get ();
		public static async Polkit.Authority get_async (GLib.Cancellable? cancellable = null) throws GLib.Error;
		public Polkit.AuthorityFeatures get_backend_features ();
		public unowned string get_backend_name ();
		public unowned string get_backend_version ();
		public string? get_owner ();
		public static Polkit.Authority get_sync (GLib.Cancellable? cancellable = null) throws GLib.Error;
		public async bool register_authentication_agent (Polkit.Subject subject, string locale, string object_path, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public bool register_authentication_agent_sync (Polkit.Subject subject, string locale, string object_path, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public async bool register_authentication_agent_with_options (Polkit.Subject subject, string locale, string object_path, GLib.Variant? options, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public bool register_authentication_agent_with_options_sync (Polkit.Subject subject, string locale, string object_path, GLib.Variant? options, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public async bool revoke_temporary_authorization_by_id (string id, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public bool revoke_temporary_authorization_by_id_sync (string id, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public async bool revoke_temporary_authorizations (Polkit.Subject subject, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public bool revoke_temporary_authorizations_sync (Polkit.Subject subject, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public async bool unregister_authentication_agent (Polkit.Subject subject, string object_path, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public bool unregister_authentication_agent_sync (Polkit.Subject subject, string object_path, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public Polkit.AuthorityFeatures backend_features { get; }
		public string backend_name { get; }
		public string backend_version { get; }
		public string owner { owned get; }
		public signal void changed ();
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_authorization_result_get_type ()")]
	public class AuthorizationResult : GLib.Object {
		[CCode (has_construct_function = false)]
		public AuthorizationResult (bool is_authorized, bool is_challenge, Polkit.Details? details);
		public unowned Polkit.Details? get_details ();
		[Version (since = "0.101")]
		public bool get_dismissed ();
		public bool get_is_authorized ();
		public bool get_is_challenge ();
		public bool get_retains_authorization ();
		public unowned string? get_temporary_authorization_id ();
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_details_get_type ()")]
	public class Details : GLib.Object {
		[CCode (has_construct_function = false)]
		public Details ();
		[CCode (array_length = false, array_null_terminated = true)]
		public string[]? get_keys ();
		public void insert (string key, string? value);
		public unowned string? lookup (string key);
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_permission_get_type ()")]
	public class Permission : GLib.Permission, GLib.AsyncInitable, GLib.Initable {
		[CCode (cname = "polkit_permission_new", has_construct_function = false)]
		public async Permission (string action_id, Polkit.Subject? subject, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public unowned string get_action_id ();
		public unowned Polkit.Subject get_subject ();
		[CCode (has_construct_function = false, type = "GPermission*")]
		public Permission.sync (string action_id, Polkit.Subject? subject, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public string action_id { get; construct; }
		public Polkit.Subject subject { get; construct; }
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_system_bus_name_get_type ()")]
	public class SystemBusName : GLib.Object, Polkit.Subject {
		[CCode (has_construct_function = false, type = "PolkitSubject*")]
		public SystemBusName (string name);
		public unowned string get_name ();
		public Polkit.Subject? get_process_sync (GLib.Cancellable? cancellable = null) throws GLib.Error;
		public Polkit.UnixUser? get_user_sync (GLib.Cancellable? cancellable = null) throws GLib.Error;
		public void set_name (string name);
		public string name { get; set construct; }
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_temporary_authorization_get_type ()")]
	public class TemporaryAuthorization : GLib.Object {
		[CCode (has_construct_function = false)]
		protected TemporaryAuthorization ();
		public unowned string get_action_id ();
		public unowned string get_id ();
		public Polkit.Subject get_subject ();
		public uint64 get_time_expires ();
		public uint64 get_time_obtained ();
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_unix_group_get_type ()")]
	public class UnixGroup : GLib.Object, Polkit.Identity {
		[CCode (has_construct_function = false, type = "PolkitIdentity*")]
		public UnixGroup (int gid);
		[CCode (has_construct_function = false, type = "PolkitIdentity*")]
		public UnixGroup.for_name (string name) throws GLib.Error;
		public int get_gid ();
		public void set_gid (int gid);
		public int gid { get; set construct; }
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_unix_netgroup_get_type ()")]
	public class UnixNetgroup : GLib.Object, Polkit.Identity {
		[CCode (has_construct_function = false, type = "PolkitIdentity*")]
		public UnixNetgroup (string name);
		public unowned string get_name ();
		public void set_name (string name);
		public string name { get; set construct; }
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_unix_process_get_type ()")]
	public class UnixProcess : GLib.Object, Polkit.Subject {
		[CCode (has_construct_function = false, type = "PolkitSubject*")]
		public UnixProcess (int pid);
		[CCode (has_construct_function = false, type = "PolkitSubject*")]
		public UnixProcess.for_owner (int pid, uint64 start_time, int uid);
		[CCode (has_construct_function = false, type = "PolkitSubject*")]
		public UnixProcess.full (int pid, uint64 start_time);
		public int get_owner () throws GLib.Error;
		public int get_pid ();
		public uint64 get_start_time ();
		public int get_uid ();
		public void set_pid (int pid);
		public void set_start_time (uint64 start_time);
		public void set_uid (int uid);
		public int pid { get; set construct; }
		public uint64 start_time { get; set construct; }
		public int uid { get; set construct; }
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_unix_session_get_type ()")]
	public class UnixSession : GLib.Object, GLib.AsyncInitable, GLib.Initable, Polkit.Subject {
		[CCode (has_construct_function = false, type = "PolkitSubject*")]
		public UnixSession (string session_id);
		[CCode (has_construct_function = false, type = "void")]
		public async UnixSession.for_process (int pid, GLib.Cancellable? cancellable = null) throws GLib.Error;
		[CCode (has_construct_function = false, type = "PolkitSubject*")]
		public UnixSession.for_process_sync (int pid, GLib.Cancellable? cancellable = null) throws GLib.Error;
		public unowned string get_session_id ();
		public void set_session_id (string session_id);
		[NoAccessorMethod]
		public int pid { construct; }
		public string session_id { get; set construct; }
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_unix_user_get_type ()")]
	public class UnixUser : GLib.Object, Polkit.Identity {
		[CCode (has_construct_function = false, type = "PolkitIdentity*")]
		public UnixUser (int uid);
		[CCode (has_construct_function = false, type = "PolkitIdentity*")]
		public UnixUser.for_name (string name) throws GLib.Error;
		public unowned string? get_name ();
		public int get_uid ();
		public void set_uid (int uid);
		public int uid { get; set construct; }
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_identity_get_type ()")]
	public interface Identity : GLib.Object {
		public abstract bool equal (Polkit.Identity b);
		public static Polkit.Identity? from_string (string str) throws GLib.Error;
		public abstract uint hash ();
		public abstract string to_string ();
	}
	[CCode (cheader_filename = "polkit/polkit.h", type_id = "polkit_subject_get_type ()")]
	public interface Subject : GLib.Object {
		public abstract bool equal (Polkit.Subject b);
		public abstract async bool exists (GLib.Cancellable? cancellable = null) throws GLib.Error;
		public abstract bool exists_sync (GLib.Cancellable? cancellable = null) throws GLib.Error;
		public static Polkit.Subject from_string (string str) throws GLib.Error;
		public abstract uint hash ();
		public abstract string to_string ();
	}
	[CCode (cheader_filename = "polkit/polkit.h", cprefix = "POLKIT_AUTHORITY_FEATURES_", type_id = "polkit_authority_features_get_type ()")]
	[Flags]
	public enum AuthorityFeatures {
		NONE,
		TEMPORARY_AUTHORIZATION
	}
	[CCode (cheader_filename = "polkit/polkit.h", cprefix = "POLKIT_CHECK_AUTHORIZATION_FLAGS_", type_id = "polkit_check_authorization_flags_get_type ()")]
	[Flags]
	public enum CheckAuthorizationFlags {
		NONE,
		ALLOW_USER_INTERACTION
	}
	[CCode (cheader_filename = "polkit/polkit.h", cprefix = "POLKIT_IMPLICIT_AUTHORIZATION_", type_id = "polkit_implicit_authorization_get_type ()")]
	public enum ImplicitAuthorization {
		UNKNOWN,
		NOT_AUTHORIZED,
		AUTHENTICATION_REQUIRED,
		ADMINISTRATOR_AUTHENTICATION_REQUIRED,
		AUTHENTICATION_REQUIRED_RETAINED,
		ADMINISTRATOR_AUTHENTICATION_REQUIRED_RETAINED,
		AUTHORIZED;
		public static bool from_string (string string, Polkit.ImplicitAuthorization out_implicit_authorization);
		public static unowned string to_string (Polkit.ImplicitAuthorization implicit_authorization);
	}
	[CCode (cheader_filename = "polkit/polkit.h", cprefix = "POLKIT_ERROR_")]
	public errordomain Error {
		FAILED,
		CANCELLED,
		NOT_SUPPORTED,
		NOT_AUTHORIZED;
		public static GLib.Quark quark ();
	}
	[CCode (cheader_filename = "polkit/polkit.h")]
	public static Polkit.Identity? identity_from_string (string str) throws GLib.Error;
	[CCode (cheader_filename = "polkit/polkit.h")]
	public static Polkit.Subject subject_from_string (string str) throws GLib.Error;
}
