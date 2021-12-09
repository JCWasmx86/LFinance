namespace LFinance {
	internal class Expense {
		internal string _purpose;
		internal uint64 _amount;
		internal string _currency;
		internal DateTime _date;
		internal Location? _location;
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
		internal void set_location(Location? location) {
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
		internal void begin_edits() {
			this.sharp = false;
		}
		internal void end_edits() {
			this.sharp = true;
			this._tags.sort((a, b) => {
				return a._name.collate(b._name);
			});
			this.fire(TriggerType.EDIT_EXPENSE);
		}
		internal Tag? search_tag(string name) {
			foreach(var t in this._tags) {
				if(name == t._name)
					return t;
			}
			return null;
		}

		internal string format_amount() {
		    if(this._currency == "€")
		        return "%.2f\u202f%s".printf(this._amount / 100.0, this._currency);
			// Invisible space as a fancy marker
			return "%s\u202f%.2f".printf(this._currency, this._amount / 100.0);
		}
		internal string format() {
			// TODO: Some currencies don't have basic units or a different
			// rate.
			// https://github.com/ourworldincode/currency/blob/main/currencies.json
			var amount_string = "%s\u202f%.2f".printf(this._currency, this._amount / 100.0);
			// TODO: Align the three-em dashes
			return _("%s \u2e3b %s \u2e3b %s").printf(this._purpose, this._date.format("%x"), amount_string);
		}
		internal Json.Node serialize() {	
			var builder = new Json.Builder();
			builder.begin_object();
			builder.set_member_name("purpose");
			builder.add_string_value(this._purpose);
			builder.set_member_name("amount");
			builder.add_int_value((int64)this._amount);
			builder.set_member_name("currency");
			builder.add_string_value(this._currency);
			builder.set_member_name("date");
			builder.begin_object();
			builder.set_member_name("year");
			builder.add_int_value(this._date.get_year());
			builder.set_member_name("month");
			builder.add_int_value(this._date.get_month());
			builder.set_member_name("day");
			builder.add_int_value(this._date.get_day_of_month());
			builder.end_object();
			builder.set_member_name("location");
			builder.add_string_value(this._location == null ? "" : this._location._name);
			builder.set_member_name("location_city");
			builder.add_string_value(this._location == null ? "" : (this._location._city == null ? "" : this._location._city));
			builder.set_member_name("tags");
			builder.begin_array();
			foreach(var t in this._tags) {
				builder.add_string_value(t._name);
			}
			builder.end_array();
			builder.end_object();
			return builder.get_root();
		}
	}
}
