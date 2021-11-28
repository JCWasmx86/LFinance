namespace MoneyWatch {
	internal class ExpenseWidget : Gtk.Box {
		Model model;
		Account account;
		Expense expense;
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
			this.model = model;
			this.account = account;
			this.expense = expense;
			this.build_gui();
			this.connect_signals();
			this.style_widget();
		}
		
		void build_gui() {
			this.build_first_line();
			this.build_tag_list();
			this.build_edit();
		}
		void build_first_line() {
			this.labelBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			this.infos = new Gtk.Label(this.expense.format());
			this.upperLabelBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.upperLabelBox.pack_start(this.infos, true, true, 2);
			this.delete_button = new Gtk.Button.from_icon_name("edit-delete");
			this.delete_button.tooltip_text = _("Remove this expense");
			this.upperLabelBox.pack_start(this.delete_button, true, true, 2);
			this.pack_start(this.upperLabelBox, false, true, 2);
		}
		void build_tag_list() {
			this.tags = new Gee.ArrayList<TagButton>();
			this.tags_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			if(expense._location != null) {
				this.location = new LocationButton(expense._location);
				this.tags_box.pack_start(this.location, false, true, 2);
			}
			foreach(var t in this.expense._tags) {
				var btn = new TagButton(t);
				this.tags.add(btn);
				this.tags_box.pack_start(btn, false, true, 2);
			}
			if(this.expense._location != null || this.tags.size != 0) {
				this.pack_start(this.tags_box, false, true, 2);
			}
		}
		void build_edit() {
			this.expander = new Gtk.Expander(_("Edit"));
			this.edit = new EditWidget(this.model, this.account, this.expense);
			this.expander.add(this.edit);
			this.pack_start(this.expander, false, true, 2);
		}
		void style_widget() {
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
		}
		void connect_signals() {
			this.delete_button.clicked.connect(() => {
				var dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Do you really want to delete expense \u201c%s\u201d?").printf(this.expense._purpose));
				dialog.add_button(_("Delete"), 0);
				dialog.add_button(_("Cancel"), 1);
				var result = dialog.run();
				if(result == 0) {
					this.account.delete_expense(this.expense);
				}
				dialog.destroy();
			});
		}
	}
}
