namespace LFinance {
	internal class Stats {
		internal double sum;
		internal double average;
		internal Range last_week;
		internal Range last_month;
		internal Range last_year;
		internal Range total;
		Gee.List<Expense> expenses;
		internal Stats(Gee.List<Expense> expenses) {
			this.expenses = expenses;
			this.sum = 0;
			foreach(var expense in expenses) {
				this.sum += expense._amount / 100.0;
			}
			this.average = this.sum / expenses.size;
			var now = new DateTime.now_local();
			this.last_week = this.build_range(now.add_weeks(-1));
			this.last_month = this.build_range(now.add_months(-1));
			this.last_year = this.build_range(now.add_years(-1));
			this.total = this.build_range(this.expenses[0]._date);
		}
		Range build_range(DateTime time) {
			var idx = 0;
			var ret = new Range();
			info("Looking for all expenses after %s!", time.format("%x"));
			for(var i = 0; i < this.expenses.size; i++) {
				if(this.expenses[i]._date.compare(time) >= 0) {
					info("Found expense: %s", this.expenses[i]._date.format("%x"));
					idx = i;
					break;
				}
			}
			for(var i = idx; i < this.expenses.size; i++) {
				var expense = this.expenses[i];
				ret.add_expense(expense._amount / 100.0, expense._date);
			}
			ret.end_it(this.expenses[idx]._date, this.expenses[this.expenses.size - 1]._date);
			return ret;
		}
	}
	internal class MonthData {
		internal string name;
		internal double amount;
		internal uint64 count;
		internal int index;

		internal MonthData(int index, string s) {
			this.index = index;
			this.name = s;
		}
		internal void add_expense(double d) {
			this.amount += d;
			this.count++;
		}
	}
	internal class Range {
		internal Gee.Map<int, MonthData> months;
		internal Gee.List<double?> each_expense;
		internal Gee.List<double?> accumulated;
		internal Gee.List<DateTime> dates;
		uint64 n;
		double average;
		internal double average_per_day;
		internal double max_expense_value;
		internal DateTime start_date;
		internal DateTime end_date;

		internal Range() {
			this.n = 0;
			this.months = new Gee.HashMap<int, MonthData>();
			this.each_expense = new Gee.ArrayList<double?>();
			this.accumulated = new Gee.ArrayList<double?>();
			this.dates = new Gee.ArrayList<DateTime?>();
		}
		internal void add_expense(double amount, DateTime date) {
			var month = date.get_month();
			if(this.months.has_key(month)) {
				this.months[month].add_expense(amount);
			} else {
				this.months[month] = new MonthData(month, date.format("%B"));
				this.months[month].add_expense(amount);
			}
			if(this.dates.size == 0 || this.dates[this.dates.size - 1].compare(date) != 0) {
				this.each_expense.add(amount);
				if(accumulated.size != 0)
					this.accumulated.add(this.accumulated[this.accumulated.size - 1] + amount);
				else
					this.accumulated.add(amount);
				this.max_expense_value = double.max(amount, this.max_expense_value);
				this.dates.add(date);
			} else {
				var len = this.each_expense.size - 1;
				this.each_expense[len] = this.each_expense[len] + amount;
				this.accumulated[len] = this.accumulated[len] + amount;
				this.max_expense_value = double.max(this.each_expense[len], this.max_expense_value);
			}
			this.n++;
		}
		internal void end_it(DateTime start, DateTime end) {
			this.start_date = start;
			this.end_date = end;
			var len = this.accumulated.size - 1;
			this.average_per_day = this.accumulated[len] / (this.end_date.difference(this.start_date) / TimeSpan.DAY);
			this.average = this.accumulated[len] / this.each_expense.size;
		}
	}
}
