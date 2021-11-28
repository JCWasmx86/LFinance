namespace MoneyWatch {
	internal class TagButton : Gtk.Label {
		Tag tag;
		internal TagButton(Tag t) {
			this.tag = t;
			var colors = t._rgba;
			this.set_markup("<b><span foreground=\"#%02x%02x%02x%02x\" >%s</span></b>".printf(colors[0], colors[1], colors[2], colors[3], this.tag._name));
			this.get_style_context().add_class("circular");
		}
	}
}
