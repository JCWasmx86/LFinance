namespace LFinance {

	[CCode (cname="resources_get_resource")]
	extern Resource resources_get_resource();
	public static int main(string[] args) {
		Intl.setlocale();
		string langpack_dir = Path.build_filename(Constants.APPLICATION_INSTALL_PREFIX, "share", "locale");
		Intl.bindtextdomain(Constants.APPLICATION_ID, langpack_dir);
		Intl.bind_textdomain_codeset(Constants.APPLICATION_ID, "UTF-8");
		Intl.textdomain(Constants.APPLICATION_ID);
		Environment.set_application_name("LFinance");
		Gtk.Window.set_default_icon_name("jcwasmx86.lfinance");
		return new LFinance().run(args);
	}
	internal class LFinance : Gtk.Application {
		Gtk.ApplicationWindow? window;

		internal LFinance() {
			Object(application_id: "jcwasmx86.lfinance", flags: ApplicationFlags.FLAGS_NONE);
		}
		protected override void activate() {
			if(this.window == null) {
				this.window = new LFinanceWindow(this);
				this.window.show_all();
			} else {
				this.window.set_visible(true);
			}
		}
	}
	internal class LFinanceWindow : Gtk.ApplicationWindow {
		LFinancePanel panel;
		Gtk.Button lock_button;
		string password = "";
		internal LFinanceWindow(Gtk.Application app) {
			Object(application: app);
			this.title = "LFinance";
			this.set_default_size(1368, 768);
			GLib.resources_register(resources_get_resource());
			Gtk.IconTheme.get_default().add_resource_path("/jcwasmx86/LFinance/icons/scalable/actions");
			if(ModelBuilderFactory.encrypted_data()) {
				var dialog = new Gtk.Dialog();
				dialog.title = _("Password required");
				dialog.modal = false;
				dialog.add_buttons(_("Exit"), Gtk.ResponseType.CANCEL, _("Unlock"), Gtk.ResponseType.OK);
				var entry = new Gtk.Entry();
				entry.set_placeholder_text(_("Password"));
				entry.set_visibility(false);
				entry.changed.connect(() => {
					dialog.get_widget_for_response(Gtk.ResponseType.OK).set_sensitive(entry.text.length != 0);
				});
				dialog.get_widget_for_response(Gtk.ResponseType.OK).set_sensitive(false);
				dialog.get_content_area().pack_start(entry, true, true, 2);
				dialog.show_all();
				var r = dialog.run();
				if(r == Gtk.ResponseType.OK) {
					this.password = entry.text;
					dialog.destroy();
				} else {
					Posix.exit(0);
				}
			}
			this.build_header_bar();
			this.init_widgets();
		}
		void build_header_bar() {
			var item = new Gtk.MenuItem.with_label(_("About"));
			item.activate.connect(about);
			var menu = new Gtk.Menu();
			menu.append(item);
			menu.show_all();
			var menu_button = new Gtk.MenuButton();
			menu_button.@set("halign", Gtk.Align.CENTER);
			menu_button.image = new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.MENU);
			menu_button.popup = menu;
			var export_button = new Gtk.Button.with_label(_("Export"));
			export_button.clicked.connect(() => {
				this.panel.export_all();
			});
			this.lock_button = new Gtk.Button.from_icon_name("key-symbolic", Gtk.IconSize.MENU);
			this.lock_button.tooltip_text = _("Encrypt your data");
			this.lock_button.clicked.connect(() => {
				this.panel.setup_encryption();
				if(this.panel.already_encrypted())
					this.lock_button.destroy();
			});
			var title_bar = new Gtk.HeaderBar();
			title_bar.title = "LFinance";
			title_bar.show_close_button = true;
			title_bar.pack_start(export_button);
			title_bar.pack_start(lock_button);
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
			} catch(Error e) {
				var dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, _("An error occurred saving data: %s\n").printf(e.message));
				dialog.run();
				return true;
			}

			return false;
		}
		void init_widgets() {
			try {
				this.panel = new LFinancePanel(this.password);
				this.panel.password = this.password;
				if(this.panel.already_encrypted()) {
					this.lock_button.destroy();
				}
			} catch(Error e) {
				var dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, _("An error occurred loading LFinance: %s\n").printf(e.message));
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
				website = "https://github.com/JCWasmx86/LFinance"
			};
			dialog.show();
		}
	}
}
