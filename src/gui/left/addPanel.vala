namespace MoneyWatch {
	internal class AddPanel : Gtk.Box {
		Model model;
		internal AddPanel(Model model) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			var add_account = new Gtk.Button.with_label(_("Create Account"));
			add_account.clicked.connect(() => {
				var label = new Gtk.Label(_("Name:"));
				var entry = new Gtk.Entry();
				var dialog = new Gtk.Dialog.with_buttons(_("Create Account"), null, Gtk.DialogFlags.MODAL);
				dialog.add_button(_("Create Account"), 0);
				dialog.add_button(_("Cancel"), 1);
				dialog.get_content_area().pack_start(label, true, true, 2);
				dialog.get_content_area().pack_start(entry, true, true, 2);
				entry.changed.connect(() => {
					var btn = ((Gtk.Button)dialog.get_widget_for_response(0));
					if(entry.buffer.text.length == 0 || model.account_exists(entry.buffer.text)) {
						btn.set_sensitive(false);
					} else {
						btn.set_sensitive(true);
					}
				});
				((Gtk.Button)dialog.get_widget_for_response(0)).set_sensitive(false);
				dialog.show_all();
				var result = dialog.run();
				if(result == 0) {
					var text = entry.buffer.text;
					dialog.destroy();
					model.add_account(new Account(text));
				} else {
					dialog.destroy();
				}
			});
			this.pack_start(add_account, true, true, 2);
			var add_tag = new Gtk.Button.with_label(_("Create Tag"));
			add_tag.clicked.connect(() => {
				var label = new Gtk.Label(_("Name:"));
				var entry = new Gtk.Entry();
				var dialog = new Gtk.Dialog.with_buttons(_("Create Tag"), null, Gtk.DialogFlags.MODAL);
				dialog.add_button(_("Create Tag"), 0);
				dialog.add_button(_("Cancel"), 1);
				var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
				var list = new Gee.ArrayList<ColoredRadioButton>();
				var color_button = new Gtk.ColorButton();
				var custom_color = new CustomColorButton(list);
				custom_color.toggled.connect(() => {
					color_button.set_visible(custom_color.get_active());
				});
				color_button.color_set.connect(() => {
					var rgba = color_button.get_rgba();
					var r = (uint8)(255 * rgba.red);
					var g = (uint8)(255 * rgba.green);
					var b = (uint8)(255 * rgba.blue);
					var a = (uint8)(255 * rgba.alpha);
					custom_color.set_color("#%02x%02x%02x%02x".printf(r, g, b, a));
				});
				box.pack_start(custom_color, true, true, 2);
				list.add(custom_color);
				foreach(var c in Colors.get_colors()) {
					var c2 = c.strip();
					if(c2.length == 0)
						continue;
					var btn = new RecommendedColorButton(c2, list);
					btn.join_group(custom_color);
					list.add(btn);
					box.pack_start(btn, true, true, 2);
				}
				var scr = new Gtk.ScrolledWindow(null, null);
				scr.add(box);
				entry.changed.connect(() => {
					var text = _("Sample text");
					if(entry.buffer.text.length != 0)
						text = entry.buffer.text;
					foreach(var btn in list) {
						btn.set_text(text);
					}
					var btn = ((Gtk.Button)dialog.get_widget_for_response(0));
					if(entry.buffer.text.length == 0 || model.search_tag(entry.buffer.text) != null) {
						btn.set_sensitive(false);
					} else {
						btn.set_sensitive(true);
					}
				});
				dialog.get_content_area().pack_start(label, false, false, 2);
				dialog.get_content_area().pack_start(entry, false, false, 2);
				dialog.get_content_area().pack_start(scr, true, true, 2);
				dialog.get_content_area().pack_start(color_button, false, false, 2);
				((Gtk.Button)dialog.get_widget_for_response(0)).set_sensitive(false);
				// Hacky way to show all widgets
				dialog.resize(200, 600);
				dialog.show_all();
				GLib.Signal.emit_by_name(entry, "changed");
				var result = dialog.run();
				if(result == 0) {
					var name = entry.buffer.text;
					var color = "";
					foreach(var item in list) {
						if(((Gtk.RadioButton)item).get_active()) {
							color = item.get_color();
							break;
						}
					}
					var rgba = new uint8[4];
					color.scanf("#%02x%02x,02x02x", out rgba[0], out rgba[1], out rgba[2], out rgba[3]);
					model.add_tag(new Tag(name, rgba));
				}
				dialog.destroy();
			});
			this.pack_start(add_tag, true, true, 2);
			var add_location = new Gtk.Button.with_label(_("Create Location"));
			add_location.clicked.connect(() => {
				var name_l = new Gtk.Label(_("Name:"));
				var name = new Gtk.Entry();
				var city_l = new Gtk.Label(_("City:"));
				var city = new Gtk.Entry();
				var info_l = new Gtk.Label(_("Further information"));
				var info = new Gtk.TextView();
				var dialog = new Gtk.Dialog.with_buttons(_("Create Tag"), null, Gtk.DialogFlags.MODAL);
				dialog.add_button(_("Create Location"), 0);
				dialog.add_button(_("Cancel"), 1);
				dialog.get_content_area().pack_start(name_l, false, false, 2);
				dialog.get_content_area().pack_start(name, false, false, 2);
				dialog.get_content_area().pack_start(city_l, false, false, 2);
				dialog.get_content_area().pack_start(city, false, false, 2);
				dialog.get_content_area().pack_start(info_l, false, false, 2);
				dialog.get_content_area().pack_start(info, true, true, 2);
				name.changed.connect(() => {
					var btn = ((Gtk.Button)dialog.get_widget_for_response(0));
					if(name.buffer.text.length == 0 || model.search_location(name.buffer.text, city.buffer.text) != null) {
						btn.set_sensitive(false);
					} else {
						btn.set_sensitive(true);
					}
				});
				city.changed.connect(() => {
					var btn = ((Gtk.Button)dialog.get_widget_for_response(0));
					if(name.buffer.text.length == 0 || model.search_location(name.buffer.text, city.buffer.text) != null) {
						btn.set_sensitive(false);
					} else {
						btn.set_sensitive(true);
					}
				});
				// Hacky way to show all widgets
				dialog.resize(200, 400);
				((Gtk.Button)dialog.get_widget_for_response(0)).set_sensitive(false);
				dialog.show_all();
				var result = dialog.run();
				if(result == 0) {
					var name_ = name.buffer.text;
					var city_ = city.buffer.text;
					var info_ = info.buffer.text;
					dialog.destroy();
					model.add_location(new Location(name_, city_, info_));
				} else {
					dialog.destroy();
				}
			});
			this.pack_start(add_location, true, true, 2);
		}
	}
}
