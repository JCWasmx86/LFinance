namespace MoneyWatch {
	internal delegate void TriggerFunc();
	
	internal class Tag {
		internal string _name{internal get; private set;}
		uint8[] _rgba;

		bool sharp;
		TriggerFunc func;

		internal Tag(string name, uint8[] rgba) {
			this.sharp = false;
			this._name = name;
			this._rgba = rgba;
			this.sharp = false;
			this.func = () => {};
		}
		internal void set_name(string s) {
			this._name = s;
			this.fire();
		}
		internal void set_rgba(uint8[] rgba) {
			this._rgba = rgba;
			this.fire();
		}
		internal void fire() {
			if(!this.sharp || this.func == null)
				return;
			this.func();
		}
	}

	internal class Location {
		internal string _name{internal get; private set;}
		string _city;
		string _further_info;

		bool sharp;
		TriggerFunc func;

		internal Location(string name, string city, string info) {
			this._name = name;
			this._city = city;
			this._further_info = info;
			this.sharp = false;
			this.func = () => {};
		}
		internal void set_name(string name) {
			this._name = name;
			this.fire();
		}
		internal void set_city(string city) {
			this._city = city;
			this.fire();
		}
		internal void set_info(string info) {
			this._further_info = info;
			this.fire();
		}
		internal void fire() {
			if(!this.sharp || this.func == null)
				return;
			this.func();
		}
	}
	internal class Expense {
		string _purpose;
		uint64 _amount;
		string _currency;
		DateTime _date;
		Location _location;
		Gee.List<Tag> _tags;

		bool sharp;
		TriggerFunc func;

		internal Expense(string purpose) {
			this._purpose = purpose;
			this._tags = new Gee.ArrayList<Tag>();
			this.sharp = false;
			this.func = () => {};
		}
		internal void set_purpose(string purpose) {
			this._purpose = purpose;
			this.fire();
		}
		internal void set_amount(uint64 amount) {
			this._amount = amount;
			this.fire();
		}
		internal void set_currency(string currency) {
			this._currency = currency;
			this.fire();
		}
		internal void set_date(DateTime date) {
			this._date = date;
			this.fire();
		}
		internal void set_location(Location location) {
			this._location = location;
			this.fire();
		}
		internal void add_tag(Tag t) {
			this._tags.add(t);
			this.fire();
		}
		internal void fire() {
			if(!this.sharp || this.func == null)
				return;
			this.func();
		}
	}

	internal class Account {
		string _name;
		uint _sorting;
		Gee.List<Expense> _expenses;

		bool sharp;
		TriggerFunc func;

		internal Account(string name) {
			this._name = name;
			this._expenses = new Gee.ArrayList<Expense>();
			sharp = false;
			func = () => {};
		}
		internal void set_name(string name) {
			this._name = name;
			this.fire();
		}
		internal void set_sorting(uint sorting) {
			this._sorting = sorting;
			this.fire();
		}
		internal void add_expense(Expense expense) {
			this._expenses.add(expense);
			this.fire();
		}
		internal void fire() {
			if(!this.sharp || this.func == null)
				return;
			this.func();
		}
	}

	internal class Model {
		Gee.List<Tag> _tags;
		Gee.List<Location> _locations;
		Gee.List<Account> _accounts;

		bool sharp;
		TriggerFunc func;

		internal Model() {
			this._tags = new Gee.ArrayList<Tag>();
			this._locations = new Gee.ArrayList<Location>();
			this._accounts = new Gee.ArrayList<Account>();
			this.sharp = false;
			this.func = () => {};
		}

		internal void add_tag(Tag tag) {
			this._tags.add(tag);
			this.fire();
		}
		internal void add_location(Location location) {
			this._locations.add(location);
			this.fire();
		}
		internal void add_account(Account account) {
			this._accounts.add(account);
			this.fire();
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
		internal void fire() {
			if(!this.sharp || this.func == null)
				return;
			this.func();
		}
	}
}
