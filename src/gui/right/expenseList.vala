namespace MoneyWatch {
	internal class ExpenseList : ScrollBox {
		// [SortingOrder]
		// [Searchbar with extra options]
		// [Expenselist]
		// [Add new expense]
		Model model;
		Account account;

		Gtk.Box header;
		Gtk.Label header_sort_label;
		Gtk.ComboBoxText header_sorting;
		Gtk.Box searchbar;
		Gtk.Box expenses;
		Gee.List<ExpenseWidget> widgets;

		internal ExpenseList(Model model, Account account) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			this.account = account;
			this.widgets = new Gee.ArrayList<ExpenseWidget>();
			this.header = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.header_sort_label = new Gtk.Label(_("Sort by:"));
			this.header_sorting = new Gtk.ComboBoxText();
			this.header_sorting.append("1", _("Amount"));
			this.header_sorting.append("2", _("Purpose"));
			this.header_sorting.append("3", _("Date"));
			this.header_sorting.append("4", _("Amount (Descending"));
			this.header_sorting.append("5", _("Purpose (Descending)"));
			this.header_sorting.append("6", _("Date (Descending)"));
			this.header_sorting.active_id = "%u".printf(account._sorting);
			this.header_sorting.changed.connect(() => {
				uint sorting = 0;
				this.header_sorting.active_id.scanf("%u", out sorting);
				this.account.set_sorting(sorting);
			});
			this.header.pack_start(this.header_sort_label, false, false, 2);
			this.header.pack_start(this.header_sorting, true, true, 2);
			this.pack_start(this.header, false, true, 2);
			this.expenses = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			foreach(var expense in this.account._expenses) {
				var widget = new ExpenseWidget(this.model, this.account, expense);
				this.widgets.add(widget);
				this.expenses.pack_start(widget, false, true, 2);
			}
			this.pack_start(this.expenses, false, true, 2);
		}
		internal void rebuild() {
			this.header_sorting.active_id = "%u".printf(account._sorting);
			this.widgets.foreach(a => {
				expenses.remove(a);
				return true;
			});
			this.widgets = new Gee.ArrayList<ExpenseWidget>();
			foreach(var expense in this.account._expenses) {
				var widget = new ExpenseWidget(this.model, this.account, expense);
				this.widgets.add(widget);
				this.expenses.pack_start(widget, false, true, 2);
			}
		}
		internal void select(Account to_render) {
			this.account = to_render;
		}
	}
}
