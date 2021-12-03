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
						var d = new ExportDialog(file, this.model.search_account(selected));
						d.export();
					}
				});
				var remove = new Gtk.MenuItem.with_label(_("Delete"));
				remove.activate.connect(() => {
					var md = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Do you really want to delete the account %s?").printf(selected));
					md.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("Delete"), Gtk.ResponseType.OK);
					if(md.run() == Gtk.ResponseType.OK) {
						this.model.remove_account_by_name(selected);
					}
					md.destroy();
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
