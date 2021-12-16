namespace LFinance {
	internal class RecommendedColorButton : ColoredRadioButton, Gtk.RadioButton {
		string color;
		internal RecommendedColorButton(string color, Gee.List<ColoredRadioButton> list) {
			Object (group: null, label: "foo");
			this.color = color;
		}
		internal string get_color() {
			return this.color;
		}
		internal void set_text(string text) {
			if(this.get_child () is Gtk.Label) {
				((Gtk.Label) this.get_child ()).set_markup ("<b><span color=\"%s\">%s</span></b>".printf (
										    this.color,
										    text));
			}
		}
	}
}
