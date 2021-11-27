namespace MoneyWatch {
	internal class ScrollBox : Gtk.ScrolledWindow {
		public Gtk.Orientation orientation{get; set construct;}
		public int spacing{get; set construct;}
		protected Gtk.Box box;
		internal ScrollBox(Gtk.Orientation orientation, int spacing) {
			this.box = new Gtk.Box(orientation, spacing);
			this.add(this.box);
		}
		internal void pack_start(Gtk.Widget child, bool expand = true, bool fill = true, uint padding = 0) {
			if(this.box == null) {
				this.box = new Gtk.Box(orientation, spacing);
				this.add(this.box);
			}
			this.box.pack_start(child, expand, fill, padding);
		}
	}
}
