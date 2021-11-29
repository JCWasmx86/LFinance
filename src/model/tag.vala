namespace LFinance {
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
		internal Json.Node serialize() {
			var builder = new Json.Builder();
			builder.begin_object();
			builder.set_member_name("name");
			builder.add_string_value(this._name);
			builder.set_member_name("color");
			builder.begin_array();
			for(var i = 0; i < 4; i++) {
				builder.add_int_value(this._rgba[i]);
			}
			builder.end_array();
			builder.end_object();
			return builder.get_root();
		}
	}
}
