namespace LFinance {
	internal class AccountInfo : Gtk.Box {
		Model model;
		// The info is composed like this:
		// A GtkNotebook consisting of an Overview page, that
		// just gives some stats, allows editing the name and exporting to LaTeX
		// The second page is the list of expenses and button to add a new expense
		// The third page is with diagrams
		Gtk.Notebook notebook;
		Account? to_render;
		Overview? overview;
		ExpenseList? expenses;

		internal AccountInfo(Model model) {
			this.model = model;
			this.overview = null;
			this.expenses = null;
			if(this.model._accounts.size == 0) {
				return;
			}
			this.to_render = this.model._accounts[0];
		}
		internal void select(string? account_name) {
			if(account_name != null) {
				this.to_render = this.model.search_account (account_name);
			}
			if(account_name == null || this.to_render == null) {
				this.rebuild (null);
				return;
			}
			if(this.overview == null) {
				this.overview = new Overview (this.model, this.to_render);
				this.notebook.append_page (this.overview, new Gtk.Label (_("Overview")));
				this.show_all ();
			}
			if(this.expenses == null) {
				this.expenses = new ExpenseList (this.model, this.to_render);
				this.notebook.append_page (this.expenses, new Gtk.Label (_("Expenses")));
				this.show_all ();
			}
			this.overview.select (this.to_render);
			this.expenses.select (this.to_render);
			Gdk.threads_add_idle_full (Priority.HIGH_IDLE + 20,
						   () => {
				this.show_all ();
				return false;
			});
		}

		internal void rebuild(TriggerType? type) {
			if(type == null) {
				this.notebook = new Gtk.Notebook ();
				this.pack_start (this.notebook, true, true, 2);
				if(this.model._accounts.size == 0) {
					var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
					var lbl = new Gtk.Label (_("Create an account…"));
					var btn = new Gtk.Button.with_label(_("…or create sample data to explore LFinance!"));
					btn.clicked.connect(() => {
						model.fill_sample_data();
					});
					box.pack_start(lbl, false, false, 2);
					box.pack_start(btn, false, false, 2);
					this.notebook.append_page (box, new Gtk.Label (""));
					return;
				}
				// Account was deleted
				if(!this.model.has_account (this.to_render) || this.to_render == null) {
					// Just use the first account we can find
					this.to_render = this.model._accounts[0];
				}
				this.overview = new Overview (this.model, this.to_render);
				this.notebook.append_page (this.overview, new Gtk.Label (_("Overview")));
				this.expenses = new ExpenseList (this.model, this.to_render);
				this.notebook.append_page (this.expenses, new Gtk.Label (_("Expenses")));
			} else if(type == TriggerType.ADD_TAG || type == TriggerType.DELETE_TAG ||
				  type == TriggerType.EDIT_TAG) {
				// Only the expenses deal with tags
				if(this.expenses != null)
					this.expenses.rebuild (type);
			} else if(type == TriggerType.ADD_LOCATION || type == TriggerType.DELETE_LOCATION ||
				  type == TriggerType.EDIT_LOCATION) {
				if(this.expenses != null)
					this.expenses.rebuild (type);
			} else if(type == TriggerType.ADD_EXPENSE || type == TriggerType.DELETE_EXPENSE ||
				  type == TriggerType.EDIT_EXPENSE) {
				  if(this.overview != null)
				this.overview.rebuild (type);
				if(this.expenses != null)
					this.expenses.rebuild (type);
			} else if(type == TriggerType.DELETE_ACCOUNT) {
				// Account was deleted
				if(!this.model.has_account (this.to_render)) {
					if(this.model._accounts.size > 0) {
						this.select (this.model._accounts[0]._name);
					}
					else {
						this.remove (this.notebook);
						this.to_render = null;
						this.select (null);
					}
					return;
				}
			} else if(type == TriggerType.ADD_ACCOUNT) {
				if(this.model._accounts.size == 1) {
					this.to_render = this.model._accounts[0];
					this.remove (this.notebook);
					this.rebuild (null);
					if(this.overview != null)
						this.overview.select (this.to_render);
					if(this.expenses != null)
						this.expenses.select (this.to_render);
				}
			} else {
				info ("Unknown type, ignoring in AccountInfo: %s", type.to_string ());
				this.overview.rebuild (type);
				this.expenses.rebuild (type);
			}
		}
	}
}
