namespace LFinance {
	internal class CustomColorButton : ColoredRadioButton, Gtk.RadioButton {
		string color;
		internal CustomColorButton(Gee.List<ColoredRadioButton> list) {
			Object(group: null);
			this.label = _("Select your own color");
			this.color = "#FFFFFF";
		}
		internal string get_color() {
			return this.color;
		}
		internal void set_color(string color) {
			this.color = color;
			if(this.get_child() is Gtk.Label) {
				((Gtk.Label)this.get_child()).set_markup("<b><span color=\"%s\">%s</span></b>".printf(color, _("Select your own color")));
			}
		}
		internal void set_text(string text) {
			
		}
	}
}
