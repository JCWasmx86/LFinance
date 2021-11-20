namespace MoneyWatch {
	internal delegate void TriggerFunc(TriggerType type);
	
	internal class Tag {
		internal string _name{internal get; private set;}
		internal uint8[] _rgba{internal get; private set;}

		bool sharp;
		TriggerFunc func;

		internal Tag(string name, uint8[] rgba) {
			this.sharp = false;
			this._name = name;
			this._rgba = rgba;
			this.sharp = false;
			this.func = t => {};
		}
		internal void set_name(string s) {
			this._name = s;
			this.fire(TriggerType.EDIT_TAG);
		}
		internal void set_rgba(uint8[] rgba) {
			this._rgba = rgba;
			this.fire(TriggerType.EDIT_TAG);
		}
		internal void fire(TriggerType type) {
			if(!this.sharp || this.func == null)
				return;
			this.func(type);
		}
		internal void set_sharp(owned TriggerFunc func) {
			this.func = (owned)func;
			this.sharp = true;
		}
	}

	internal class Location {
		internal string _name{internal get; private set;}
		internal string _city{internal get; private set;}
		string _further_info;

		bool sharp;
		TriggerFunc func;

		internal Location(string name, string city, string info) {
			this._name = name;
			this._city = city;
			this._further_info = info;
			this.sharp = false;
			this.func = t => {};
		}
		internal void set_name(string name) {
			this._name = name;
			this.fire(TriggerType.EDIT_LOCATION);
		}
		internal void set_city(string city) {
			this._city = city;
			this.fire(TriggerType.EDIT_LOCATION);
		}
		internal void set_info(string info) {
			this._further_info = info;
			this.fire(TriggerType.EDIT_LOCATION);
		}
		internal void fire(TriggerType type) {
			if(!this.sharp || this.func == null)
				return;
			this.func(type);
		}
		internal void set_sharp(owned TriggerFunc func) {
			this.func = (owned)func;
			this.sharp = true;
		}
	}
	internal class Expense {
		internal string _purpose;
		internal uint64 _amount;
		internal string _currency;
		internal DateTime _date;
		internal Location _location;
		internal Gee.List<Tag> _tags;

		bool sharp;
		TriggerFunc func;

		internal Expense(string purpose) {
			this._purpose = purpose;
			this._tags = new Gee.ArrayList<Tag>();
			this.sharp = false;
			this.func = t => {};
		}
		internal void set_purpose(string purpose) {
			this._purpose = purpose;
			this.fire(TriggerType.EDIT_EXPENSE);
		}
		internal void set_amount(uint64 amount) {
			this._amount = amount;
			this.fire(TriggerType.EDIT_EXPENSE);
		}
		internal void set_currency(string currency) {
			this._currency = currency;
			this.fire(TriggerType.EDIT_EXPENSE);
		}
		internal void set_date(DateTime date) {
			this._date = date;
			this.fire(TriggerType.EDIT_EXPENSE);
		}
		internal void set_location(Location location) {
			this._location = location;
			this.fire(TriggerType.EDIT_EXPENSE);
		}
		internal void add_tag(Tag t) {
			this._tags.add(t);
			this.fire(TriggerType.EDIT_EXPENSE);
		}
		internal void fire(TriggerType type) {
			if(!this.sharp || this.func == null)
				return;
			this.func(type);
		}
		internal void set_sharp(owned TriggerFunc func) {
			this.func = (owned)func;
			this.sharp = true;
		}
		internal void sort() {
			this._tags.sort((a, b) => {
				return a._name.collate(b._name);
			});
			this.fire(TriggerType.EXPENSE_SORT_TAGS);
		}
		internal string format() {
			// TODO: Some currencies don't have basic units or a different
			// rate.
			// https://github.com/ourworldincode/currency/blob/main/currencies.json
			var amount_string = "%s\u202f%.2f".printf(this._currency, this._amount / 100.0);
			// TODO: Align the three-em dashes
			return _("%s \u2e3b %s \u2e3b %s").printf(this._purpose, this._date.format("%x"), amount_string);
		}
	}

	internal class Account {
		internal string _name{internal get; private set;}
		internal uint _sorting{internal get; private set;}
		internal Gee.List<Expense> _expenses{internal get; private set;}

		bool sharp;
		TriggerFunc func;

		internal Account(string name) {
			this._name = name;
			this._expenses = new Gee.ArrayList<Expense>();
			sharp = false;
			func = t => {};
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
			if(!this.sharp || this.func == null)
				return;
			this.func(type);
		}
		internal void set_sharp(owned TriggerFunc func) {
			this.func = (owned)func;
			this.sharp = true;
			this._expenses.foreach(a => {
				a.set_sharp((owned)func);
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
						return a._purpose.collate(b._purpose);
					case 6:
						return a._date.compare(b._date);
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
	}

	internal class Model {
		internal Gee.List<Tag> _tags{internal get; private set;}
		internal Gee.List<Location> _locations{internal get; private set;}
		internal Gee.List<Account> _accounts{internal get; private set;}

		bool sharp;
		TriggerFunc func;

		internal Model() {
			this._tags = new Gee.ArrayList<Tag>();
			this._locations = new Gee.ArrayList<Location>();
			this._accounts = new Gee.ArrayList<Account>();
			this.sharp = false;
			this.func = t => {};
		}

		internal void add_tag(Tag tag) {
			this._tags.add(tag);
			this.fire(TriggerType.ADD_TAG);
		}
		internal void add_location(Location location) {
			this._locations.add(location);
			this.fire(TriggerType.ADD_LOCATION);
		}
		internal void add_account(Account account) {
			this._accounts.add(account);
			this.fire(TriggerType.ADD_ACCOUNT);
		}
		internal Location? search_location(string name) {
			foreach(var l in this._locations) {
				if(name == l._name)
					return l;
			}
			return null;
		}
		internal Tag? search_tag(string name) {
			foreach(var t in this._tags) {
				if(name == t._name)
					return t;
			}
			return null;
		}
		internal void fire(TriggerType type) {
			if(!this.sharp || this.func == null)
				return;
			this.func(type);
		}
		internal void set_sharp(owned TriggerFunc func) {
			this.func = (owned)func;
			this.sharp = true;
			this._tags.foreach(a => {
				a.set_sharp((owned)func);
				return true;
			});
			this._locations.foreach(a => {
				a.set_sharp((owned)func);
				return true;
			});
			this._accounts.foreach(a => {
				a.set_sharp((owned)func);
				return true;
			});
		}
		internal void sort() {
			this._tags.sort((a, b) => {
				return a._name.collate(b._name);
			});
			this._locations.sort((a, b) => {
				return a._name.collate(b._name);
			});
			this._accounts.sort((a, b) => {
				return a._name.collate(b._name);
			});
			this._accounts.foreach(a => {
				a.sort();
				return true;
			});
			this.fire(TriggerType.GENERAL);
		}
		internal bool has_account(Account a) {
			foreach(var account in this._accounts)
				if(account._name == a._name)
					return true;
			return false;
		}
	}
	internal enum TriggerType {
		DELETE_TAG, ADD_TAG, DELETE_LOCATION, ADD_LOCATION, DELETE_ACCOUNT, ADD_ACCOUNT, ADD_EXPENSE, DELETE_EXPENSE, ACCOUNT_EXPENSES_SORT, EDIT_TAG,
		EDIT_LOCATION, EDIT_ACCOUNT, EDIT_EXPENSE, EXPENSE_SORT_TAGS, GENERAL;
	}
}
