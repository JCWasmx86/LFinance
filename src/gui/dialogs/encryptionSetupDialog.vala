namespace LFinance {
	internal class EncryptionSetupDialog : Gtk.Dialog {
		Gtk.Entry first;
		Gtk.Entry second;

		internal EncryptionSetupDialog() {
			this.title = _("Setup Encryption");
			this.modal = true;
			this.build_gui ();
			this.connect_signals ();
		}
		void build_gui() {
			this.add_buttons (_("_Cancel"),
					  Gtk.ResponseType.CANCEL,
					  _("Encrypt Data"),
					  Gtk.ResponseType.OK);
			this.get_widget_for_response (Gtk.ResponseType.OK).get_style_context ().add_class (
				"destructive-action");
			var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
			var label = new Gtk.Label (_("Enter password:"));
			this.first = new Gtk.Entry ();
			this.first.set_visibility (false);
			this.first.input_purpose = Gtk.InputPurpose.PASSWORD;
			box.pack_start (label, false, false, 2);
			box.pack_start (this.first, true, true, 2);
			var box2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
			var label2 = new Gtk.Label (_("Confirm password:"));
			this.second = new Gtk.Entry ();
			this.second.set_visibility (false);
			this.second.input_purpose = Gtk.InputPurpose.PASSWORD;
			box2.pack_start (label2, false, false, 2);
			box2.pack_start (this.second, true, true, 2);
			var ca = this.get_content_area ();
			ca.pack_start (box, false, false, 2);
			ca.pack_start (box2, false, false, 2);
			var warning = new Gtk.Label ("");
			warning.set_markup ("<b><span color=\"#FF0000\">%s</span></b>".printf (_(
												       "If you forget your password, your data is lost and can't be recovered!")));
			ca.pack_start (warning, true, true, 2);
			this.get_widget_for_response (Gtk.ResponseType.OK).set_sensitive (false);
			this.show_all ();
		}
		void connect_signals() {
			this.first.changed.connect (this.update_buttons);
			this.second.changed.connect (this.update_buttons);
		}
		void update_buttons() {
			if(this.first.text == "" || this.first.text != this.second.text) {
				this.get_widget_for_response (Gtk.ResponseType.OK).set_sensitive (false);
				return;
			}
			this.get_widget_for_response (Gtk.ResponseType.OK).set_sensitive (true);
		}
		internal string get_password() {
			return this.first.text;
		}
	}
}
