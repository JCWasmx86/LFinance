namespace LFinance {
	class TagActionHandler : GLib.Object, ActionHandler {
		Model model;
		internal TagActionHandler(Model model) {
			this.model = model;
		}
		bool handle_edit(string old, string @new, out string replacement) {
			replacement = null;
			var prologue_len = "<b><span foreground=\"#11223344\" >".length;
			var epilogue_len = "</span></b>".length;
			var content_len = @old.length - (prologue_len + epilogue_len);
			var old_name = @old.slice(prologue_len, prologue_len + content_len);
			if(old_name == @new)
				return false;
			if(this.model.search_tag(@new) != null)
				return false;
			replacement = @old.substring(0, prologue_len) + @new + "</span></b>";
			model.rename_tag(old_name, @new);
			return false;
		}
		void handle_mouse_press(string selected, Gdk.EventButton event) {
			if(event.type == Gdk.EventType.BUTTON_PRESS && event.button == 3) {
				var menu = new Gtk.Menu();
				var edit = new Gtk.MenuItem.with_label(_("Edit"));
				edit.activate.connect(() => {
					var prologue_len = "<b><span foreground=\"#11223344\" >".length;
					var epilogue_len = "</span></b>".length;
					var content_len = selected.length - (prologue_len + epilogue_len);
					var old_name = selected.slice(prologue_len, prologue_len + content_len);
					var tag = this.model.search_tag(old_name);
					var dialog = new TagEditDialog(tag, model);
					var result = dialog.run();
					var new_name = dialog.get_new_name();
					var rgba = dialog.get_rgba();
					dialog.destroy();
					if(result == Gtk.ResponseType.OK) {
							tag.set_name(new_name);
							tag.set_rgba(rgba);
							model._tags.sort((a, b) => {
								return a._name.collate(b._name);
							});
							model._accounts.foreach(a => {
								foreach(var expense in a._expenses) {
									expense._tags.sort((a, b) => {
										return a._name.collate(b._name);
									});
								}
								return true;
							});
							model.fire(TriggerType.GENERAL);
					}
				});
				menu.append(edit);
				var @delete = new Gtk.MenuItem.with_label(_("Delete"));
				@delete.activate.connect(() => {
					var prologue_len = "<b><span foreground=\"#11223344\" >".length;
					var epilogue_len = "</span></b>".length;
					var content_len = selected.length - (prologue_len + epilogue_len);
					var old_name = selected.slice(prologue_len, prologue_len + content_len);
					var md = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Do you really want to delete the tag %s?").printf(old_name));
					md.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("Delete"), Gtk.ResponseType.OK);
					if(md.run() == Gtk.ResponseType.OK) {
						this.model.remove_tag_by_name(old_name);
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
			if(key.keyval == Gdk.Key.Delete) {
				var prologue_len = "<b><span foreground=\"#11223344\" >".length;
				var epilogue_len = "</span></b>".length;
				var content_len = selected.length - (prologue_len + epilogue_len);
				var old_name = selected.slice(prologue_len, prologue_len + content_len);
				var md = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Do you really want to delete the tag %s?").printf(old_name));
				md.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("Delete"), Gtk.ResponseType.OK);
				if(md.run() == Gtk.ResponseType.OK) {
					this.model.remove_tag_by_name(old_name);
				}
				md.destroy();
			}
		}
	}
}
