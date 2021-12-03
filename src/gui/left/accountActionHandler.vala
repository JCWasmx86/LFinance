namespace LFinance {
	class AccountActionHandler : GLib.Object, ActionHandler {
		Model model;
		SelectAccountFunc func;

		internal AccountActionHandler(SelectAccountFunc func, Model model) {
			this.model = model;
			this.func = func;
		}
		bool handle_edit(string old, string @new, out string replacement) {
			replacement = null;
			warning("Didn't expect a call to AccountActionHandler::handle_edit!");
			return false; // Shouldn't be called
		}
		void handle_mouse_press(string selected, Gdk.EventButton event) {
			if(event.type == Gdk.EventType.BUTTON_PRESS && event.button == 3) {
				var menu = new Gtk.Menu();
				var export = new Gtk.MenuItem.with_label(_("Export"));
				export.activate.connect(() => {
					var dialog = new Gtk.FileChooserDialog(_("Export %s").printf(selected),null, Gtk.FileChooserAction.SAVE, _("_Cancel"), Gtk.ResponseType.CANCEL, _("Export"), Gtk.ResponseType.OK);
					dialog.do_overwrite_confirmation = true;
					var result = dialog.run();
					var file = dialog.get_filename();
					dialog.destroy();
					if(result == Gtk.ResponseType.OK) {
						var progress_dialog = new Gtk.Dialog();
						var bar = new Gtk.ProgressBar();
						bar.show_text = true;
						var scrolled_window = new Gtk.ScrolledWindow(null, null);
						var view = new Gtk.TextView();
						view.editable = false;
						scrolled_window.add(view);
						progress_dialog.get_content_area().pack_start(bar, false, false, 2);
						progress_dialog.get_content_area().pack_start(scrolled_window, true, true, 2);
						var exit_button = progress_dialog.add_button(_("_Close"), 0);
						progress_dialog.response.connect(r => progress_dialog.destroy());
						// Otherwise the dialog will be too small
						progress_dialog.set_default_size(250, 350);
						progress_dialog.show_all();
						new Thread<void>("question", () => {
							try {
								var exporter = ExporterFactory.for_file(file);
								exporter.progress.connect((text, frac) => {
									GLib.Idle.add(() => {
										view.buffer.text += (text + "\n");
										bar.set_fraction(frac);
										// To avoid any floating point inaccuracies...
										exit_button.set_sensitive(frac >= 0.999999);
										return false;
									});
								});
								exporter.export(this.model.search_account(selected));
							} catch(GLib.Error e) {
								var message = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, _("Export failed: %s").printf(e.message));
								message.run();
								message.destroy();
							}
						});
					}
				});
				var remove = new Gtk.MenuItem.with_label(_("Delete"));
				remove.activate.connect(() => {
					var md = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Do you really want to delete the account %s?").printf(selected));
					md.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("_Delete"), Gtk.ResponseType.OK);
					if(md.run() == Gtk.ResponseType.CANCEL) {
						md.destroy();
						return;
					}
					md.destroy();
					this.model.remove_account_by_name(selected);
				});
				menu.append(export);
				menu.append(remove);
				menu.show_all();
				menu.popup_at_pointer(event);
				return;
			}
			info("Account selected: %s", selected);
			this.func(selected);
		}
		void handle_key_press(string selected, Gdk.EventKey key) {
			
		}
	}
}
