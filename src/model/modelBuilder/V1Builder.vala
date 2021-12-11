using Json;

namespace LFinance {
	internal class ModelV1Builder : ModelBuilder, GLib.Object {
		Json.Object root;
		internal ModelV1Builder(Json.Object root) {
			this.root = root;
		}

		internal Model build() throws GLib.Error {
			var ret = new Model();
			var account = new Account(_("default"));
			ParsingErrors.check_node(this.root, "data", NodeType.ARRAY);
			var data = this.root.get_array_member("data");
			for(var i = 0; i < data.get_length(); i++) {
				var expense = data.get_object_element(i);
				ParsingErrors.check_node(expense, "purpose", NodeType.VALUE);
				var expense_ret = new Expense(expense.get_string_member("purpose"));
				ParsingErrors.check_node(expense, "amount", NodeType.VALUE);
				expense_ret.set_amount(expense.get_int_member("amount") & 0xFFFFFFFF);
				expense_ret.set_currency("€");
				ParsingErrors.check_node(expense, "date", NodeType.OBJECT);
				var date = expense.get_object_member("date");
				ParsingErrors.check_node(date, "year", NodeType.VALUE);
				ParsingErrors.check_node(date, "month", NodeType.VALUE);
				ParsingErrors.check_node(date, "day", NodeType.VALUE);
				expense_ret.set_date(new DateTime(new TimeZone.local(),
									(int)date.get_int_member("year") + 1900,
									(int)date.get_int_member("month") + 1,
									(int)date.get_int_member("day"), 0, 0, 0));
				account.add_expense(expense_ret);
			}
			info("Loaded %u expenses", data.get_length());
			ParsingErrors.check_node(this.root, "sorting", NodeType.VALUE);
			account.set_sorting((uint)this.root.get_int_member("sorting"));
			ret.add_account(account);
			return ret;
		}
	}
}
