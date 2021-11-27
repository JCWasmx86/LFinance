namespace MoneyWatch {
	internal class LocationEditDialog : Gtk.Dialog {
		Gtk.Entry name_entry;
		Gtk.Entry city;
		Gtk.TextView textview;
		
		internal LocationEditDialog(string selected, Model model) {
			this.title = _("Edit location");
			var location = model.search_location_by_id(selected);
			this.name_entry = new Gtk.Entry();
			this.name_entry.set_text(location._name);
			this.city = new Gtk.Entry();
			this.city.set_text(location._city);
			this.textview = new Gtk.TextView();
			this.textview.buffer.set_text(location._further_info);
			this.get_content_area().pack_start(new Gtk.Label(_("Name:")), false, true, 2);
			this.get_content_area().pack_start(this.name_entry, false, true, 2);
			this.get_content_area().pack_start(new Gtk.Label(_("City:")), false, true, 2);
			this.get_content_area().pack_start(this.city, false, true, 2);
			this.get_content_area().pack_start(new Gtk.Label(_("Further information")), false, true, 2);
			this.get_content_area().pack_start(this.textview, true, true, 2);
			this.add_button(_("Edit"), 0);
			this.add_button(_("Cancel"), 1);
			this.show_all();
		}
		internal string get_name() {
			return this.name_entry.buffer.text;
		}
		internal string get_city() {
			return this.city.buffer.text;
		}
		internal string get_info() {
			return this.textview.buffer.text;
		}
	}
}
