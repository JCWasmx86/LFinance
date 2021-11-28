namespace MoneyWatch {
	public static int main(string[] args) {
		Intl.setlocale(GLib.LocaleCategory.ALL, "");
		string langpack_dir = GLib.Path.build_filename(Constants.APPLICATION_INSTALL_PREFIX, "share", "locale");
		GLib.Intl.bindtextdomain(Constants.APPLICATION_ID, langpack_dir);
		GLib.Intl.bind_textdomain_codeset(Constants.APPLICATION_ID, "UTF-8");
		GLib.Intl.textdomain(Constants.APPLICATION_ID);
		Environment.set_application_name("MoneyWatch");
		Gtk.Window.set_default_icon_name("jcwasmx86.money_watch");
		return new MoneyWatch().run(args);
	}
	internal class MoneyWatch : Gtk.Application {
		Gtk.ApplicationWindow? window;

		internal MoneyWatch() {
			Object(application_id: "jcwasmx86.money_watch", flags: ApplicationFlags.FLAGS_NONE);
		}
		protected override void activate() {
			if(this.window == null) {
				this.window = new MoneyWatchWindow(this);
				this.window.show_all();
			} else {
				this.window.set_visible(true);
			}
		}
	}
	internal class MoneyWatchWindow : Gtk.ApplicationWindow {
		MoneyWatchPanel panel;

		internal MoneyWatchWindow(Gtk.Application app) {
			Object(application: app);
			this.title = "MoneyWatch";
			this.set_default_size(1368, 768);
			this.build_header_bar();
			this.init_widgets();
		}
		void build_header_bar() {
			var item = new Gtk.MenuItem.with_label(_("About MoneyWatch"));
			item.activate.connect(about);
			var menu = new Gtk.Menu();
			menu.append(item);
			menu.show_all();
			var menu_button = new Gtk.MenuButton();
			menu_button.@set("halign", Gtk.Align.CENTER);
			menu_button.image = new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.MENU);
			menu_button.popup = menu;
			var title_bar = new Gtk.HeaderBar();
			title_bar.title = "MoneyWatch";
			title_bar.show_close_button = true;
			title_bar.pack_end(menu_button);
			title_bar.show_all();
			this.set_titlebar(title_bar);
			// TODO: The popup goes over the edge of the window
			menu_button.set_align_widget(title_bar);
		}
		public override bool delete_event(Gdk.EventAny event) {
			// TODO: Check if edited, ask the user if he wants to save
			// If yes, return true
			try {
				this.panel.save();
			} catch(GLib.Error e) {
				var dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, _("An error occurred saving data: %s\n").printf(e.message));
				dialog.run();
				return true;
			}

			return false;
		}
		void init_widgets() {
			try {
				this.panel = new MoneyWatchPanel();
			} catch(GLib.Error e) {
				var dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, _("An error occurred loading MoneyWatch: %s\n").printf(e.message));
				dialog.run();
				Process.exit(-1);
			}
			this.add(this.panel);
			this.show_all();
		}

		void about() {
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
				website = "https://github.com/JCWasmx86/MoneyWatch"
			};
			dialog.show();
		}
	}
}
