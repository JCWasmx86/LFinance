namespace MoneyWatch {
	internal class EditWidget : Gtk.Box {
			// [Purpose][Amount][LocationComboBox]
			// [Calendar]
			// [Taglist][Addbutton]
			// [Save][Cancel]
			Model model;
			Account account;
			Expense expense;

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
				Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
				this.model = model;
				this.account = account;
				this.expense = expense;
				this.first_line = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
				var buffer = new Gtk.EntryBuffer();
				buffer.set_text(expense._purpose.data);
				this.purpose = new Gtk.Entry.with_buffer(buffer);
				this.first_line.pack_start(this.purpose, true, true, 2);
				buffer = new Gtk.EntryBuffer();
				buffer.set_text("%.2f".printf(expense._amount / 100.0).data);
				this.amount = new Gtk.Entry.with_buffer(buffer);
				this.first_line.pack_start(this.amount, true, true, 2);
				this.location_chooser = new Gtk.ComboBoxText();
				this.location_chooser.append("$$<<NU$$LL>>$$", "");
				foreach(var loc in model._locations) {
					this.location_chooser.append(loc.id_string(), loc.id_string());
				}
				this.location_chooser.active_id = expense._location == null ? "$$<<NU$$LL>>$$" : expense._location.id_string();
				this.first_line.pack_start(this.location_chooser, true, true, 2);
				this.pack_start(this.first_line, true, true, 2);
				this.second_line = new Gtk.Calendar();
				var date = expense._date;
				this.second_line.select_month(date.get_month() -1, date.get_year());
				this.second_line.select_day(date.get_day_of_month());
				this.pack_start(this.second_line, true, true, 2);
				this.tags = new Gee.ArrayList<ExtendedTagButton>();
				this.third_line = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
				this.add_tag = new Gtk.Button.from_icon_name("list-add");
				this.add_tag.clicked.connect(() => {
					this.show_tag_selection_dialog();
				});
				this.third_line.pack_start(this.add_tag, true, true, 2);
				foreach(var tag in expense._tags) {
					var btn = new ExtendedTagButton(tag, account, expense, this.tags);
					this.tags.add(btn);
					this.third_line.pack_start(btn, false, false, 2);
				}
				this.pack_start(this.third_line, true, true, 2);
				this.fourth_line = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
				this.edit = new Gtk.Button.with_label(_("Save edits"));
				this.edit.get_style_context().add_class("suggested-action");
				this.edit.clicked.connect(() => {
					expense.begin_edits();
					expense.set_purpose(this.purpose.buffer.text);
					// FIXME: It's not always times 100
					expense.set_amount((uint64)(double.parse(this.amount.buffer.text) * 100));
					var loc = this.location_chooser.get_active_text();
					expense.set_location(loc == "" ? null : model.search_location_by_id(loc));
					uint year = 0;
					uint month = 0;
					uint day = 0;
					this.second_line.get_date(out year, out month, out day);
					month++;
					expense.set_date(new DateTime.local((int)year, (int)month, (int)day, 0, 0, 0));
					while(expense._tags.size != 0)
						expense._tags.remove_at(0);
					foreach(var tag in this.tags) {
						expense._tags.add(tag.get_tag());
					}
					expense.end_edits();
				});
				this.fourth_line.pack_start(this.edit, true, true, 2);
				this.cancel = new Gtk.Button.with_label(_("Reset changes"));
				this.cancel.get_style_context().add_class("destructive-action");
				this.cancel.clicked.connect(() => {
					this.purpose.buffer.set_text(expense._purpose.data);
					// FIXME: It's not always the factor 100
					this.amount.buffer.set_text("%.2f".printf(expense._amount / 100.0).data);
					this.location_chooser.active_id = expense._location == null ? "$$<<NU$$LL>>$$" : expense._location.id_string();
					var d = expense._date;
					this.second_line.select_month(d.get_month() -1, d.get_year());
					this.second_line.select_day(d.get_day_of_month());
					foreach(var etb in this.tags) {
						this.third_line.remove(etb);
					}
					while(this.tags.size != 0)
						this.tags.remove_at(0);
					foreach(var tag in expense._tags) {
						var btn = new ExtendedTagButton(tag, account, expense, this.tags);
						this.tags.add(btn);
						this.third_line.pack_start(btn, false, false, 2);
					}
					this.third_line.show_all();
					this.queue_draw();
				});
				this.fourth_line.pack_start(this.cancel, true, true, 2);
				this.pack_start(this.fourth_line, true, true, 2);
			}
			void show_tag_selection_dialog() {
				var dialog = new AddTagDialog(model, this.tags);
				dialog.response.connect(response => {
					if(response == 0) {
						foreach(var radio in dialog.buttons) {
							if(radio.get_active()) {
								var btn = new ExtendedTagButton(model.search_tag(radio.label), account, expense, this.tags);
								this.tags.add(btn);
								Gdk.threads_add_idle_full(GLib.Priority.HIGH_IDLE + 20, () => {
									this.third_line.pack_start(btn, false, false, 2);
									this.third_line.show_all();
									this.third_line.queue_draw();
									return false;
								});
								break;
							}
						}
					}
					dialog.destroy();
				});
				dialog.run();
		}
	}
	internal class AddTagDialog : Gtk.Dialog {
		internal unowned SList<Gtk.RadioButton> buttons{internal get; private set;}

		internal AddTagDialog(Model model, Gee.List<ExtendedTagButton> tags) {
			this.title = _("Add tag");
			this.add_button(_("Add tag"), 0);
			this.add_button(_("Cancel"), 1);
			var b = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			this.buttons = new SList<Gtk.RadioButton>();
			foreach(var tag in model._tags) {
				bool found = false;
				foreach(var btn in tags) {
					if(tag._name == btn.get_tag()._name) {
						found = true;
						break;
					}
				}
				if(found)
					continue;
				var radio = new Gtk.RadioButton.with_label(buttons, tag._name);
				buttons.append(radio);
				b.add(radio);
			}
			var scr = new Gtk.ScrolledWindow(null, null);
			scr.add(b);
			this.get_content_area().pack_start(scr, true, true, 2);
			this.show_all();
		}
	}
}
