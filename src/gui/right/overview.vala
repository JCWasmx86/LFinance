namespace MoneyWatch {
	internal class Overview : ScrollBox {
		// Gtk.Entry with the name On double click: editable=true, can_focus = true,
		// else editable = false, can_focus = false/true (TODO)
		// Number of expenses total + amount
		// Number of expenses last month + amount
		// Number of expenses last week + amount
		// Number of expenses last year + amount
		internal Overview(Model model, Account to_render) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
		}
		internal void rebuild() {
			
		}
		internal void select(Account to_render) {
			
		}
	}
}
