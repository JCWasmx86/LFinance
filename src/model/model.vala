namespace LFinance {
	internal class Model {
		internal Gee.List<Tag> _tags {internal get; private set;}
		internal Gee.List<Location> _locations {internal get; private set;}
		internal Gee.List<Account> _accounts {internal get; private set;}

		bool sharp;
		unowned TriggerFunc func;
		internal bool encrypted {get; private set;}
		internal string password {get; private set;}

		internal Model(bool encrypted = false, string password = "") {
			this._tags = new Gee.ArrayList<Tag>();
			this._locations = new Gee.ArrayList<Location>();
			this._accounts = new Gee.ArrayList<Account>();
			this.sharp = false;
			this.func = t => {};
			this.encrypted = encrypted;
			this.password = password;
		}

		internal void add_tag(Tag tag) {
			this._tags.add (tag);
			this._tags.sort ((a, b) => {
				return a._name.collate (b._name);
			});
			this.fire (TriggerType.ADD_TAG);
		}
		internal void add_location(Location location) {
			this._locations.add (location);
			this.fire (TriggerType.ADD_LOCATION);
		}
		internal void add_account(Account account) {
			this._accounts.add (account);
			this._accounts.sort ((a, b) => {
				return a._name.collate (b._name);
			});
			this.fire (TriggerType.ADD_ACCOUNT);
		}
		internal Location? search_location (string name, string city) {
			foreach(var l in this._locations) {
				var b1 = l._city == "" && city == null;
				var b2 = l._city == null && city == "";
				if(name == l._name && (city == l._city || b1 || b2)) {
					return l;
				}
			}
			return null;
		}
		internal Location? search_location_by_id (string id) {
			foreach(var l in this._locations) {
				if(id == l.id_string ()) {
					return l;
				}
			}
			return null;
		}
		internal Tag? search_tag (string name) {
			foreach(var t in this._tags) {
				if(name == t._name) {
					return t;
				}
			}
			return null;
		}
		internal Account? search_account (string name) {
			foreach(var a in this._accounts) {
				if(name == a._name) {
					return a;
				}
			}
			return null;
		}
		internal void rename_tag(string old, string @new) {
			foreach(var t in this._tags) {
				if(old == t._name) {
					t.set_name (@new);
					break;
				}
			}
			this.sort ();
		}
		internal void fire(TriggerType type) {
			if(!this.sharp || this.func == null) {
				return;
			}
			this.func (type);
		}
		internal void set_sharp(TriggerFunc func) {
			this.func = func;
			this.sharp = true;
			this._tags.foreach(a => {
				a.set_sharp (func);
				return true;
			});
			this._locations.foreach(a => {
				a.set_sharp (func);
				return true;
			});
			this._accounts.foreach(a => {
				a.set_sharp (func);
				return true;
			});
		}
		internal void sort() {
			this._tags.sort ((a, b) => {
				return a._name.collate (b._name);
			});
			this._locations.sort ((a, b) => {
				return a._name.collate (b._name);
			});
			this._accounts.sort ((a, b) => {
				return a._name.collate (b._name);
			});
			this._accounts.foreach(a => {
				a.sort ();
				return true;
			});
			this.fire (TriggerType.GENERAL);
		}
		internal bool has_account(Account a) {
			foreach(var account in this._accounts)
				if(account._name == a._name) {
					return true;
				}
			return false;
		}
		internal void remove_account_by_name(string s) {
			var index = 0;
			foreach(var account in this._accounts) {
				if(account._name == s) {
					break;
				}
				index++;
			}
			this._accounts.remove_at (index);
			this.fire (TriggerType.DELETE_ACCOUNT);
		}
		internal void remove_tag_by_name(string s) {
			var t = this.search_tag (s);
			foreach(var account in this._accounts) {
				foreach(var expense in account._expenses) {
					for(var i = 0; i < expense._tags.size; i++) {
						if(expense._tags[i]._name == s) {
							expense._tags.remove_at (i);
							i--;
						}
					}
				}
			}
			this._tags.remove (t);
			this.fire (TriggerType.DELETE_TAG);
		}
		internal void remove_location_by_id(string id) {
			var loc = this.search_location_by_id (id);
			foreach(var account in this._accounts) {
				foreach(var expense in account._expenses) {
					if(expense._location != null &&
					   expense._location.id_string () == loc.id_string ()) {
						expense._location = null;
					}
				}
			}
			this._locations.remove (loc);
			this.fire (TriggerType.DELETE_LOCATION);
		}
		internal Json.Node serialize() {
			var builder = new Json.Builder ();
			builder.begin_object ();
			builder.set_member_name ("version");
			builder.add_int_value (2);
			builder.set_member_name ("tags");
			builder.begin_array ();
			foreach(var tag in this._tags) {
				builder.add_value (tag.serialize ());
			}
			builder.end_array ();
			builder.set_member_name ("locations");
			builder.begin_array ();
			foreach(var location in this._locations) {
				builder.add_value (location.serialize ());
			}
			builder.end_array ();
			builder.set_member_name ("accounts");
			builder.begin_array ();
			foreach(var account in this._accounts) {
				builder.add_value (account.serialize ());
			}
			builder.end_array ();
			builder.end_object ();
			return builder.get_root ();
		}
		internal bool account_exists(string name) {
			foreach(var account in this._accounts)
				if(account._name == name) {
					return true;
				}
			return false;
		}
		internal void secure(string pwd) {
			this.encrypted = true;
			this.password = pwd;
		}

		internal void fill_sample_data(bool small = true) {
			this.sharp = false;
			this._tags = new Gee.ArrayList<Tag>();
			this._locations = new Gee.ArrayList<Location>();
			this._accounts = new Gee.ArrayList<Account>();
			this.add_tag(new Tag(_("Shopping"), new uint8[4]{0xFF, 0x11, 0x00}));
			this.add_tag(new Tag(_("Restaurant"), new uint8[]{0x11, 0xFF, 0x00}));
			this.add_tag(new Tag(_("Gifts"), new uint8[]{0xFF, 0x00, 0xFF}));
			this.add_tag(new Tag(_("Donations"), new uint8[]{0x60, 0xF0, 0x0F}));
			this.add_tag(new Tag(_("IT/Software"), new uint8[]{0x00, 0xFF, 0xFF}));
			this.add_tag(new Tag(_("Groceries"), new uint8[4]{0x0F, 0xA0, 0xFF}));
			this.add_tag(new Tag(_("Hobbies"), new uint8[4]{0xAF, 0x0A, 0x0F}));
			this.add_tag(new Tag(_("Culture"), new uint8[4]{0xA0, 0x00, 0x00}));
			this.add_tag(new Tag(_("Other"), new uint8[4]{0x33, 0x33, 0xFF}));
			var acc = new Account(_("My account"));
			this.add_account(acc);
			acc.fill_sample_data(this._tags, this._locations, small);
			acc = new Account(_("Gifts"));
			this.add_account(acc);
			acc.fill_sample_data(this._tags, this._locations, small);
			if (small) {
				for(var i = 2017; i <= 2019; i++) {
					acc = new Account(_("Holidays %d").printf(i));
					this.add_account(acc);
					acc.fill_holiday_data(i, this._tags, this._locations, small);
				}
			} else {
				for(var i = 1980; i <= 2021; i++) {
					acc = new Account(_("Holidays %d").printf(i));
					this.add_account(acc);
					acc.fill_holiday_data(i, this._tags, this._locations, small);
				}
			}
			this.sharp = true;
			// TODO: Fire
			this.fire(TriggerType.ADD_TAG);
			this.fire(TriggerType.ADD_ACCOUNT);
		}
	}
}
