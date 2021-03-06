namespace LFinance {
	internal class EditWidget : Gtk.Box {
		Model model;
		Account account;
		Expense expense;
		// [Purpose][Amount][LocationComboBox]
		// [Calendar]
		// [Taglist][Addbutton]
		// [Save][Cancel]
		Gtk.Box first_line;
		Gtk.Entry purpose;
		Gtk.Entry amount;
		Gtk.ComboBoxText location_chooser;
		Gtk.Calendar second_line;
		Gtk.Box third_line;
		Gee.List<ExtendedTagButton> tags;
		Gtk.Button add_tag;
		Gtk.Box fourth_line;
		Gtk.Button edit;
		Gtk.Button cancel;
		internal EditWidget(Model model, Account account, Expense expense) {
			Object (orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			this.account = account;
			this.expense = expense;
			this.build_gui ();
			this.connect_signals ();
		}
		void build_gui() {
			this.build_first_line ();
			this.build_second_line ();
			this.build_third_line ();
			this.build_fourth_line ();
			this.show_all ();
		}
		void build_first_line() {
			this.first_line = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
			var buffer = new Gtk.EntryBuffer ();
			buffer.set_text (this.expense._purpose.data);
			this.purpose = new Gtk.Entry.with_buffer (buffer);
			this.first_line.pack_start (this.purpose, true, true, 2);
			buffer = new Gtk.EntryBuffer ();
			buffer.set_text ("%.2f".printf (this.expense._amount / 100.0).data);
			this.amount = new Gtk.Entry.with_buffer (buffer);
			this.first_line.pack_start (this.amount, true, true, 2);
			this.location_chooser = new Gtk.ComboBoxText ();
			this.location_chooser.append ("$$<<NU$$LL>>$$", "");
			foreach(var loc in model._locations) {
				this.location_chooser.append (loc.id_string (), loc.id_string ());
			}
			this.location_chooser.active_id = this.expense._location ==
							  null ? "$$<<NU$$LL>>$$" : this.expense._location.id_string ();
			this.first_line.pack_start (this.location_chooser, true, true, 2);
			this.pack_start (this.first_line, true, true, 2);
		}
		void build_second_line() {
			this.second_line = new Gtk.Calendar ();
			var date = expense._date;
			this.second_line.select_month (date.get_month () - 1, date.get_year ());
			this.second_line.select_day (date.get_day_of_month ());
			this.pack_start (this.second_line, true, true, 2);
		}

		void build_third_line() {
			this.tags = new Gee.ArrayList<ExtendedTagButton>();
			this.third_line = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
			this.add_tag = new Gtk.Button.from_icon_name ("list-add");
			this.third_line.pack_start (this.add_tag, true, true, 2);
			foreach(var tag in expense._tags) {
				var btn = new ExtendedTagButton (tag, this.account, this.expense, this.tags);
				this.tags.add (btn);
				this.third_line.pack_start (btn, false, false, 2);
			}
			this.pack_start (this.third_line, true, true, 2);
		}

		void build_fourth_line() {
			this.fourth_line = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
			this.edit = new Gtk.Button.with_label (_("Save edits"));
			this.edit.get_style_context ().add_class ("suggested-action");
			this.fourth_line.pack_start (this.edit, true, true, 2);
			this.cancel = new Gtk.Button.with_label (_("Reset changes"));
			this.cancel.get_style_context ().add_class ("destructive-action");
			this.fourth_line.pack_start (this.cancel, true, true, 2);
			this.pack_start (this.fourth_line, true, true, 2);
		}
		void connect_signals() {
			this.add_tag.clicked.connect (() => {
				this.show_tag_selection_dialog ();
			});
			this.purpose.changed.connect (() => {
				this.update_edit_button ();
			});
			this.amount.changed.connect (() => {
				this.update_edit_button ();
			});
			this.edit.clicked.connect (() => {
				this.expense.begin_edits ();
				this.expense.set_purpose (this.purpose.buffer.text);
				// FIXME: It's not always times 100
				this.expense.set_amount ((uint64)(double.parse (this.amount.buffer.text) * 100));
				var loc = this.location_chooser.get_active_text ();
				this.expense.set_location (loc == "" ? null : model.search_location_by_id (loc));
				uint year = 0;
				uint month = 0;
				uint day = 0;
				this.second_line.get_date (out year, out month, out day);
				month++;
				this.expense.set_date (new DateTime.local ((int)year, (int)month, (int)day, 0, 0, 0));
				while(this.expense._tags.size != 0) {
					this.expense._tags.remove_at (0);
				}
				foreach(var tag in this.tags) {
					this.expense._tags.add (tag.get_tag ());
				}
				this.expense.end_edits ();
				((Gtk.Expander) this.get_parent ()).set_expanded (false);
			});
			this.cancel.clicked.connect (() => {
				this.purpose.buffer.set_text (this.expense._purpose.data);
				// FIXME: It's not always the factor 100
				this.amount.buffer.set_text ("%.2f".printf (
								     this.expense._amount / 100.0).data);
				this.location_chooser.active_id = this.expense._location == null ? "$$<<NU$$LL>>$$" : this.expense._location.id_string ();
				var d = this.expense._date;
				this.second_line.select_month (d.get_month () - 1, d.get_year ());
				this.second_line.select_day (d.get_day_of_month ());
				foreach(var etb in this.tags) {
					this.third_line.remove (etb);
				}
				while(this.tags.size != 0) {
					this.tags.remove_at (0);
				}
				foreach(var tag in this.expense._tags) {
					var btn = new ExtendedTagButton (tag, this.account, this.expense, this.tags);
					this.tags.add (btn);
					this.third_line.pack_start (btn, false, false, 2);
				}
				this.third_line.show_all ();
				this.queue_draw ();
			});
		}
		void update_edit_button() {
			var pt = this.purpose.buffer.text;
			var at = this.amount.buffer.text;
			var set_active = pt.length != 0 && at.length != 0 && double.parse (at) > 0;
			this.edit.set_sensitive (set_active);
		}
		void show_tag_selection_dialog() {
			var dialog = new AddTagDialog (model, this.tags);
			var result = dialog.run ();
			if(result == Gtk.ResponseType.OK) {
				foreach(var radio in dialog.buttons) {
					if(radio.get_active ()) {
						var btn = new ExtendedTagButton (this.model.search_tag (
											 radio.label),
										 this.account,
										 this.expense,
										 this.tags);
						this.tags.add (btn);
						Gdk.threads_add_idle_full (Priority.HIGH_IDLE + 20,
									   () => {
							this.third_line.pack_start (btn, false, false, 2);
							this.third_line.show_all ();
							this.third_line.queue_draw ();
							return false;
						});
						break;
					}
				}
			}
			dialog.destroy ();
		}
		internal void rebuild(TriggerType type) {
			if(type == TriggerType.ADD_LOCATION || type == TriggerType.DELETE_LOCATION ||
			   type == TriggerType.EDIT_LOCATION) {
				this.location_chooser.remove_all ();
				this.location_chooser.append ("$$<<NU$$LL>>$$", "");
				var id = this.location_chooser.active_id;
				foreach(var loc in this.model._locations) {
					this.location_chooser.append (loc.id_string (), loc.id_string ());
				}
				if(!this.location_chooser.set_active_id (id)) { // Location was deleted
					this.location_chooser.active_id = this.expense._location ==
									  null ? "$$<<NU$$LL>>$$" : this.expense.
									  _location.id_string ();
				}
			} else if(type == TriggerType.DELETE_TAG) {
				for(var i = 0; i < this.tags.size; i++) {
					var btn = this.tags[i];
					if(this.model.search_tag (btn.get_tag ()._name) == null) { // Tag deleted
						this.tags.remove_at (i);
						this.third_line.remove (btn);
						i--;
					}
				}
			} else if(type == TriggerType.EDIT_TAG) {
				for(var i = 0; i < this.tags.size; i++) {
					var btn = this.tags[i];
					btn.rebuild_if_necessary ();
				}
			}
		}
	}
}
