namespace LFinance {
	internal class LocationButton : Gtk.Label {
		Location location;

		internal LocationButton(Location l) {
			this.location = l;
			this.label = l.id_string ();
			this.get_style_context ().add_class ("circular");
		}
	}
}
