namespace MoneyWatch {
	internal class Account {
		internal string _name{internal get; private set;}
		internal uint _sorting{internal get; private set;}
		internal Gee.List<Expense> _expenses{internal get; private set;}

		bool sharp;
		unowned TriggerFunc func;

		internal Account(string name) {
			this._name = name;
			this._expenses = new Gee.ArrayList<Expense>();
			sharp = false;
			func = null;
		}
		internal void set_name(string name) {
			this._name = name;
			this.fire(TriggerType.EDIT_ACCOUNT);
		}
		internal void set_sorting(uint sorting) {
			this._sorting = sorting;
			this.sort(false);
			this.fire(TriggerType.EDIT_ACCOUNT);
		}
		internal void add_expense(Expense expense) {
			this._expenses.add(expense);
			this.fire(TriggerType.EDIT_ACCOUNT);
		}
		internal void fire(TriggerType type) {
			if((!this.sharp) || this.func == null)
				return;
			this.func(type);
		}
		internal void delete_expense(Expense expense) {
			this._expenses.remove(expense);
			this.fire(TriggerType.EDIT_ACCOUNT);
		}

		internal void set_sharp(TriggerFunc func) {
			this.func = func;
			this.sharp = true;
			this._expenses.foreach(a => {
				a.set_sharp(func);
				return true;
			});
		}
		internal void sort(bool sort_expenses = true) {
			this._expenses.sort((a,b) => {
				switch(this._sorting) {
					case 1:
						return a._amount > b._amount ? 1 : (a._amount == b._amount ? 0 : -1);
					case 2:
						return a._purpose.collate(b._purpose);
					case 3:
						return a._date.compare(b._date);
					case 4:
						return a._amount > b._amount ? -1 : (a._amount == b._amount ? 0 : 1);
					case 5:
						return b._purpose.collate(a._purpose);
					case 6:
						return b._date.compare(a._date);
				}
				return 0;
			});
			if(sort_expenses) {
				this._expenses.foreach(a => {
					a.sort();
					return true;
				});
			}
			this.fire(TriggerType.ACCOUNT_EXPENSES_SORT);
		}
		internal Json.Node serialize() {
			var builder = new Json.Builder();
			builder.begin_object();
			builder.set_member_name("name");
			builder.add_string_value(this._name);
			builder.set_member_name("sorting");
			builder.add_int_value(this._sorting);
			builder.set_member_name("expenses");
			builder.begin_array();
			foreach(var expense in this._expenses) {
				builder.add_value(expense.serialize());
			}
			builder.end_array();
			builder.end_object();
			return builder.get_root();
		}
	}
}