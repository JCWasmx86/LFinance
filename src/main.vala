namespace MoneyWatch {
	public static int main(string[] args) {
		Intl.setlocale(GLib.LocaleCategory.ALL, "");
		string langpack_dir = GLib.Path.build_filename(Constants.APPLICATION_INSTALL_PREFIX, "share", "locale");
		GLib.Intl.bindtextdomain(Constants.APPLICATION_ID, langpack_dir);
		GLib.Intl.bind_textdomain_codeset(Constants.APPLICATION_ID, "UTF-8");
		GLib.Intl.textdomain(Constants.APPLICATION_ID);
		Environment.set_application_name("MoneyWatch");
		Gtk.Window.set_default_icon_name ("jcwasmx86.money_watch");
		return new MoneyWatch().run(args);
	}
	internal class MoneyWatch : Gtk.Application {
		internal MoneyWatch() {
			Object(application_id: "jcwasmx86.money_watch", flags: ApplicationFlags.FLAGS_NONE);
		}
		protected override void activate() {
			var window = new MoneyWatchWindow(this);
			var panel = new MoneyWatchPanel();
			window.add(panel);
			window.show_all();
			window.destroy.connect(() => {
				panel.save();
			});
		}
	}
	internal class MoneyWatchWindow : Gtk.ApplicationWindow {
		internal MoneyWatchWindow(Gtk.Application app) {
			Object(application: app);
			this.title = "MoneyWatch";
			this.set_default_size(1368, 768);
			var title_bar = new Gtk.HeaderBar();
			title_bar.title = "MoneyWatch";
			title_bar.show_close_button = true;
			title_bar.spacing = 0;
			var menu_button = new Gtk.MenuButton();
			menu_button.@set("halign", Gtk.Align.CENTER);
			menu_button.direction = Gtk.ArrowType.DOWN;
			menu_button.image = new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.MENU);
			title_bar.pack_end(menu_button);
			var menu = new Gtk.Menu();
			var item = new Gtk.MenuItem.with_label(_("About MoneyWatch"));
			menu.append(item);
			item.activate.connect(about);
			menu.show_all();
			menu_button.popup = menu;
			title_bar.show_all();
			this.set_titlebar(title_bar);
			// TODO: The popup goes over the edge of the window
			menu_button.set_align_widget(title_bar);
		}
		internal void about() {
			var authors = new string[] {"JCWasmx86"};
			var dialog = new Gtk.AboutDialog() {
				transient_for = this,
				modal = true,
				program_name = Environment.get_application_name(),
				logo_icon_name = Gtk.Window.get_default_icon_name(),
				version = Constants.PACKAGE_VERSION,
				copyright = _("Copyright © 2021 JCWasmx86"),
				license_type = Gtk.License.AGPL_3_0,
				authors = authors,
				website = "https://github.com/JCWasmx86/MoneyWatch",
			};
			dialog.show();
		}
	}
}
