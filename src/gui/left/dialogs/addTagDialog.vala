namespace LFinance {
	internal class CreateTagDialog : Gtk.Dialog {
		Model model;

		Gtk.ColorButton color_button;
		CustomColorButton custom_color;
		Gee.List<ColoredRadioButton> colored_radio_buttons;
		Gtk.Entry entry;

		internal CreateTagDialog(Model model) {
			this.title = _("Create Tag");
			this.modal = true;
			this.model = model;
			this.colored_radio_buttons = new Gee.ArrayList<ColoredRadioButton>();
			this.build_gui ();
			this.connect_signals ();
		}
		void build_gui() {
			this.add_buttons (_("_Cancel"), Gtk.ResponseType.CANCEL, _("Create Tag"), Gtk.ResponseType.OK);
			var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
			var label = new Gtk.Label (_("Name:"));
			this.entry = new Gtk.Entry ();
			this.color_button = new Gtk.ColorButton ();
			this.custom_color = new CustomColorButton (this.colored_radio_buttons);
			box.pack_start (this.custom_color, true, true, 2);
			this.colored_radio_buttons.add (this.custom_color);
			foreach(var c in Colors.get_colors ()) {
				var c2 = c.strip ();
				if(c2.length == 0) {
					continue;
				}
				var btn = new RecommendedColorButton (c2, this.colored_radio_buttons);
				btn.join_group (this.custom_color);
				btn.set_text (_("Sample text"));
				this.colored_radio_buttons.add (btn);
				box.pack_start (btn, true, true, 2);
			}
			var scr = new Gtk.ScrolledWindow (null, null);
			scr.add (box);
			var ca = this.get_content_area ();
			ca.pack_start (label, false, false, 2);
			ca.pack_start (this.entry, false, false, 2);
			ca.pack_start (scr, true, true, 2);
			ca.pack_start (this.color_button, false, false, 2);
			((Gtk.Button) this.get_widget_for_response (Gtk.ResponseType.OK)).set_sensitive (false);
			// Hacky way to show all widgets
			this.resize (200, 600);
			this.show_all ();
		}
		void connect_signals() {
			this.custom_color.toggled.connect (() => {
				this.color_button.set_visible (this.custom_color.get_active ());
			});
			this.color_button.color_set.connect (() => {
				var rgba = color_button.get_rgba ();
				var r = (uint8)(255 * rgba.red);
				var g = (uint8)(255 * rgba.green);
				var b = (uint8)(255 * rgba.blue);
				var a = (uint8)(255 * rgba.alpha);
				this.custom_color.set_color ("#%02x%02x%02x%02x".printf (r, g, b, a));
			});
			this.entry.changed.connect (() => {
				var text = _("Sample text");
				var et = this.entry.buffer.text;
				if(et.length != 0) {
					text = et;
				}
				foreach(var btn in this.colored_radio_buttons) {
					btn.set_text (text);
				}
				var btn = (Gtk.Button) this.get_widget_for_response (Gtk.ResponseType.OK);
				if(et.length == 0 || this.model.search_tag (et) != null) {
					btn.set_sensitive (false);
				} else {
					btn.set_sensitive (true);
				}
			});
		}
		internal string get_name() {
			return this.entry.buffer.text;
		}
		internal string get_active_color() {
			foreach(var item in this.colored_radio_buttons) {
				if(((Gtk.RadioButton) item).get_active ()) {
					return item.get_color ();
				}
			}
			critical ("Should not reach here!");
			return "";
		}
	}
}
