namespace LFinance {
	internal class V1Test {
		static void main(string[] args) {
			Test.init (ref args);
			Test.add_func ("/no_data", () => {
				V1Test.no_data ();
			});
			Test.add_func ("/data_invalid_type", () => {
				V1Test.data_invalid_type ();
			});
			Test.add_func ("/expense_no_purpose", () => {
				V1Test.expense_no_purpose ();
			});
			Test.add_func ("/expense_purpose_invalid_type", () => {
				V1Test.expense_purpose_invalid_type ();
			});
			Test.add_func ("/expense_no_amount", () => {
				V1Test.expense_no_amount ();
			});
			Test.add_func ("/expense_amount_invalid_type", () => {
				V1Test.expense_amount_invalid_type ();
			});
			Test.add_func ("/expense_no_date", () => {
				V1Test.expense_no_date ();
			});
			Test.add_func ("/expense_date_invalid_type", () => {
				V1Test.expense_date_invalid_type ();
			});
			Test.add_func ("/date_missing_parts", () => {
				V1Test.date_missing_parts ();
			});
			Test.add_func ("/date_missing_month", () => {
				V1Test.date_missing_month ();
			});
			Test.add_func ("/date_missing_day", () => {
				V1Test.date_missing_day ();
			});
			Test.add_func ("/date_year_invalid_type", () => {
				V1Test.date_year_invalid_type ();
			});
			Test.add_func ("/date_month_invalid_type", () => {
				V1Test.date_month_invalid_type ();
			});
			Test.add_func ("/date_day_invalid_type", () => {
				V1Test.date_day_invalid_type ();
			});
			Test.add_func ("/no_sorting", () => {
				V1Test.no_sorting ();
			});
			Test.add_func ("/sorting_invalid_type", () => {
				V1Test.sorting_invalid_type ();
			});
			Test.run ();
		}
		static void no_data() {
			var f = TestUtils.write_file ("{\"version\" : 1}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void data_invalid_type() {
			var f = TestUtils.write_file ("{\"version\" : 1, \"data\": 5}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void expense_no_purpose() {
			var f = TestUtils.write_file ("{\"version\" : 1, \"data\": [{}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void expense_purpose_invalid_type() {
			var f = TestUtils.write_file ("{\"version\" : 1, \"data\": [{\"purpose\": []}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void expense_no_amount() {
			var f = TestUtils.write_file ("{\"version\" : 1, \"data\": [{\"purpose\": \"foo\"}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void expense_amount_invalid_type() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": []}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void expense_no_date() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": 0}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void expense_date_invalid_type() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": 0, \"date\": 0}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void date_missing_parts() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": 0, \"date\": {}}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void date_missing_month() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": 0, \"date\": {\"year\": 1234}}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void date_missing_day() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": 0, \"date\": {\"year\": 1234, \"month\": 10}}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void date_year_invalid_type() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": 0, \"date\": {\"year\": [], \"month\": 10}}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void date_month_invalid_type() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": 0, \"date\": {\"year\": 2000, \"month\": []}}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void date_day_invalid_type() {
			var f = TestUtils.write_file (
				"{\"version\" : 1, \"data\": [{\"purpose\": \"foo\", \"amount\": 0, \"date\": {\"year\": 2000, \"month\": 2, \"date\": []}}]}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void no_sorting() {
			var f = TestUtils.write_file ("{\"version\" : 1, \"data\": []}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void sorting_invalid_type() {
			var f = TestUtils.write_file ("{\"version\" : 1, \"data\": [], \"sorting\": []}");
			var passed = false;
			try {
				var builder = ModelBuilderFactory.from_file (f.get_path ());
				assert (builder is ModelV1Builder);
				builder.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
	}
}
