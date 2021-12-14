namespace LFinance {
	internal class AddPanel : Gtk.Box {
		Model model;

		internal AddPanel(Model model) {
			Object (orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			var add_account = new Gtk.Button.with_label (_("Create Account"));
			add_account.clicked.connect (() => {
				var dialog = new AddAccountDialog (this.model);
				var result = dialog.run ();
				if(result == Gtk.ResponseType.OK) {
					var text = dialog.get_text ();
					dialog.destroy ();
					var account = new Account (text);
					account.set_sorting (3);
					this.model.add_account (account);
				} else {
					dialog.destroy ();
				}
			});
			this.pack_start (add_account, true, true, 2);
			var add_location = new Gtk.Button.with_label (_("Create Location"));
			add_location.clicked.connect (() => {
				var dialog = new AddLocationDialog (this.model);
				var result = dialog.run ();
				if(result == Gtk.ResponseType.OK) {
					var loc = dialog.build_location ();
					dialog.destroy ();
					this.model.add_location (loc);
				} else {
					dialog.destroy ();
				}
			});
			this.pack_start (add_location, true, true, 2);
			var add_tag = new Gtk.Button.with_label (_("Create Tag"));
			add_tag.clicked.connect (() => {
				var dialog = new CreateTagDialog (this.model);
				var result = dialog.run ();
				if(result == Gtk.ResponseType.OK) {
					var name = dialog.get_name ();
					var color = dialog.get_active_color ();
					var rgba = new uint8[4];
					rgba[0] = (uint8)uint.parse (color.substring (1, 2), 16);
					rgba[1] = (uint8)uint.parse (color.substring (3, 2), 16);
					rgba[2] = (uint8)uint.parse (color.substring (5, 2), 16);
					if(color.length == 9)
						rgba[3] = (uint8)uint.parse (color.substring (7, 2), 16);
					this.model.add_tag (new Tag (name, rgba));
				}
				dialog.destroy ();
			});
			this.pack_start (add_tag, true, true, 2);
		}
	}
}
