namespace LFinance {
	internal class ExportModelDialog : Gtk.Dialog {
		Model model;
		string file;

		Gtk.ProgressBar progress_bar;
		Gtk.TextView view;
		Gtk.Widget exit_button;

		internal ExportModelDialog(string file,
					   Model model) {
			this.model = model;
			this.file = file;
			this.build_gui ();
		}
		void build_gui() {
			this.progress_bar = new Gtk.ProgressBar ();
			this.progress_bar.show_text = true;
			var scrolled_window = new Gtk.ScrolledWindow (null, null);
			this.view = new Gtk.TextView ();
			this.view.editable = false;
			scrolled_window.add (this.view);
			this.get_content_area ().pack_start (this.progress_bar, false, false, 2);
			this.get_content_area ().pack_start (scrolled_window, true, true, 2);
			this.exit_button = this.add_button (_("_Close"), Gtk.ResponseType.OK);
			this.response.connect (r => this.destroy ());
			// Otherwise the dialog will be too small
			this.set_default_size (250, 350);
		}
		internal void export() {
			this.show_all ();
			new Thread<void>("question", () => {
				try {
					var exporter = new PDFModelExporter (this.model, this.file);
					exporter.progress_update.connect ((text, frac) => {
						Idle.add (() => {
							this.update_view (text, frac);
							return false;
						});
					});
					exporter.export ();
				} catch(Error e) {
					this.destroy ();
					var message =
						new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL,
								       Gtk.MessageType.ERROR,
								       Gtk.ButtonsType.OK,
								       _("Export failed: %s").printf (e.message));
					message.run ();
					message.destroy ();
				}
			});
		}
		void update_view(string text,
				 double frac) {
			this.view.buffer.text += (text + "\n");
			this.progress_bar.set_fraction (frac);
			// To avoid any floating point inaccuracies…
			this.exit_button.set_sensitive (frac >= 0.999999);
		}
	}
}
