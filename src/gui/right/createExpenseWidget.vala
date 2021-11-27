namespace MoneyWatch {
	internal class CreateExpenseWidget : Gtk.Expander {
		CreateExpense ce;

		internal CreateExpenseWidget(Account account, Model model) {
			this.label = _("Add Expense");
			this.ce = new CreateExpense(account, model);
			this.add(ce);
			this.show_all();
		}
		internal void select(Account account) {
			this.ce.select(account);
		}
	}
}
