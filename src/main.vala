namespace MoneyWatch {
	public static int main(string[] args) {
		Intl.setlocale(GLib.LocaleCategory.ALL, "");
		string langpack_dir = GLib.Path.build_filename(Constants.APPLICATION_INSTALL_PREFIX, "share", "locale");
		GLib.Intl.bindtextdomain(Constants.APPLICATION_ID, langpack_dir);
		GLib.Intl.bind_textdomain_codeset(Constants.APPLICATION_ID, "UTF-8");
		GLib.Intl.textdomain(Constants.APPLICATION_ID);
		return new MoneyWatch().run(args);
	}
	internal class MoneyWatch : Gtk.Application {
		internal MoneyWatch() {
			Object(application_id: "jcwasmx86.money_watch", flags: ApplicationFlags.FLAGS_NONE);
		}
		protected override void activate() {
			var window = new Gtk.ApplicationWindow(this);
			window.set_default_size(1368, 768);
			window.title = "MoneyWatch";
			var panel = new MoneyWatchPanel();
			window.add(panel);
			window.show_all();
			window.destroy.connect(() => {
				panel.save();
			});
		}
	}
}
