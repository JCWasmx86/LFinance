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
					var dialog = new Gtk.FileChooserDialog(_("Export %s").printf(selected), null, Gtk.FileChooserAction.SAVE);
					dialog.do_overwrite_confirmation = true;
					dialog.add_button(_("Export"), 0);
					dialog.add_button(_("Cancel"), 1);
					var result = dialog.run();
					var file = dialog.get_filename();
					dialog.destroy();
					if(result == 0) {
						new Thread<void>("question", () => {
							try {
								var exporter = ExporterFactory.for_file(file);
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
					md.add_button(_("Delete"), 0);
					md.add_button(_("Cancel"), 1);
					if(md.run() == 1) {
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
