namespace LFinance {
	internal class TagEditDialog : Gtk.Dialog {
		Gtk.Entry name_entry;
		Gtk.ColorButton button;

		internal TagEditDialog(Tag tag, Model model) {
			this.title = _("Edit tag");
			this.name_entry = new Gtk.Entry();
			this.name_entry.buffer.set_text(tag._name.data);
			this.button = new Gtk.ColorButton();
			this.button.set_rgba(Gdk.RGBA(){
				red = tag._rgba[0] / 255.0,
				green = tag._rgba[1] / 255.0,
				blue = tag._rgba[2] / 255.0,
				alpha = tag._rgba[3] / 255.0
			});
			this.get_content_area().pack_start(this.name_entry, true, false, 2);
			this.get_content_area().pack_start(this.button, true, false, 2);
			this.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("_Edit"), Gtk.ResponseType.OK);
			this.show_all();
		}
		internal string get_new_name() {
			return this.name_entry.buffer.text;
		}
		internal uint8[] get_rgba() {
			var rgba = this.button.get_rgba();
			return new uint8[]{(uint8)(rgba.red * 255), (uint8)(rgba.green * 255), (uint8)(rgba.blue * 255), (uint8)(rgba.alpha *255)};
		}
	}
}
