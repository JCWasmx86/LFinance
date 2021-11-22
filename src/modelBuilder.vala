using GLib;

namespace MoneyWatch {
	internal errordomain ParsingErrors {
		INVALID_DATA
	}
	internal interface ModelBuilder : GLib.Object {
		internal abstract Model build();
	}
	internal class ModelBuilderFactory {
		internal static ModelBuilder from_file(string file) throws Error {
			var parser = new Json.Parser();
			parser.load_from_file(file);
			var node = parser.get_root();
			if(node == null || node.get_node_type() != Json.NodeType.OBJECT) {
				throw new ParsingErrors.INVALID_DATA("No object found");
			}
			var root = node.get_object();
			if(root == null || !root.has_member("version")) {
				throw new ParsingErrors.INVALID_DATA("No object	found or version not found");
			}
			var version = root.get_int_member("version");
			switch(version) {
				case 1:
					return new ModelV1Builder(root);
				case 2:
					return new ModelV2Builder(root);
				default:
					throw new ParsingErrors.INVALID_DATA("Invalid version: %lld".printf(version));
			}
		}
	}
	internal class ModelV1Builder : ModelBuilder, GLib.Object {
		Json.Object root;
		internal ModelV1Builder(Json.Object root) {
			this.root = root;
		}

		internal Model build() {
			var ret = new Model();
			var account = new Account(_("default"));
			var data = this.root.get_array_member("data");
			for(var i = 0; i < data.get_length(); i++) {
				var expense = data.get_object_element(i);
				var expense_ret = new Expense(expense.get_string_member("purpose"));
				expense_ret.set_amount(expense.get_int_member("amount") & 0xFFFFFFFF);
				expense_ret.set_currency("€");
				var date = expense.get_object_member("date");
				expense_ret.set_date(new DateTime(new TimeZone.local(),
									(int)date.get_int_member("year") + 1900,
									(int)date.get_int_member("month") + 1,
									(int)date.get_int_member("day"), 0, 0, 0));
				account.add_expense(expense_ret);
			}
			info("Loaded %u expenses", data.get_length());
			account.set_sorting((uint)this.root.get_int_member("sorting"));
			ret.add_tag(new Tag("foo", new uint8[]{(uint8)255, (uint8)200, (uint8)100, (uint8)0}));
			ret.add_tag(new Tag("foo1", new uint8[]{(uint8)255, (uint8)200, (uint8)100, (uint8)0}));
			ret.add_tag(new Tag("foo2", new uint8[]{(uint8)255, (uint8)100, (uint8)100, (uint8)0}));
			ret.add_tag(new Tag("foo3", new uint8[]{(uint8)255, (uint8)200, (uint8)100, (uint8)0}));
			ret.add_account(account);
			return ret;
		}
	}

	internal class ModelV2Builder : ModelBuilder, GLib.Object {
		Json.Object root;

		internal ModelV2Builder(Json.Object root) {
			this.root = root;
		}

		internal Model build() {
			var ret = new Model();
			var tags = this.root.get_array_member("tags");
			for(var i = 0; i < tags.get_length(); i++) {
				var tag = tags.get_object_element(i);
				var name = tag.get_string_member("name");
				var colors = tag.get_array_member("color");
				var color = new uint8[4];
				color[0] = (uint8)(colors.get_int_element(0) & 0xFF);
				color[1] = (uint8)(colors.get_int_element(1) & 0xFF);
				color[2] = (uint8)(colors.get_int_element(2) & 0xFF);
				color[3] = colors.get_length() == 3 ? 255 : (uint8)(colors.get_int_element(3) & 0xFF);
				ret.add_tag(new Tag(name, color));
			}
			info("Loaded %u tags",tags.get_length());
			var locations = this.root.get_array_member("locations");
			for(var i = 0; i < locations.get_length(); i++) {
				var location = locations.get_object_element(i);
				var name = location.get_string_member("name");
				var city = location.has_member("city") ? location.get_string_member("city") : null;
				var _info = location.has_member("info") ? location.get_string_member("info") : null;
				ret.add_location(new Location(name, city, _info));
			}
			info("Loaded %u locations",locations.get_length());
			var accounts = this.root.get_array_member("accounts");
			for(var i = 0; i < accounts.get_length(); i++) {
				var account = accounts.get_object_element(i);
				var account_ret = new Account(account.get_string_member("name"));
				var sorting = account.get_int_member("sorting") & 0xFF;
				account_ret.set_sorting((uint)sorting);
				var expenses = account.get_array_member("expenses");
				for(var j = 0; j < expenses.get_length(); j++) {
					var expense = expenses.get_object_element(j);
					var expense_ret = new Expense(expense.get_string_member("purpose"));
					expense_ret.set_amount(expense.get_int_member("amount") & 0xFFFFFFFF);
					expense_ret.set_currency(expense.get_string_member("currency"));
					var date = expense.get_object_member("date");
					expense_ret.set_date(new DateTime(new TimeZone.local(),
										(int)date.get_int_member("year"),
										(int)date.get_int_member("month"),
										(int)date.get_int_member("day"), 0, 0, 0));
					if(expense.has_member("location") && expense.get_string_member("location") != null) {
						var city = expense.has_member("location_city") ? expense.get_string_member("location_city") : null;
						expense_ret.set_location(ret.search_location(expense.get_string_member("location"), city));
					}
					var assigned_tags = expense.get_array_member("tags");
					for(var k = 0; k < assigned_tags.get_length(); k++) {
						expense_ret.add_tag(ret.search_tag(assigned_tags.get_string_element(i)));
					}
					account_ret.add_expense(expense_ret);
				}
				info("Loaded %u expenses", expenses.get_length());
				ret.add_account(account_ret);
			}
			info("Loaded %u accounts", accounts.get_length());
			return ret;
		}
	}
}
