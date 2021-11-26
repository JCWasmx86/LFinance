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
		CreateExpenseWidget epw;

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
			this.epw = new CreateExpenseWidget(account, model);
			this.pack_start(this.epw, true, true, 2);
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
			this.epw.select(to_render);
		}
	}
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
	internal class CreateExpense : Gtk.Box {
		// [PurposeTextfield+Label] [AmountTextfield+Label] [LocationCombobox]
		// [Calendar]
		// Checkboxes with tags
		// [Add] [Reset]
		Gtk.Box first_line;
		Gtk.Box purpose_box;
		Gtk.Label purpose_label;
		Gtk.Entry purpose;
		Gtk.Box amount_box;
		Gtk.Label amount_label;
		Gtk.Entry amount;
		Gtk.ComboBoxText location;
		Gtk.Calendar calendar;
		Gtk.ScrolledWindow tags_scw;
		Gtk.Box tags_box;
		Gee.List<Gtk.CheckButton> tags;
		Gee.List<string> tag_names;
		Gtk.Box buttons;
		Gtk.Button add_btn;
		Gtk.Button reset;
		Model model;
		Account account;

		internal CreateExpense(Account account, Model model) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			this.account = account;
			this.first_line = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.purpose_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.purpose_label = new Gtk.Label(_("Purpose:"));
			this.purpose = new Gtk.Entry();
			this.purpose.changed.connect(() => {
				this.edited();
			});
			this.purpose_box.pack_start(this.purpose_label, false, true, 2);
			this.purpose_box.pack_start(this.purpose, true, true, 2);
			this.first_line.pack_start(this.purpose_box, true, true, 2);
			this.amount_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.amount_label = new Gtk.Label(_("Amount:"));
			this.amount = new Gtk.Entry();
			this.amount.changed.connect(() => {
				this.edited();
			});
			this.amount_box.pack_start(this.amount_label, false, true, 2);
			this.amount_box.pack_start(this.amount, true, true, 2);
			this.first_line.pack_start(this.amount_box, true, true, 2);
			this.location = new Gtk.ComboBoxText();
			this.location.append("", "");
			foreach(var loc in model._locations) {
				this.location.append(loc.id_string(), loc.id_string());
			}
			this.location.set_active(0); // Default no location
			this.first_line.pack_start(this.location, true, true, 2);
			this.calendar = new Gtk.Calendar();
			this.tags_scw = new Gtk.ScrolledWindow(null, null);
			this.tags_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			this.tags = new Gee.ArrayList<Gtk.CheckButton>();
			this.tag_names = new Gee.ArrayList<string>();
			this.tags_scw.add(tags_box);
			foreach(var tag in model._tags) {
				var c = tag._rgba;
				var markup = "<b><span foreground=\"#%02x%02x%02x%02x\" >%s</span></b>".printf(c[0], c[1], c[2], c[3], tag._name);
				var cb = new Gtk.CheckButton.with_label(markup);
				((Gtk.Label)cb.get_child()).set_markup(markup);
				this.tags_box.pack_start(cb, true, true, 2);
				this.tags.add(cb);
				this.tag_names.add(tag._name);
			}
			this.buttons = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.add_btn = new Gtk.Button.with_label(_("Add"));
			this.add_btn.set_sensitive(false);
			this.add_btn.clicked.connect(() => {
				this.add_expense();
				this.reset_all();
			});
			this.reset = new Gtk.Button.with_label(_("Reset"));
			this.reset.clicked.connect(() => {
				this.reset_all();
			});
			this.buttons.pack_start(this.add_btn, true, true, 2);
			this.buttons.pack_start(this.reset, true, true, 2);
			this.pack_start(this.first_line, true, true, 2);
			this.pack_start(this.calendar, true, true, 2);
			this.pack_start(this.tags_scw, true, true, 2);
			this.pack_start(this.buttons, true, true, 2);
			this.show_all();
		}
		internal void select(Account account) {
			this.account = account;
		}
		void edited() {
			var activate = this.amount.buffer.text.length == 0 || this.purpose.buffer.text.length == 0;
			this.add_btn.set_sensitive(!activate);
			this.add_btn.show_all();
			this.add_btn.queue_draw();
		}
		void add_expense() {
			var expense = new Expense(this.purpose.buffer.text);
			double amount = 0.0;
			this.amount.buffer.text.scanf("%lf", out amount);
			var amount_real = (uint64)(amount * 100);
			expense.set_amount(amount_real);
			if(this.location.get_active_text() != "") {
				expense.set_location(this.model.search_location_by_id(this.location.get_active_text()));
			}
			// TODO: Add combobox for currency
			expense.set_currency("€");
			expense.set_date(new GLib.DateTime.local(this.calendar.year, this.calendar.month + 1, this.calendar.day, 0, 0, 0));
			var idx = 0;
			foreach(var cb in this.tags) {
				if(cb.get_active()) {
					expense.add_tag(model.search_tag(this.tag_names[idx]));
				}
				idx++;
			}
			this.account.add_expense(expense);
		}
		void reset_all() {
			this.purpose.buffer.set_text("".data);
			this.amount.buffer.set_text("".data);
			this.location.set_active(0);
			var date = new GLib.DateTime.now_local();
			this.calendar.select_day(date.get_day_of_month());
			this.calendar.select_month(date.get_month() - 1, date.get_year());
			foreach(var btn in this.tags) {
				btn.set_active(false);
			}
		}
	}
}
