namespace LFinance {
	internal class TagButton : Gtk.Label {
		internal Tag tag;
		string old_markup;
		internal TagButton(Tag t) {
			this.tag = t;
			var colors = t._rgba;
			this.old_markup = "<b><span foreground=\"#%02x%02x%02x%02x\" >%s</span></b>".printf (colors[0],
													     colors[1],
													     colors[2],
													     colors[3],
													     this.tag._name);
			this.set_markup (this.old_markup);
			this.get_style_context ().add_class ("circular");
		}
		internal void rebuild_if_necessary() {
			var colors = this.tag._rgba;
			var new_markup = "<b><span foreground=\"#%02x%02x%02x%02x\" >%s</span></b>".printf (colors[0],
													    colors[1],
													    colors[2],
													    colors[3],
													    this.tag._name);
			if(new_markup != this.old_markup) {
				this.set_markup (new_markup);
				this.old_markup = new_markup;
			}
		}
	}
}
