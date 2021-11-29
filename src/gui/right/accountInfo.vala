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
				this.rebuild();
				this.show_all();
				return false;
			});
		}

		internal void rebuild() {
			if(this.notebook == null) {
				this.notebook = new Gtk.Notebook();
				this.pack_start(this.notebook, true, true, 2);
			}
			if(this.model._accounts.size == 0)
				return;
			// Account was deleted
			if(!this.model.has_account(this.to_render)) {
				// Just use the first account we can find
				this.select(this.model._accounts[0]._name);
				return;
			}
			if(this.overview == null) {
				this.overview = new Overview(this.model, this.to_render);
				this.notebook.append_page(this.overview, new Gtk.Label(_("Overview")));
			} else {
				this.overview.rebuild();
			}
			if(this.expenses == null) {
				this.expenses = new ExpenseList(this.model, this.to_render);
				this.notebook.append_page(this.expenses, new Gtk.Label(_("Expenses")));
			} else {
				this.expenses.rebuild();
			}
		}
	}
}
