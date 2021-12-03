namespace LFinance {
	internal class AddAccountDialog : Gtk.Dialog {
		Model model;
		Gtk.Entry entry;

		internal AddAccountDialog(Model model) {
			this.title = _("Create Account");
			this.modal = true;
			this.model = model;
			this.build_gui();
		}
		void build_gui() {
			this.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("Create Account"), Gtk.ResponseType.OK);
			var label = new Gtk.Label(_("Name:"));
			this.entry = new Gtk.Entry();
			entry.changed.connect(() => {
				var btn = ((Gtk.Button)this.get_widget_for_response(Gtk.ResponseType.OK));
				var text = this.get_text();
				if(text.length == 0 || this.model.account_exists(text)) {
					btn.set_sensitive(false);
				} else {
					btn.set_sensitive(true);
				}
			});
			this.get_content_area().pack_start(label, true, true, 2);
			this.get_content_area().pack_start(this.entry, true, true, 2);
			((Gtk.Button)this.get_widget_for_response(Gtk.ResponseType.OK)).set_sensitive(false);
			this.show_all();
		}
		internal string get_text() {
			return this.entry.buffer.text;
		}
	}
}
