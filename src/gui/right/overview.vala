namespace MoneyWatch {
	internal class Overview : ScrollBox {
		Account account;
		string old_name;
		// Number of expenses total + amount
		// Number of expenses last month + amount
		// Number of expenses last week + amount
		// Number of expenses last year + amount
		Gtk.Box first_line;
		Gtk.Entry name_entry;
		Gtk.Button btn;
		Gtk.Button reset;
		bool is_editing;
		Gtk.ListStore store;
		Gtk.TreeView stats;

		internal Overview(Model model, Account to_render) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.account = to_render;
			this.old_name = this.account._name;
			this.first_line = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.name_entry = new Gtk.Entry();
			this.name_entry.set_text(this.account._name);
			this.btn = new Gtk.Button.with_label(_("Edit"));
			this.btn.clicked.connect(() => {
				if(this.is_editing) {
					this.account.set_name(this.name_entry.buffer.text);
					this.old_name = this.name_entry.buffer.text;
					this.btn.set_label(_("Edit"));
					this.btn.set_sensitive(true);
					this.first_line.remove(this.reset);
					this.name_entry.editable = false;
					this.name_entry.can_focus = false;
					this.is_editing = false;
				} else {
					this.btn.set_label(_("Save"));
					this.btn.set_sensitive(false);
					this.name_entry.editable = true;
					this.name_entry.can_focus = true;
					this.is_editing = true;
					this.first_line.pack_start(this.reset, false, false, 2);
					this.show_all();
				}
			});
			this.name_entry.changed.connect(() => {
				var text = this.name_entry.buffer.text;
				if(text == "" || (model.search_account(text) != null && text != this.old_name)) {
					this.btn.set_sensitive(false);
				} else {
					this.btn.set_sensitive(true);
				}
			});
			this.reset = new Gtk.Button.with_label(_("Reset"));
			reset.get_style_context().add_class("destructive-action");
			this.reset.clicked.connect(() => {
				this.name_entry.set_text(this.account._name);
				this.account.set_name(this.name_entry.buffer.text);
				this.btn.set_label(_("Edit"));
				this.btn.set_sensitive(true);
				this.first_line.remove(this.reset);
				this.name_entry.editable = false;
				this.name_entry.can_focus = false;
				this.is_editing = false;
			});
			this.first_line.pack_start(this.name_entry, true, true, 2);
			this.first_line.pack_start(this.btn, false, false, 2);
			this.pack_start(this.first_line, false, false, 2);
			this.store = new Gtk.ListStore(4, GLib.Type.STRING, GLib.Type.STRING, GLib.Type.STRING, GLib.Type.STRING);
			var time = new Gtk.TreeViewColumn.with_attributes(_("Timespan"), new Gtk.CellRendererText(), "text", 0, null);
			var nExpenses = new Gtk.TreeViewColumn.with_attributes(_("Number of Expenses"), new Gtk.CellRendererText(), "text", 1, null);
			var average = new Gtk.TreeViewColumn.with_attributes(_("Average Amount"), new Gtk.CellRendererText(), "text", 2, null);
			var total = new Gtk.TreeViewColumn.with_attributes(_("Total Amount"), new Gtk.CellRendererText(), "text", 3, null);
			this.stats = new Gtk.TreeView.with_model(this.store);
			this.stats.append_column(time);
			this.stats.append_column(nExpenses);
			this.stats.append_column(average);
			this.stats.append_column(total);
			this.populate_stats();
			this.pack_start(this.stats, true, true, 2);
			this.name_entry.editable = false;
			this.name_entry.can_focus = false;
			this.show_all();
		}
		void populate_stats() {
			this.store.clear();
			Gtk.TreeIter iter;
			var current_date = new DateTime.now_local();
			var last = this.account._expenses;
			this.insert(_("Total time"), out iter, last);
			last = this.account.expenses_after(current_date.add_weeks(-1));
			this.insert(_("Last week"), out iter, last);
			last = this.account.expenses_after(current_date.add_months(-1));
			this.insert(_("Last month"), out iter, last);
			last = this.account.expenses_after(current_date.add_years(-1));
			this.insert(_("Last year"), out iter, last);
			this.stats.model = this.store;
		}
		void insert(string time, out Gtk.TreeIter iter, Gee.List<Expense> expenses) {
			var n = expenses.size;
			var sum = 0.0;
			var hash_map = new Gee.HashMap<string, uint64?>();
			foreach(var expense in expenses) {
				sum += expense._amount;
				if(expense._currency in hash_map) {
					hash_map[expense._currency] = hash_map[expense._currency] + 1;
				} else {
					hash_map[expense._currency] = 1;
				}
			}
			var most_used = (uint64)0;
			var currency = "€";
			foreach(var pair in hash_map.entries) {
				if(pair.@value > most_used) {
					currency = pair.key;
					most_used = pair.@value;
				}
			}
			var average = (n == 0) ? 0 : (sum / n);
			average /= 100.0;
			sum /= 100.0;
			var val1 = Value(typeof(string));
			var val2 = Value(typeof(string));
			var val3 = Value(typeof(string));
			var val4 = Value(typeof(string));
			val1.set_string(time);
			val2.set_string("%u".printf(n));
			val3.set_string("%s%.2lf".printf(currency, average));
			val4.set_string("%s%.2lf".printf(currency, sum));
			this.store.insert_with_valuesv(out iter, -1, new int[]{0, 1, 2, 3}, new Value[]{val1, val2, val3, val4});
		}
		internal void rebuild() {
			if(this.old_name != this.account._name && this.is_editing) {
				this.name_entry.set_text(this.account._name);
				this.btn.set_label(_("Edit"));
				this.first_line.remove(this.reset);
				this.name_entry.editable = false;
				this.name_entry.can_focus = false;
				this.is_editing = false;
			} else if(this.old_name != this.account._name) {
				this.name_entry.set_text(this.account._name);
			}
			this.old_name = this.account._name;
			this.populate_stats();
		}
		internal void select(Account to_render) {
			this.account = to_render;
			this.rebuild();
		}
	}
}
