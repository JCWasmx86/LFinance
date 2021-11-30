namespace LFinance {
	internal class AccountInfo : Gtk.Box {
		Model model;
		// The info is composed like this:
		// A GtkNotebook consisting of an Overview page, that
		// just gives some stats, allows editing the name and exporting to LaTeX
		// The second page is the list of expenses and button to add a new expense
		// The third page is with diagrams
		Gtk.Notebook notebook;
		Account to_render;
		Overview overview;
		ExpenseList expenses;

		internal AccountInfo(Model model) {
			this.model = model;
			if(model._accounts.size == 0)
				return;
			this.to_render = model._accounts[0];
		}
		internal void select(string account_name) {
			this.to_render = this.model.search_account(account_name);
			this.overview.select(this.to_render);
			this.expenses.select(this.to_render);
			Gdk.threads_add_idle_full(GLib.Priority.HIGH_IDLE + 20, () => {
				this.show_all();
				return false;
			});
		}

		internal void rebuild(TriggerType? type) {
			if(type == null) {
				this.notebook = new Gtk.Notebook();
				this.pack_start(this.notebook, true, true, 2);
				if(this.model._accounts.size == 0)
					return;
				// Account was deleted
				if(!this.model.has_account(this.to_render)) {
					// Just use the first account we can find
					this.select(this.model._accounts[0]._name);
					return;
				}
				this.overview = new Overview(this.model, this.to_render);
				this.notebook.append_page(this.overview, new Gtk.Label(_("Overview")));
				this.expenses = new ExpenseList(this.model, this.to_render);
				this.notebook.append_page(this.expenses, new Gtk.Label(_("Expenses")));
			} else if(type == TriggerType.ADD_TAG || type == TriggerType.DELETE_TAG || type == TriggerType.EDIT_TAG) {
				// Only the expenses deal with tags
				this.expenses.rebuild(type);
			} else if(type == TriggerType.ADD_LOCATION || type == TriggerType.DELETE_LOCATION || type == TriggerType.EDIT_LOCATION) {
				this.expenses.rebuild(type);
			} else if(type == TriggerType.ADD_EXPENSE || type == TriggerType.DELETE_EXPENSE || type == TriggerType.EDIT_EXPENSE) {
				this.overview.rebuild(type);
				this.expenses.rebuild(type);
			} else {
				info("Unknown type, ignoring in AccountInfo: %s", type.to_string());
				this.overview.rebuild(type);
				this.expenses.rebuild(type);
			}
		}
	}
}
