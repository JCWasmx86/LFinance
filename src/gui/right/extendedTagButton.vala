namespace MoneyWatch {
	internal class ExtendedTagButton : Gtk.Box {
		Tag tag;
		Gee.List<ExtendedTagButton> btns;

		internal ExtendedTagButton(Tag t, Account account, Expense expense, Gee.List<ExtendedTagButton> btns) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 2);
			this.tag = t;
			this.btns = btns;
			this.build_gui();
			this.style_widget();
		}
		void build_gui() {
			var colors = this.tag._rgba;
			var label = new Gtk.Label("");
			label.set_markup("<b><span foreground=\"#%02x%02x%02x%02x\" >%s</span></b>".printf(colors[0], colors[1], colors[2], colors[3], this.tag._name));
			this.pack_start(label, false, false, 2);
			var button = new Gtk.Button.from_icon_name("edit-delete");
			button.tooltip_text = _("Delete Tag");
			button.clicked.connect(() => {
				var parent = this.get_parent();
				btns.remove(this);
				parent.remove(this);
			});
			this.pack_start(button, false, false, 2);
		}
		void style_widget() {
			var provider = new Gtk.CssProvider();
			try {
				provider.load_from_data("""
					.bordered {
						border: 1px solid #3F4747;
					}
				""");
			} catch(GLib.Error e) {
				warning("Gtk.CssProvider::load_from_data failed: %s", e.message);
			}
			this.get_style_context().add_class("bordered");
			this.get_style_context().add_provider(provider, -1);
		}
		internal Tag get_tag() {
			return this.tag;
		}
	}

}
