namespace LFinance {
	internal class V2Test {
		static void main(string[] args) {
			Test.init (ref args);
			Test.add_func ("/no_tags", () => {
				V2Test.no_tags ();
			});
			Test.add_func ("/tags_invalid_type", () => {
				V2Test.tags_invalid_type ();
			});
			Test.add_func ("/tag_no_name", () => {
				V2Test.tag_no_name ();
			});
			Test.add_func ("/tag_name_invalid_type", () => {
				V2Test.tag_name_invalid_type ();
			});
			Test.add_func ("/tag_no_color", () => {
				V2Test.tag_no_color ();
			});
			Test.add_func ("/tag_color_invalid_type", () => {
				V2Test.tag_color_invalid_type ();
			});
			Test.run ();
		}
		static void no_tags() {
			var f = TestUtils.write_file ("{\"version\": 2}");
			var passed = false;
			try {
				var model = ModelBuilderFactory.from_file (f.get_path ());
				assert (model is ModelV2Builder);
				model.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void tags_invalid_type() {
			var f = TestUtils.write_file ("{\"version\": 2, \"tags\": 5}");
			var passed = false;
			try {
				var model = ModelBuilderFactory.from_file (f.get_path ());
				assert (model is ModelV2Builder);
				model.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void tag_no_name() {
			var f = TestUtils.write_file ("{\"version\": 2, \"tags\": [{}]}");
			var passed = false;
			try {
				var model = ModelBuilderFactory.from_file (f.get_path ());
				assert (model is ModelV2Builder);
				model.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void tag_name_invalid_type() {
			var f = TestUtils.write_file ("{\"version\": 2, \"tags\": [{\"name\": []}]}");
			var passed = false;
			try {
				var model = ModelBuilderFactory.from_file (f.get_path ());
				assert (model is ModelV2Builder);
				model.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void tag_no_color() {
			var f = TestUtils.write_file ("{\"version\": 2, \"tags\": [{\"name\": \"foo\"}]}");
			var passed = false;
			try {
				var model = ModelBuilderFactory.from_file (f.get_path ());
				assert (model is ModelV2Builder);
				model.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
		static void tag_color_invalid_type() {
			var f =
				TestUtils.write_file ("{\"version\": 2, \"tags\": [{\"name\": \"foo\", \"color\": {}}]}");
			var passed = false;
			try {
				var model = ModelBuilderFactory.from_file (f.get_path ());
				assert (model is ModelV2Builder);
				model.build ();
			} catch(Error e) {
				info (e.message);
				passed = true;
			}
			assert (passed);
		}
	}
}
