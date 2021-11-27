namespace MoneyWatch {
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
				var item = new Gtk.MenuItem.with_label(_("Delete"));
				item.activate.connect(() => {
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
				menu.append(item);
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
