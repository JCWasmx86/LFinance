namespace LFinance {
	class ModelBuilderTest {
		static void main(string[] args) {
			Test.init (ref args);
			Test.add_func ("/no_object",
				       () => {
				ModelBuilderTest.no_object ();
			});
			Test.add_func ("/invalid_json",
				       () => {
				ModelBuilderTest.invalid_json ();
			});
			Test.add_func ("/no_version",
				       () => {
				ModelBuilderTest.no_version ();
			});
			Test.add_func ("/invalid_version",
				       () => {
				ModelBuilderTest.invalid_version ();
			});
			Test.add_func ("/version_invalid_data_type",
				       () => {
				ModelBuilderTest.version_invalid_data_type ();
			});
			Test.add_func ("/get_right_builder",
				       () => {
				ModelBuilderTest.get_right_builder ();
			});
			Test.run ();
		}
		static void no_object() {
			var f = TestUtils.write_file ("");
			var passed = false;
			try {
				ModelBuilderFactory.from_file (f.get_path ());
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void invalid_json() {
			var f = TestUtils.write_file ("{{{");
			var passed = false;
			try {
				ModelBuilderFactory.from_file (f.get_path ());
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void no_version() {
			var f = TestUtils.write_file ("{}");
			var passed = false;
			try {
				ModelBuilderFactory.from_file (f.get_path ());
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void invalid_version() {
			var f = TestUtils.write_file ("{\"version\": 5643464}");
			var passed = false;
			try {
				ModelBuilderFactory.from_file (f.get_path ());
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void version_invalid_data_type() {
			var f = TestUtils.write_file ("{\"version\": []}");
			var passed = false;
			try {
				ModelBuilderFactory.from_file (f.get_path ());
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void get_right_builder() {
			var f = TestUtils.write_file ("{\"version\": 1}");
			var passed = false;
			try {
				var model = ModelBuilderFactory.from_file (f.get_path ());
				passed = model is ModelV1Builder;
			} catch(Error e) {
				critical (e.message);
				passed = false;
			}
			assert (passed);
			f = TestUtils.write_file ("{\"version\": 2}");
			passed = false;
			try {
				var model = ModelBuilderFactory.from_file (f.get_path ());
				passed = model is ModelV2Builder;
			} catch(Error e) {
				critical (e.message);
				passed = false;
			}
			assert (passed);
		}
	}
}
