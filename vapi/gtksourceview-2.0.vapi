/* gtksourceview-2.0.vapi generated by vapigen, do not modify. */

[CCode (cprefix = "Gtk", lower_case_cprefix = "gtk_")]
namespace Gtk {
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceBuffer : Gtk.TextBuffer {
		[CCode (has_construct_function = false)]
		public SourceBuffer (Gtk.TextTagTable? table);
		public bool backward_iter_to_source_mark (Gtk.TextIter iter, string category);
		public void begin_not_undoable_action ();
		public unowned Gtk.SourceMark create_source_mark (string name, string category, Gtk.TextIter where);
		public void end_not_undoable_action ();
		public void ensure_highlight (Gtk.TextIter start, Gtk.TextIter end);
		public bool forward_iter_to_source_mark (Gtk.TextIter iter, string category);
		public unowned string get_context_classes_at_iter (Gtk.TextIter iter);
		public bool get_highlight_matching_brackets ();
		public bool get_highlight_syntax ();
		public unowned Gtk.SourceLanguage get_language ();
		public int get_max_undo_levels ();
		public unowned GLib.SList get_source_marks_at_iter (Gtk.TextIter iter, string category);
		public unowned GLib.SList get_source_marks_at_line (int line, string category);
		public unowned Gtk.SourceStyleScheme get_style_scheme ();
		public unowned Gtk.SourceUndoManager get_undo_manager ();
		public bool iter_backward_to_context_class_toggle (Gtk.TextIter iter, string context_class);
		public bool iter_forward_to_context_class_toggle (Gtk.TextIter iter, string context_class);
		public bool iter_has_context_class (Gtk.TextIter iter, string context_class);
		public void remove_source_marks (Gtk.TextIter start, Gtk.TextIter end, string category);
		public void set_highlight_matching_brackets (bool highlight);
		public void set_highlight_syntax (bool highlight);
		public void set_language (Gtk.SourceLanguage language);
		public void set_max_undo_levels (int max_undo_levels);
		public void set_style_scheme (Gtk.SourceStyleScheme scheme);
		public void set_undo_manager (Gtk.SourceUndoManager manager);
		[CCode (has_construct_function = false)]
		public SourceBuffer.with_language (Gtk.SourceLanguage language);
		[NoAccessorMethod]
		public bool can_redo { get; }
		[NoAccessorMethod]
		public bool can_undo { get; }
		public bool highlight_matching_brackets { get; set; }
		public bool highlight_syntax { get; set; }
		public Gtk.SourceLanguage language { get; set; }
		public int max_undo_levels { get; set; }
		public Gtk.SourceStyleScheme style_scheme { get; set; }
		public Gtk.SourceUndoManager undo_manager { get; set construct; }
		public virtual signal void highlight_updated (Gtk.TextIter p0, Gtk.TextIter p1);
		[HasEmitter]
		public virtual signal void redo ();
		public virtual signal void source_mark_updated (Gtk.TextMark p0);
		[HasEmitter]
		public virtual signal void undo ();
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceCompletion : Gtk.Object {
		public bool add_provider (Gtk.SourceCompletionProvider provider) throws GLib.Error;
		public void block_interactive ();
		public unowned Gtk.SourceCompletionContext create_context (Gtk.TextIter? position = null);
		public static GLib.Quark error_quark ();
		public unowned Gtk.SourceCompletionInfo get_info_window ();
		public unowned GLib.List get_providers ();
		public void* get_view ();
		public void move_window (Gtk.TextIter iter);
		[NoWrapper]
		public virtual bool proposal_activated (Gtk.SourceCompletionProvider provider, Gtk.SourceCompletionProposal proposal);
		public bool remove_provider (Gtk.SourceCompletionProvider provider) throws GLib.Error;
		public void unblock_interactive ();
		[NoAccessorMethod]
		public uint accelerators { get; set construct; }
		[NoAccessorMethod]
		public uint auto_complete_delay { get; set construct; }
		[NoAccessorMethod]
		public uint proposal_page_size { get; set construct; }
		[NoAccessorMethod]
		public uint provider_page_size { get; set construct; }
		[NoAccessorMethod]
		public bool remember_info_visibility { get; set construct; }
		[NoAccessorMethod]
		public bool select_on_show { get; set construct; }
		[NoAccessorMethod]
		public bool show_headers { get; set construct; }
		[NoAccessorMethod]
		public bool show_icons { get; set construct; }
		public Gtk.SourceView view { get; construct; }
		public virtual signal void activate_proposal ();
		[HasEmitter]
		public virtual signal void hide ();
		public virtual signal void move_cursor (Gtk.ScrollStep step, int num);
		public virtual signal void move_page (Gtk.ScrollStep step, int num);
		public virtual signal void populate_context (Gtk.SourceCompletionContext context);
		[HasEmitter]
		public virtual signal void show ();
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceCompletionContext : GLib.InitiallyUnowned {
		public void add_proposals (void* provider, GLib.List proposals, bool finished);
		public Gtk.SourceCompletionActivation get_activation ();
		public void get_iter (Gtk.TextIter iter);
		[NoAccessorMethod]
		public Gtk.SourceCompletionActivation activation { get; set; }
		[NoAccessorMethod]
		public Gtk.SourceCompletion completion { owned get; construct; }
		[NoAccessorMethod]
		public Gtk.TextIter iter { get; set; }
		public virtual signal void cancelled ();
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceCompletionInfo : Gtk.Window, Atk.Implementor, Gtk.Buildable {
		[CCode (has_construct_function = false)]
		public SourceCompletionInfo ();
		public unowned Gtk.Widget get_widget ();
		public void move_to_iter (Gtk.TextView view, Gtk.TextIter? iter = null);
		public void process_resize ();
		public void set_sizing (int width, int height, bool shrink_width, bool shrink_height);
		public void set_widget (Gtk.Widget widget);
		[NoAccessorMethod]
		public int max_height { get; set construct; }
		[NoAccessorMethod]
		public int max_width { get; set construct; }
		[NoAccessorMethod]
		public bool shrink_height { get; set construct; }
		[NoAccessorMethod]
		public bool shrink_width { get; set construct; }
		public virtual signal void before_show ();
	}
	[CCode (cheader_filename = "gtksourceview/gtksourcecompletionitem.h")]
	public class SourceCompletionItem : GLib.Object, Gtk.SourceCompletionProposal {
		[CCode (has_construct_function = false)]
		public SourceCompletionItem (string label, string text, Gdk.Pixbuf? icon, string? info);
		[CCode (has_construct_function = false)]
		public SourceCompletionItem.from_stock (string label, string text, string stock, string info);
		[CCode (has_construct_function = false)]
		public SourceCompletionItem.with_markup (string markup, string text, Gdk.Pixbuf icon, string info);
		[NoAccessorMethod]
		public Gdk.Pixbuf icon { owned get; set; }
		[NoAccessorMethod]
		public string info { owned get; set; }
		[NoAccessorMethod]
		public string label { owned get; set; }
		[NoAccessorMethod]
		public string markup { owned get; set; }
		[NoAccessorMethod]
		public string text { owned get; set; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceCompletionWords : GLib.Object, Gtk.SourceCompletionProvider {
		[CCode (has_construct_function = false)]
		public SourceCompletionWords (string name, Gdk.Pixbuf icon);
		public void register (Gtk.TextBuffer buffer);
		public void unregister (Gtk.TextBuffer buffer);
		[NoAccessorMethod]
		public Gdk.Pixbuf icon { owned get; set construct; }
		[NoAccessorMethod]
		public int interactive_delay { get; set construct; }
		[NoAccessorMethod]
		public uint minimum_word_size { get; set construct; }
		[NoAccessorMethod]
		public string name { owned get; set construct; }
		[NoAccessorMethod]
		public int priority { get; set construct; }
		[NoAccessorMethod]
		public uint proposals_batch_size { get; set construct; }
		[NoAccessorMethod]
		public uint scan_batch_size { get; set construct; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceGutter : GLib.Object {
		public unowned Gdk.Window get_window ();
		public void insert (Gtk.CellRenderer renderer, int position);
		public void queue_draw ();
		public void remove (Gtk.CellRenderer renderer);
		public void reorder (Gtk.CellRenderer renderer, int position);
		public void set_cell_data_func (Gtk.CellRenderer renderer, Gtk.SourceGutterDataFunc func, void* func_data, GLib.DestroyNotify destroy);
		public void set_cell_size_func (Gtk.CellRenderer renderer, Gtk.SourceGutterSizeFunc func, void* func_data, GLib.DestroyNotify destroy);
		[NoAccessorMethod]
		public Gtk.SourceView view { owned get; construct; }
		[NoAccessorMethod]
		public Gtk.TextWindowType window_type { get; construct; }
		public virtual signal void cell_activated (Gtk.CellRenderer renderer, Gtk.TextIter iter, Gdk.Event event);
		public virtual signal bool query_tooltip (Gtk.CellRenderer renderer, Gtk.TextIter iter, Gtk.Tooltip tooltip);
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceLanguage : GLib.Object {
		public unowned string get_globs ();
		public bool get_hidden ();
		public unowned string get_id ();
		public unowned string get_metadata (string name);
		public unowned string get_mime_types ();
		public unowned string get_name ();
		public unowned string get_section ();
		public unowned string get_style_ids ();
		public unowned string get_style_name (string style_id);
		public bool hidden { get; }
		public string id { get; }
		public string name { get; }
		public string section { get; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourcelanguagemanager.h")]
	public class SourceLanguageManager : GLib.Object {
		[CCode (has_construct_function = false)]
		public SourceLanguageManager ();
		public static unowned Gtk.SourceLanguageManager get_default ();
		public unowned Gtk.SourceLanguage get_language (string id);
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[]? get_language_ids ();
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[]? get_search_path ();
		public unowned Gtk.SourceLanguage? guess_language (string? filename, string? content_type);
		public void set_search_path ([CCode (array_length = false)] string[]? dirs);
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] language_ids { get; }
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] search_path { get; set; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceMark : Gtk.TextMark {
		[CCode (has_construct_function = false)]
		public SourceMark (string name, string category);
		public unowned string get_category ();
		public unowned Gtk.SourceMark next (string category);
		public unowned Gtk.SourceMark prev (string category);
		public string category { get; construct; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceprintcompositor.h")]
	public class SourcePrintCompositor : GLib.Object {
		[CCode (has_construct_function = false)]
		public SourcePrintCompositor (Gtk.SourceBuffer buffer);
		public void draw_page (Gtk.PrintContext context, int page_nr);
		[CCode (has_construct_function = false)]
		public SourcePrintCompositor.from_view (Gtk.SourceView view);
		public unowned string get_body_font_name ();
		public double get_bottom_margin (Gtk.Unit unit);
		public unowned Gtk.SourceBuffer get_buffer ();
		public unowned string get_footer_font_name ();
		public unowned string get_header_font_name ();
		public bool get_highlight_syntax ();
		public double get_left_margin (Gtk.Unit unit);
		public unowned string get_line_numbers_font_name ();
		public int get_n_pages ();
		public double get_pagination_progress ();
		public bool get_print_footer ();
		public bool get_print_header ();
		public uint get_print_line_numbers ();
		public double get_right_margin (Gtk.Unit unit);
		public uint get_tab_width ();
		public double get_top_margin (Gtk.Unit unit);
		public Gtk.WrapMode get_wrap_mode ();
		public bool paginate (Gtk.PrintContext context);
		public void set_body_font_name (string font_name);
		public void set_bottom_margin (double margin, Gtk.Unit unit);
		public void set_footer_font_name (string font_name);
		public void set_footer_format (bool separator, string left, string center, string right);
		public void set_header_font_name (string font_name);
		public void set_header_format (bool separator, string left, string center, string right);
		public void set_highlight_syntax (bool highlight);
		public void set_left_margin (double margin, Gtk.Unit unit);
		public void set_line_numbers_font_name (string font_name);
		public void set_print_footer (bool print);
		public void set_print_header (bool print);
		public void set_print_line_numbers (uint interval);
		public void set_right_margin (double margin, Gtk.Unit unit);
		public void set_tab_width (uint width);
		public void set_top_margin (double margin, Gtk.Unit unit);
		public void set_wrap_mode (Gtk.WrapMode wrap_mode);
		public string body_font_name { get; set; }
		public Gtk.SourceBuffer buffer { get; construct; }
		public string footer_font_name { get; set; }
		public string header_font_name { get; set; }
		public bool highlight_syntax { get; set; }
		public string line_numbers_font_name { get; set; }
		public int n_pages { get; }
		public bool print_footer { get; set; }
		public bool print_header { get; set; }
		public uint print_line_numbers { get; set; }
		public uint tab_width { get; set; }
		public Gtk.WrapMode wrap_mode { get; set; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceStyle : GLib.Object {
		public Gtk.SourceStyle copy ();
		[NoAccessorMethod]
		public string background { owned get; construct; }
		[NoAccessorMethod]
		public bool background_set { get; construct; }
		[NoAccessorMethod]
		public bool bold { get; construct; }
		[NoAccessorMethod]
		public bool bold_set { get; construct; }
		[NoAccessorMethod]
		public string foreground { owned get; construct; }
		[NoAccessorMethod]
		public bool foreground_set { get; construct; }
		[NoAccessorMethod]
		public bool italic { get; construct; }
		[NoAccessorMethod]
		public bool italic_set { get; construct; }
		[NoAccessorMethod]
		public string line_background { owned get; construct; }
		[NoAccessorMethod]
		public bool line_background_set { get; construct; }
		[NoAccessorMethod]
		public bool strikethrough { get; construct; }
		[NoAccessorMethod]
		public bool strikethrough_set { get; construct; }
		[NoAccessorMethod]
		public bool underline { get; construct; }
		[NoAccessorMethod]
		public bool underline_set { get; construct; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceStyleScheme : GLib.Object {
		public unowned string get_authors ();
		public unowned string get_description ();
		public unowned string get_filename ();
		public unowned string get_id ();
		public unowned string get_name ();
		public unowned Gtk.SourceStyle get_style (string style_id);
		public string description { get; }
		public string filename { get; }
		public string id { get; construct; }
		public string name { get; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourcestyleschememanager.h")]
	public class SourceStyleSchemeManager : GLib.Object {
		[CCode (has_construct_function = false)]
		public SourceStyleSchemeManager ();
		public void append_search_path (string path);
		public void force_rescan ();
		public static unowned Gtk.SourceStyleSchemeManager get_default ();
		public unowned Gtk.SourceStyleScheme get_scheme (string scheme_id);
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[] get_scheme_ids ();
		[CCode (array_length = false, array_null_terminated = true)]
		public unowned string[] get_search_path ();
		public void prepend_search_path (string path);
		public void set_search_path (string path);
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] scheme_ids { get; }
		[CCode (array_length = false, array_null_terminated = true)]
		public string[] search_path { get; set; }
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public class SourceView : Gtk.TextView, Atk.Implementor, Gtk.Buildable {
		[CCode (type = "GtkWidget*", has_construct_function = false)]
		public SourceView ();
		public bool get_auto_indent ();
		public unowned Gtk.SourceCompletion get_completion ();
		public Gtk.SourceDrawSpacesFlags get_draw_spaces ();
		public unowned Gtk.SourceGutter get_gutter (Gtk.TextWindowType window_type);
		public bool get_highlight_current_line ();
		public bool get_indent_on_tab ();
		public int get_indent_width ();
		public bool get_insert_spaces_instead_of_tabs ();
		public bool get_mark_category_background (string category, Gdk.Color dest);
		public unowned Gdk.Pixbuf get_mark_category_pixbuf (string category);
		public int get_mark_category_priority (string category);
		public uint get_right_margin_position ();
		public bool get_show_line_marks ();
		public bool get_show_line_numbers ();
		public bool get_show_right_margin ();
		public Gtk.SourceSmartHomeEndType get_smart_home_end ();
		public uint get_tab_width ();
		public void set_auto_indent (bool enable);
		public void set_draw_spaces (Gtk.SourceDrawSpacesFlags flags);
		public void set_highlight_current_line (bool show);
		public void set_indent_on_tab (bool enable);
		public void set_indent_width (int width);
		public void set_insert_spaces_instead_of_tabs (bool enable);
		public void set_mark_category_background (string category, Gdk.Color color);
		public void set_mark_category_icon_from_icon_name (string category, string name);
		public void set_mark_category_icon_from_pixbuf (string category, Gdk.Pixbuf pixbuf);
		public void set_mark_category_icon_from_stock (string category, string stock_id);
		public void set_mark_category_pixbuf (string category, Gdk.Pixbuf pixbuf);
		public void set_mark_category_priority (string category, int priority);
		public void set_mark_category_tooltip_func (string category, Gtk.SourceViewMarkTooltipFunc func, GLib.DestroyNotify user_data_notify);
		public void set_mark_category_tooltip_markup_func (string category, Gtk.SourceViewMarkTooltipFunc markup_func, GLib.DestroyNotify user_data_notify);
		public void set_right_margin_position (uint pos);
		public void set_show_line_marks (bool show);
		public void set_show_line_numbers (bool show);
		public void set_show_right_margin (bool show);
		public void set_smart_home_end (Gtk.SourceSmartHomeEndType smart_he);
		public void set_tab_width (uint width);
		[CCode (type = "GtkWidget*", has_construct_function = false)]
		public SourceView.with_buffer (Gtk.SourceBuffer buffer);
		public bool auto_indent { get; set; }
		public Gtk.SourceCompletion completion { get; }
		public Gtk.SourceDrawSpacesFlags draw_spaces { get; set; }
		public bool highlight_current_line { get; set; }
		public bool indent_on_tab { get; set; }
		public int indent_width { get; set; }
		public bool insert_spaces_instead_of_tabs { get; set; }
		public uint right_margin_position { get; set; }
		public bool show_line_marks { get; set; }
		public bool show_line_numbers { get; set; }
		public bool show_right_margin { get; set; }
		public Gtk.SourceSmartHomeEndType smart_home_end { get; set; }
		public uint tab_width { get; set; }
		public virtual signal void line_mark_activated (Gtk.TextIter iter, Gdk.Event event);
		public virtual signal void move_lines (bool copy, int step);
		public virtual signal void redo ();
		public virtual signal void show_completion ();
		public virtual signal void undo ();
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public interface SourceCompletionProposal : GLib.Object {
		public abstract bool equal (Gtk.SourceCompletionProposal other);
		public abstract unowned Gdk.Pixbuf get_icon ();
		public abstract unowned string get_info ();
		public abstract unowned string get_label ();
		public abstract unowned string get_markup ();
		public abstract unowned string get_text ();
		public abstract uint hash ();
		[HasEmitter]
		public signal void changed ();
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public interface SourceCompletionProvider : GLib.Object {
		public abstract bool activate_proposal (Gtk.SourceCompletionProposal proposal, Gtk.TextIter iter);
		public abstract Gtk.SourceCompletionActivation get_activation ();
		public abstract unowned Gdk.Pixbuf get_icon ();
		public abstract unowned Gtk.Widget? get_info_widget (Gtk.SourceCompletionProposal proposal);
		public abstract int get_interactive_delay ();
		public abstract string get_name ();
		public abstract int get_priority ();
		public abstract bool get_start_iter (Gtk.SourceCompletionContext context, Gtk.SourceCompletionProposal proposal, Gtk.TextIter iter);
		public abstract bool match (Gtk.SourceCompletionContext context);
		public abstract void populate (Gtk.SourceCompletionContext context);
		public abstract void update_info (Gtk.SourceCompletionProposal proposal, Gtk.SourceCompletionInfo info);
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public interface SourceUndoManager : GLib.Object {
		public abstract void begin_not_undoable_action ();
		public abstract bool can_redo ();
		public abstract bool can_undo ();
		public abstract void end_not_undoable_action ();
		public abstract void redo ();
		public abstract void undo ();
		[HasEmitter]
		public signal void can_redo_changed ();
		[HasEmitter]
		public signal void can_undo_changed ();
	}
	[CCode (cprefix = "GTK_SOURCE_COMPLETION_ACTIVATION_", cheader_filename = "gtksourceview/gtksourceview.h")]
	[Flags]
	public enum SourceCompletionActivation {
		NONE,
		INTERACTIVE,
		USER_REQUESTED
	}
	[CCode (cprefix = "GTK_SOURCE_COMPLETION_ERROR_", cheader_filename = "gtksourceview/gtksourceview.h")]
	public enum SourceCompletionError {
		ALREADY_BOUND,
		NOT_BOUND
	}
	[CCode (cprefix = "GTK_SOURCE_DRAW_SPACES_", cheader_filename = "gtksourceview/gtksourceview.h")]
	[Flags]
	public enum SourceDrawSpacesFlags {
		SPACE,
		TAB,
		NEWLINE,
		NBSP,
		LEADING,
		TEXT,
		TRAILING,
		ALL
	}
	[CCode (cprefix = "GTK_SOURCE_SEARCH_", cheader_filename = "gtksourceview/gtksourceiter.h")]
	[Flags]
	public enum SourceSearchFlags {
		VISIBLE_ONLY,
		TEXT_ONLY,
		CASE_INSENSITIVE
	}
	[CCode (cprefix = "GTK_SOURCE_SMART_HOME_END_", cheader_filename = "gtksourceview/gtksourceview.h")]
	public enum SourceSmartHomeEndType {
		DISABLED,
		BEFORE,
		AFTER,
		ALWAYS
	}
	[CCode (cprefix = "GTK_SOURCE_VIEW_GUTTER_POSITION_", cheader_filename = "gtksourceview/gtksourceview.h")]
	public enum SourceViewGutterPosition {
		LINES,
		MARKS
	}
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public delegate void SourceGutterDataFunc (Gtk.SourceGutter gutter, Gtk.CellRenderer cell, int line_number, bool current_line);
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public delegate void SourceGutterSizeFunc (Gtk.SourceGutter gutter, Gtk.CellRenderer cell);
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public delegate unowned string SourceViewMarkTooltipFunc (Gtk.SourceMark mark);
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public const string SOURCE_COMPLETION_CAPABILITY_AUTOMATIC;
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public const string SOURCE_COMPLETION_CAPABILITY_INTERACTIVE;
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public static bool source_iter_backward_search (Gtk.TextIter iter, string str, Gtk.SourceSearchFlags flags, out Gtk.TextIter match_start, out Gtk.TextIter match_end, Gtk.TextIter? limit);
	[CCode (cheader_filename = "gtksourceview/gtksourceview.h")]
	public static bool source_iter_forward_search (Gtk.TextIter iter, string str, Gtk.SourceSearchFlags flags, out Gtk.TextIter match_start, out Gtk.TextIter match_end, Gtk.TextIter? limit);
}
