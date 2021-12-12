namespace LFinance {
	internal class TestUtils {
		internal static File write_file(string s) {
			try {
				FileIOStream stream;
				var f = GLib.File.new_tmp("test_XXXXXX_lfinance.json", out stream);
				((FileOutputStream)stream.output_stream).write(s.data);
				return f;
			} catch(Error e) {
				critical(e.message);
				// Won't be reached
				return GLib.File.new_for_path("/dev/null");
			}
		}
	}
}
