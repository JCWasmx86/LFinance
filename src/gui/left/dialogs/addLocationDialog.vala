namespace LFinance {
	internal class AddLocationDialog : Gtk.Dialog {
		Model model;

		Gtk.Entry name_entry;
		Gtk.Entry city;
		Gtk.TextView info;

		internal AddLocationDialog(Model model) {
			this.title = _("Create Location");
			this.modal = true;
			this.model = model;
			this.build_gui ();
			this.connect_signals ();
		}

		void build_gui() {
			this.add_buttons (_("_Cancel"), Gtk.ResponseType.CANCEL, _(
						  "Create Location"), Gtk.ResponseType.OK);
			var name_l = new Gtk.Label (_("Name:"));
			this.name_entry = new Gtk.Entry ();
			var city_l = new Gtk.Label (_("City:"));
			this.city = new Gtk.Entry ();
			var info_l = new Gtk.Label (_("Further information"));
			this.info = new Gtk.TextView ();
			var ca = this.get_content_area ();
			ca.pack_start (name_l, false, false, 2);
			ca.pack_start (this.name_entry, false, false, 2);
			ca.pack_start (city_l, false, false, 2);
			ca.pack_start (this.city, false, false, 2);
			ca.pack_start (info_l, false, false, 2);
			ca.pack_start (this.info, true, true, 2);
			// Hacky way to show all widgets
			this.resize (200, 400);
			((Gtk.Button) this.get_widget_for_response (Gtk.ResponseType.OK)).set_sensitive (false);
			this.show_all ();
		}

		void connect_signals() {
			this.name_entry.changed.connect (() => {
				var btn = ((Gtk.Button) this.get_widget_for_response (Gtk.ResponseType.OK));
				var nb = this.name_entry.buffer.text;
				if(nb.length == 0 || this.model.search_location (nb, this.city.buffer.text) != null) {
					btn.set_sensitive (false);
				} else {
					btn.set_sensitive (true);
				}
			});
			this.city.changed.connect (() => {
				var btn = ((Gtk.Button) this.get_widget_for_response (Gtk.ResponseType.OK));
				var nb = this.name_entry.buffer.text;
				if(nb.length == 0 || model.search_location (nb, this.city.buffer.text) != null) {
					btn.set_sensitive (false);
				} else {
					btn.set_sensitive (true);
				}
			});
		}
		internal Location build_location() {
			return new Location (this.name_entry.buffer.text, this.city.buffer.text, this.info.buffer.text);
		}
	}
}
