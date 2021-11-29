namespace LFinance {
	internal class CreateExpense : Gtk.Box {
		Model model;
		Account account;
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

		internal CreateExpense(Account account, Model model) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			this.account = account;
			this.build_gui();
			this.connect_signals();
		}
		void build_gui() {
			this.build_first_line();
			this.build_calendar();
			this.build_tags_window();
			this.build_buttons();
			this.show_all();
		}

		void build_buttons() {
			this.buttons = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.add_btn = new Gtk.Button.with_label(_("Add"));
			this.add_btn.set_sensitive(false);
			this.reset = new Gtk.Button.with_label(_("Reset"));
			this.buttons.pack_start(this.add_btn, true, true, 2);
			this.buttons.pack_start(this.reset, true, true, 2);
			this.pack_start(this.buttons, true, true, 2);
		}

		void build_tags_window() {
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
			this.pack_start(this.tags_scw, true, true, 2);
		}

		void build_calendar() {
			this.calendar = new Gtk.Calendar();
			this.pack_start(this.calendar, true, true, 2);
		}

		void build_first_line() {
			this.first_line = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.purpose_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.purpose_label = new Gtk.Label(_("Purpose:"));
			this.purpose = new Gtk.Entry();
			this.purpose_box.pack_start(this.purpose_label, false, true, 2);
			this.purpose_box.pack_start(this.purpose, true, true, 2);
			this.first_line.pack_start(this.purpose_box, true, true, 2);
			this.amount_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.amount_label = new Gtk.Label(_("Amount:"));
			this.amount = new Gtk.Entry();
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
			this.pack_start(this.first_line, true, true, 2);
		}

		void connect_signals() {
			this.add_btn.clicked.connect(() => {
				this.add_expense();
				this.reset_all();
			});
			this.reset.clicked.connect(() => {
				this.reset_all();
			});
			this.purpose.changed.connect(() => {
				this.edited();
			});
			this.amount.changed.connect(() => {
				this.edited();
			});
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
