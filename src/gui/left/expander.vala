namespace LFinance {
	internal class Expander : Gtk.Expander {
		TreeViewWithAction treeView;

		internal Expander(string s, ActionHandler handler, string type = "text", bool editable = true) {
			Object(label: s);
			this.treeView = new TreeViewWithAction(s, handler, type, editable);
			this.add(this.treeView);
		}
		internal void append_string(string val, string shadow = "") {
			this.treeView.append_string(val, shadow == null ? "" : shadow);
		}
		internal void clear() {
			this.treeView.clear();
		}
	}
}
