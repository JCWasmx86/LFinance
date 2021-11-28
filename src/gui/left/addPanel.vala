namespace MoneyWatch {
	internal class AddPanel : Gtk.Box {
		Model model;

		internal AddPanel(Model model) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			var add_account = new Gtk.Button.with_label(_("Create Account"));
			add_account.clicked.connect(() => {
				var dialog = new AddAccountDialog(this.model);
				var result = dialog.run();
				if(result == 0) {
					var text = dialog.get_text();
					dialog.destroy();
					model.add_account(new Account(text));
				} else {
					dialog.destroy();
				}
			});
			this.pack_start(add_account, true, true, 2);
			var add_location = new Gtk.Button.with_label(_("Create Location"));
			add_location.clicked.connect(() => {
				var dialog = new AddLocationDialog(this.model);
				var result = dialog.run();
				if(result == 0) {
					var loc = dialog.build_location();
					dialog.destroy();
					model.add_location(loc);
				} else {
					dialog.destroy();
				}
			});
			this.pack_start(add_location, true, true, 2);
			var add_tag = new Gtk.Button.with_label(_("Create Tag"));
			add_tag.clicked.connect(() => {
				var dialog = new CreateTagDialog(this.model);
				var result = dialog.run();
				if(result == 0) {
					var name = dialog.get_name();
					var color = dialog.get_active_color();
					var rgba = new uint8[4];
					color.scanf("#%02x%02x,02x02x", out rgba[0], out rgba[1], out rgba[2], out rgba[3]);
					model.add_tag(new Tag(name, rgba));
				}
				dialog.destroy();
			});
			this.pack_start(add_tag, true, true, 2);
		}
	}
}
