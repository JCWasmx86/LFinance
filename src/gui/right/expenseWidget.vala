namespace LFinance {
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
			} catch(Error e) {
				warning("Gtk.CssProvider::load_from_data failed: %s", e.message);
			}
			this.get_style_context().add_class("bordered");
			this.get_style_context().add_provider(provider, -1);
		}
		void connect_signals() {
			this.delete_button.clicked.connect(() => {
				var dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, _("Do you really want to delete expense \u201c%s\u201d?").printf(this.expense._purpose));
				dialog.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("Delete"), Gtk.ResponseType.OK);
				var result = dialog.run();
				if(result == Gtk.ResponseType.OK) {
					this.account.delete_expense(this.expense);
				}
				dialog.destroy();
			});
		}
		internal void rebuild(TriggerType? type) {
			if(type == TriggerType.ADD_LOCATION || type == TriggerType.DELETE_LOCATION || type == TriggerType.EDIT_LOCATION) {
				if(type == TriggerType.DELETE_LOCATION && this.location != null) {
					var loc = this.model.search_location_by_id(this.location.label);
					if(loc == null) { // Deleted
						this.tags_box.remove(this.location);
					}
				}
				this.edit.rebuild(type);
			} else if(type == TriggerType.ADD_TAG || type == TriggerType.DELETE_TAG || type == TriggerType.EDIT_TAG) {
				if(!this.tags.is_empty && type == TriggerType.DELETE_TAG) {
					for(var i = 0; i < this.tags.size; i++) {
						if(this.model.search_tag(this.tags[i].tag._name) == null) {
							this.tags_box.remove(this.tags[i]);
							this.tags.remove_at(i);
							i--;
						}
					}
				} else if(type == TriggerType.EDIT_TAG) {
					for(var i = 0; i < this.tags.size; i++) {
						this.tags[i].rebuild_if_necessary();
					}
				}
				this.edit.rebuild(type);
			} else if(type == TriggerType.EDIT_EXPENSE) {
				this.rebuild_if_necessary();
			} else {
				info("Unknown type, ignoring in ExpenseWidget: %s", type.to_string());
			}
		}
		internal void rebuild_if_necessary() {
			if(this.expense.format() != this.infos.label) {
				this.infos.label = this.expense.format();
			}
			if(this.expense._location == null && this.location != null) {
				this.tags_box.remove(this.location);
				this.location = null;
			} else if(this.expense._location != null && this.location == null) {
				this.location = new LocationButton(expense._location);
				this.tags_box.pack_start(this.location, false, true, 2);
				this.tags_box.reorder_child(this.location, 0);
				this.tags_box.show_all();
				if(this.tags_box.get_parent() == null) {
					this.pack_start(this.tags_box, false, true, 2);
					this.reorder_child(this.tags_box, 1);
					this.tags_box.show_all();
				}
			} else if(this.expense._location != null && this.location != null && this.location.label != null) {
				this.location.label = this.expense._location.id_string();
			}
			if(this.expense._tags.size > 0 && this.tags_box.get_parent() == null) {
				this.pack_start(this.tags_box, false, true, 2);
				this.reorder_child(this.tags_box, 1);
				this.tags_box.show_all();
			}
			var array = new bool[this.expense._tags.size];
			for(var i = 0; i < this.tags.size; i++) {
				if(expense.search_tag(this.tags[i].tag._name) == null) { // Removed
					this.tags_box.remove(this.tags[i]);
					this.tags.remove_at(i);
					i--;
				} else { // Edited
					this.tags[i].rebuild_if_necessary();
					var cnter = 0;
					foreach(var t in this.expense._tags) {
						if(t._name == this.tags[i].tag._name) {
							array[cnter] = true;
							break;
						}
						cnter++;
					}
				}
			}
			for(var i = array.length - 1; i >= 0; i--) {
				if(!array[i]) {
					this.tags_box.foreach(a => this.tags_box.remove(a));
					while(this.tags.size != 0)
						this.tags.remove_at(0);
					foreach(var t in this.expense._tags) {
						var btn = new TagButton(t);
						this.tags.add(btn);
						this.tags_box.pack_start(btn, false, true, 2);
					}
					break;
				}
			}
			this.tags_box.show_all();
		}
	}
}
