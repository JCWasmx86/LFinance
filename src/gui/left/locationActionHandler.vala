namespace LFinance {
	class LocationActionHandler : GLib.Object, ActionHandler {
		Model model;
		internal LocationActionHandler(Model model) {
			this.model = model;
		}
		bool handle_edit(string old, string @new, out string replacement) {
			replacement = null;
			return false;
		}
		void handle_mouse_press(string selected, Gdk.EventButton event) {
			if(event.type == Gdk.EventType.BUTTON_PRESS && event.button == 3) {
				var menu = new Gtk.Menu();
				var edit = new Gtk.MenuItem.with_label(_("Edit"));
				edit.activate.connect(() => {
					var location = model.search_location_by_id(selected);
					var dialog = new LocationEditDialog(selected, model);
					var result = dialog.run();
					var name = dialog.get_name();
					var city = dialog.get_city();
					var info = dialog.get_info();
					dialog.destroy();
					if(result == Gtk.ResponseType.OK) {
						// Edit and fire
						location.set_name(name);
						location.set_city(city);
						location.set_info(info);
						dialog.destroy();
						model._locations.sort((a, b) => {
							return a._name.collate(b._name);
						});
						model.fire(TriggerType.GENERAL);
					}
				});
				menu.append(edit);
				var @delete = new Gtk.MenuItem.with_label(_("Delete"));
				@delete.activate.connect(() => {
					var md = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Do you really want to delete this location?"));
					md.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("_Delete"), Gtk.ResponseType.OK);
					if(md.run() == Gtk.ResponseType.OK) {
						this.model.remove_location_by_id(selected);
					}
					md.destroy();
				});
				menu.append(@delete);
				menu.show_all();
				menu.popup_at_pointer(event);
				return;
			}
		}
		void handle_key_press(string selected, Gdk.EventKey key) {
			
		}
	}
}
