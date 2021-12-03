namespace LFinance {
	internal class ExportDialog : Gtk.Dialog {
		Account account;
		string file;

		Gtk.ProgressBar progress_bar;
		Gtk.TextView view;
		Gtk.Widget exit_button;

		internal ExportDialog(string file, Account account) {
			this.account = account;
			this.file = file;
			this.build_gui();
		}
		void build_gui() {
			this.progress_bar = new Gtk.ProgressBar();
			this.progress_bar.show_text = true;
			var scrolled_window = new Gtk.ScrolledWindow(null, null);
			this.view = new Gtk.TextView();
			this.view.editable = false;
			scrolled_window.add(this.view);
			this.get_content_area().pack_start(this.progress_bar, false, false, 2);
			this.get_content_area().pack_start(scrolled_window, true, true, 2);
			this.exit_button = this.add_button(_("_Close"), Gtk.ResponseType.OK);
			this.response.connect(r => this.destroy());
			// Otherwise the dialog will be too small
			this.set_default_size(250, 350);
		}
		internal void export() {
			this.show_all();
			new Thread<void>("question", () => {
				try {
					var exporter = ExporterFactory.for_file(file);
					exporter.progress.connect((text, frac) => {
						GLib.Idle.add(() => {
							this.view.buffer.text += (text + "\n");
							this.progress_bar.set_fraction(frac);
							// To avoid any floating point inaccuracies...
							this.exit_button.set_sensitive(frac >= 0.999999);
							return false;
						});
					});
					exporter.export(this.account);
				} catch(GLib.Error e) {
					var message = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, _("Export failed: %s").printf(e.message));
					message.run();
					message.destroy();
				}
			});
		}
	}
}
