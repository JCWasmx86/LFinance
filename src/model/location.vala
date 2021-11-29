namespace LFinance {
	internal class Location {
		internal string _name{internal get; internal set;}
		internal string? _city{internal get; internal set;}
		internal string? _further_info{internal get; internal set;}

		bool sharp;
		TriggerFunc func;

		internal Location(string name, string? city, string? info) {
			this._name = name;
			this._city = city;
			this._further_info = info == null ? "" : info;
			this.sharp = false;
			this.func = t => {};
		}
		internal void set_name(string name) {
			this._name = name;
			this.fire(TriggerType.EDIT_LOCATION);
		}
		internal void set_city(string? city) {
			this._city = city;
			this.fire(TriggerType.EDIT_LOCATION);
		}
		internal void set_info(string? info) {
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
		internal string id_string() {
			if(this._city == null || this._city == "" || this._city.length == 0)
				return this._name;
			return this._name + ",\u00a0" + this._city;
		}
		internal Json.Node serialize() {
			var builder = new Json.Builder();
			builder.begin_object();
			builder.set_member_name("name");
			builder.add_string_value(this._name);
			builder.set_member_name("city");
			builder.add_string_value(this._city);
			builder.set_member_name("info");
			builder.add_string_value(this._further_info);
			builder.end_object();
			return builder.get_root();
		}
	}
}
