namespace MoneyWatch {
	internal class AddTagDialog : Gtk.Dialog {
		internal unowned SList<Gtk.RadioButton> buttons{internal get; private set;}

		internal AddTagDialog(Model model, Gee.List<ExtendedTagButton> tags) {
			this.title = _("Add tag");
			this.add_button(_("Add tag"), 0);
			this.add_button(_("Cancel"), 1);
			var b = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			this.buttons = new SList<Gtk.RadioButton>();
			foreach(var tag in model._tags) {
				bool found = false;
				foreach(var btn in tags) {
					if(tag._name == btn.get_tag()._name) {
						found = true;
						break;
					}
				}
				if(found)
					continue;
				var radio = new Gtk.RadioButton.with_label(buttons, tag._name);
				buttons.append(radio);
				b.add(radio);
			}
			var scr = new Gtk.ScrolledWindow(null, null);
			scr.add(b);
			this.get_content_area().pack_start(scr, true, true, 2);
			this.show_all();
		}
	}
}
