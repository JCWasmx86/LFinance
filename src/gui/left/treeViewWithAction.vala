namespace LFinance {
	internal class TreeViewWithAction : Gtk.TreeView {
		Gtk.TreeIter tp;
		Gtk.ListStore store;
		Gtk.CellRendererText renderer;
		bool editable;
		string title;
		string type;
		ActionHandler handler;

		internal TreeViewWithAction(string s, ActionHandler handler, string type =  "text", bool editable = true) {
			this.get_selection().set_mode(Gtk.SelectionMode.BROWSE);
			this.store = new Gtk.ListStore(3, GLib.Type.STRING, GLib.Type.STRING, GLib.Type.STRING);
			this.hover_selection = true;
			this.enable_search = true;
			this.editable = editable;
			this.title = s;
			this.type = type;
			this.handler = handler;

			this.set_events(Gdk.EventMask.ALL_EVENTS_MASK);
			this.build_gui();
			this.connect_signals();
		}
		
		void build_gui() {
			this.renderer = new Gtk.CellRendererText();
			this.renderer.editable = this.editable;
			var column = new Gtk.TreeViewColumn();
			column.set_title(this.title);
			column.pack_start(this.renderer, true);
			column.add_attribute(this.renderer, type, 0);
			this.append_column(column);
			this.set_model(this.store);
		}
		void connect_signals() {
			this.button_press_event.connect((event) => {
				var selected = this.get_selection();
				Gtk.TreeModel model;
				Gtk.TreeIter iter;
				selected.get_selected(out model, out iter);
				var val = Value(typeof(string));
				this.store.get_value(iter, 0, out val);
				var val2 = Value(typeof(string));
				this.store.get_value(iter, 1, out val2);
				handler.handle_mouse_press((string)val, event);
				return false;
			});
			this.renderer.edited.connect((path, new_text) => {
				var selected = this.get_selection();
				Gtk.TreeModel model;
				Gtk.TreeIter iter;
				selected.get_selected(out model, out iter);
				var val = Value(typeof(string));
				this.store.get_value(iter, 0, out val);
				string out_val = "";
				if(handler.handle_edit((string)val, new_text, out out_val))
					this.store.set_value(iter, 0, out_val == null ? new_text : out_val);
			});
			this.key_release_event.connect_after((event) => {
				var selected = this.get_selection();
				Gtk.TreeModel model;
				Gtk.TreeIter iter;
				selected.get_selected(out model, out iter);
				var val = Value(typeof(string));
				this.store.get_value(iter, 0, out val);
				handler.handle_key_press((string)val, event);
				return false;
			});
		}

		internal void append_string(string val, string shadow = "") {
			var val1 = Value(typeof(string));
			var val2 = Value(typeof(string));
			val1.set_string(val);
			val2.set_string(shadow);
			this.store.insert_with_valuesv(out tp, -1, new int[]{0, 1}, new Value[]{val1, val2});
		}
		internal void clear() {
			this.store.clear();
		}
	}
}
