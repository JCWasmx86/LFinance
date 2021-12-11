namespace LFinance {
	interface ActionHandler : Object {
		// If true, accept the change, else reject
		internal abstract bool handle_edit(string old, string @new, out string replacement);
		internal abstract void handle_mouse_press(string selected, Gdk.EventButton event);
		internal abstract void handle_key_press(string selected, Gdk.EventKey key);
	}
}
