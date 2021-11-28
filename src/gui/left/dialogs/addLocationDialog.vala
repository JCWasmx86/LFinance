namespace MoneyWatch {
	internal class AddLocationDialog : Gtk.Dialog {
		Model model;

		Gtk.Entry name;
		Gtk.Entry city;
		Gtk.TextView info;

		internal AddLocationDialog(Model model) {
			this.title = _("Create Location");
			this.modal = true;
			this.model = model;
			this.build_gui();
			this.connect_signals();
		}

		void build_gui() {
			this.add_button(_("Create Location"), 0);
			this.add_button(_("Cancel"), 1);
			var name_l = new Gtk.Label(_("Name:"));
			this.name = new Gtk.Entry();
			var city_l = new Gtk.Label(_("City:"));
			this.city = new Gtk.Entry();
			var info_l = new Gtk.Label(_("Further information"));
			this.info = new Gtk.TextView();
			var ca = this.get_content_area();
			ca.pack_start(name_l, false, false, 2);
			ca.pack_start(this.name, false, false, 2);
			ca.pack_start(city_l, false, false, 2);
			ca.pack_start(this.city, false, false, 2);
			ca.pack_start(info_l, false, false, 2);
			ca.pack_start(this.info, true, true, 2);
			// Hacky way to show all widgets
			this.resize(200, 400);
			((Gtk.Button)this.get_widget_for_response(0)).set_sensitive(false);
			this.show_all();
		}

		void connect_signals() {
			this.name.changed.connect(() => {
				var btn = ((Gtk.Button)this.get_widget_for_response(0));
				var nb = this.name.buffer.text;
				if(nb.length == 0 || this.model.search_location(nb, this.city.buffer.text) != null) {
					btn.set_sensitive(false);
				} else {
					btn.set_sensitive(true);
				}
			});
			this.city.changed.connect(() => {
				var btn = ((Gtk.Button)this.get_widget_for_response(0));
				var nb = this.name.buffer.text;
				if(nb.length == 0 || model.search_location(nb, this.city.buffer.text) != null) {
					btn.set_sensitive(false);
				} else {
					btn.set_sensitive(true);
				}
			});
		}
		internal Location build_location() {
			return new Location(this.name.buffer.text, this.city.buffer.text, this.info.buffer.text);
		}
	}
}
