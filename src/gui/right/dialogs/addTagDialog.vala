namespace LFinance {
	internal class AddTagDialog : Gtk.Dialog {
		Model model;

		Gee.List<ExtendedTagButton> tags;
		internal unowned SList<Gtk.RadioButton> buttons{internal get; private set;}

		internal AddTagDialog(Model model, Gee.List<ExtendedTagButton> tags) {
			this.title = _("Add tag");
			this.model = model;
			this.tags = tags;
			this.build_gui();
			this.show_all();
		}
		void build_gui() {
			this.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("Add Tag"), Gtk.ResponseType.OK);
			var b = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			this.buttons = new SList<Gtk.RadioButton>();
			foreach(var tag in this.model._tags) {
				bool found = false;
				foreach(var btn in this.tags) {
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
