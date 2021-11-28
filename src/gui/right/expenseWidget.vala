namespace MoneyWatch {
	internal class ExpenseWidget : Gtk.Box {
		// [About this expense][DeleteButton]
		// [Tags]
		// [Expander that expands to a widget that allows editing]
		Gtk.Box labelBox; // Contains location and then the tags
		Gtk.Box upperLabelBox;
		Gtk.Label infos;
		Gtk.Button delete_button;
		Gtk.Box tags_box;
		LocationButton location;
		Gee.List<TagButton> tags;
		Gtk.Expander expander;
		EditWidget edit;

		internal ExpenseWidget(Model model, Account account, Expense expense) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.tags = new Gee.ArrayList<TagButton>();
			this.labelBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			this.infos = new Gtk.Label(expense.format());
			this.upperLabelBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.upperLabelBox.pack_start(this.infos, true, true, 2);
			this.delete_button = new Gtk.Button.from_icon_name("edit-delete");
			this.delete_button.tooltip_text = _("Remove this expense");
			this.upperLabelBox.pack_start(this.delete_button, true, true, 2);
			this.tags_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			if(expense._location != null) {
				this.location = new LocationButton(expense._location);
				this.tags_box.pack_start(this.location, false, true, 2);
			}
			foreach(var t in expense._tags) {
				var btn = new TagButton(t);
				this.tags.add(btn);
				this.tags_box.pack_start(btn, false, true, 2);
			}
			this.pack_start(this.upperLabelBox, false, true, 2);
			if(expense._location != null || this.tags.size != 0) {
				this.pack_start(this.tags_box, false, true, 2);
			}
			this.expander = new Gtk.Expander(_("Edit"));
			this.edit = new EditWidget(model, account, expense);
			this.expander.add(this.edit);
			this.pack_start(this.expander, false, true, 2);
			var provider = new Gtk.CssProvider();
			try {
				provider.load_from_data("""
					.bordered {
						border: 1px solid #3F4747;
					}
				""");
			} catch(GLib.Error e) {
				warning("Gtk.CssProvider::load_from_data failed: %s", e.message);
			}
			this.get_style_context().add_class("bordered");
			this.get_style_context().add_provider(provider, -1);
			this.delete_button.clicked.connect(() => {
				var dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Do you really want to delete expense \u201c%s\u201d?").printf(expense._purpose));
				dialog.add_button(_("Delete"), 0);
				dialog.add_button(_("Cancel"), 1);
				var result = dialog.run();
				dialog.close();
				if(result == 0) {
					account.delete_expense(expense);
				}
			});
		}
	}
}
