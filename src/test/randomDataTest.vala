namespace LFinance {
	class RandomDataTest {
		static void main(string[] args) {
			Test.init (ref args);
			Test.add_func ("/small_data",
				       () => {
				RandomDataTest.small_data ();
			});
			Test.add_func ("/big_data",
				       () => {
				RandomDataTest.big_data ();
			});
			Test.run ();
		}
		static void small_data() {
			try {
				var pool = new ThreadPool<uint?>.with_owned_data(i => {
					var model = new Model();
					model.fill_sample_data(true);
					var exporter = new PDFModelExporter(model, "%u_test.pdf".printf(i));
					exporter.progress_update.connect((s, f) => {
						info("[%lf%%]: %s", f * 100, s);
					});
					try {
						exporter.export();
					} catch (Error e) {
						critical(e.message);
						assert(false);
					}
				}, 2, false);
				for(var i = 0; i < 2; i++) {
					pool.add(i);
				}
				while(pool.unprocessed() > 0);
			} catch (ThreadError error) {
				critical(error.message);
				assert(false);
			}
		}
		static void big_data() {
			try {
				var pool = new ThreadPool<uint?>.with_owned_data(i => {
					var model = new Model();
					model.fill_sample_data(false);
					var exporter = new PDFModelExporter(model, "%u_big_test.pdf".printf(i));
					exporter.progress_update.connect((s, f) => {
						info("[%lf%%]: %s", f * 100, s);
					});
					try {
						exporter.export();
					} catch (Error e) {
						critical(e.message);
						assert(false);
					}
				}, 2, false);
				for(var i = 0; i < 2; i++) {
					pool.add(i);
				}
				while(pool.unprocessed() > 0);
			} catch (ThreadError error) {
				critical(error.message);
				assert(false);
			}
		}
	}
}
