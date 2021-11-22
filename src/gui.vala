namespace MoneyWatch {
	internal delegate void SelectAccountFunc(string name);

	internal class MoneyWatchPanel : Gtk.Box {
		BigList left;
		AccountInfo right;
		Model model;
		int obj;
		SelectAccountFunc func;

		internal MoneyWatchPanel() {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 2);
			this.obj = 0;
			var before = GLib.get_monotonic_time() / 1000000.0;
			var files = new string[]{GLib.Environment.get_home_dir() + "/.spendings.json",
										GLib.Environment.get_user_data_dir() + "/MoneyWatch/data.json"};
			if(GLib.FileUtils.test(files[1], GLib.FileTest.EXISTS)) {
				this.model = ModelBuilderFactory.from_file(files[1]).build();
			} else if(GLib.FileUtils.test(files[0], GLib.FileTest.EXISTS)) {
				this.model = ModelBuilderFactory.from_file(files[0]).build();
				try {
					File.new_for_path(GLib.Environment.get_user_data_dir() + "/MoneyWatch").make_directory_with_parents();
				} catch(Error e) {
					warning("Error creating directory: %s", e.message);
				}
			} else {
				this.model = new Model();
				try {
					File.new_for_path(GLib.Environment.get_user_data_dir() + "/MoneyWatch").make_directory_with_parents();
				} catch(Error e) {
					warning("Error creating directory: %s", e.message);
				}
			}
			var after = GLib.get_monotonic_time() / 1000000.0;
			info("Loaded JSON: %.2fs", (after - before));
			this.model.sort();
			this.left = new BigList(this.model);
			this.func = s => this.right.select(s);
			this.left.rebuild(func);
			this.pack_start(left, true, true, 2);
			this.right = new AccountInfo(model);
			this.right.rebuild();
			this.pack_start(this.right, true, true, 2);
			this.model.set_sharp(type => {
				this.rebuild();
			});
		}
		void rebuild() {
			info("Rebuilding GUI!");
			lock(obj) {
				this.left.rebuild(func);
				this.right.rebuild();
				Gdk.threads_add_idle_full(GLib.Priority.HIGH_IDLE + 20, () => {
					this.show_all();
					this.queue_draw();
					return false;
				});
			}
		}
		internal void save() {
			var generator = new Json.Generator();
			generator.set_root(this.model.serialize());
			generator.indent_char = '\t';
			generator.pretty = true;
			var date = new DateTime.now();
			var base_dir = GLib.Environment.get_user_data_dir() + "/MoneyWatch/";
			var save_dir = base_dir + "/%d/%d/%d".printf(date.get_year(), date.get_month(), date.get_day_of_month());
			try {
				File.new_for_path(save_dir).make_directory_with_parents();
			} catch(Error e) {
				warning("Error creating directory: %s", e.message);
			}
			var new_save_file = base_dir + "/data.json";
			var old_save_file = save_dir + "/%d_%d_%d.json".printf(date.get_hour(), date.get_minute(), date.get_second());
			try {
				info("Copying old save file to %s", old_save_file);
				File.new_for_path(new_save_file).copy(File.new_for_path(old_save_file), GLib.FileCopyFlags.OVERWRITE, null, null);
			} catch(Error e) {
				warning("Error copying file: %s", e.message);
			}
			generator.to_file(new_save_file);
		}
	}

	internal class AccountInfo : Gtk.Box {
		// The info is composed like this:
		// A GtkNotebook consisting of an Overview page, that
		// just gives some stats, allows editing the name and exporting to LaTeX
		// The second page is the list of expenses and button to add a new expense
		// The third page is with diagrams
		Model model;
		Gtk.Notebook notebook;
		Account to_render;
		Overview overview;
		ExpenseList expenses;

		internal AccountInfo(Model model) {
			this.model = model;
			if(model._accounts.size == 0)
				return;
			this.to_render = model._accounts[0];
		}
		internal void select(string account_name) {
			this.to_render = this.model.search_account(account_name);
			this.overview.select(this.to_render);
			this.expenses.select(this.to_render);
			Gdk.threads_add_idle_full(GLib.Priority.HIGH_IDLE + 20, () => {
				this.rebuild();
				this.show_all();
				return false;
			});
		}

		internal void rebuild() {
			if(this.notebook == null) {
				this.notebook = new Gtk.Notebook();
				this.pack_start(this.notebook, true, true, 2);
			}
			if(this.model._accounts.size == 0)
				return;
			// Account was deleted
			if(!this.model.has_account(this.to_render))
				return;
			if(this.overview == null) {
				this.overview = new Overview(this.model, this.to_render);
				this.notebook.append_page(this.overview, new Gtk.Label(_("Overview")));
			} else {
				this.overview.rebuild();
			}
			if(this.expenses == null) {
				this.expenses = new ExpenseList(this.model, this.to_render);
				this.notebook.append_page(this.expenses, new Gtk.Label(_("Expenses")));
			} else {
				this.expenses.rebuild();
			}
		}
	}
	internal class Overview : ScrollBox {
		// Gtk.Entry with the name On double click: editable=true, can_focus = true,
		// else editable = false, can_focus = false/true (TODO)
		// Number of expenses total + amount
		// Number of expenses last month + amount
		// Number of expenses last week + amount
		// Number of expenses last year + amount
		internal Overview(Model model, Account to_render) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
		}
		internal void rebuild() {
			
		}
		internal void select(Account to_render) {
			
		}
	}
	internal class ExpenseList : ScrollBox {
		// [SortingOrder]
		// [Searchbar with extra options]
		// [Expenselist]
		// [Add new expense]
		Model model;
		Account account;

		Gtk.Box header;
		Gtk.Label header_sort_label;
		Gtk.ComboBoxText header_sorting;
		Gtk.Box searchbar;
		Gtk.Box expenses;
		Gee.List<ExpenseWidget> widgets;

		internal ExpenseList(Model model, Account account) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			this.account = account;
			this.widgets = new Gee.ArrayList<ExpenseWidget>();
			this.header = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			this.header_sort_label = new Gtk.Label(_("Sort by:"));
			this.header_sorting = new Gtk.ComboBoxText();
			this.header_sorting.append("1", _("Amount"));
			this.header_sorting.append("2", _("Purpose"));
			this.header_sorting.append("3", _("Date"));
			this.header_sorting.append("4", _("Amount (Descending"));
			this.header_sorting.append("5", _("Purpose (Descending)"));
			this.header_sorting.append("6", _("Date (Descending)"));
			this.header_sorting.active_id = "%u".printf(account._sorting);
			this.header_sorting.changed.connect(() => {
				uint sorting = 0;
				this.header_sorting.active_id.scanf("%u", out sorting);
				this.account.set_sorting(sorting);
			});
			this.header.pack_start(this.header_sort_label, false, false, 2);
			this.header.pack_start(this.header_sorting, true, true, 2);
			this.pack_start(this.header, false, true, 2);
			this.expenses = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			foreach(var expense in this.account._expenses) {
				var widget = new ExpenseWidget(this.model, this.account, expense);
				this.widgets.add(widget);
				this.expenses.pack_start(widget, false, true, 2);
			}
			this.pack_start(this.expenses, false, true, 2);
		}
		internal void rebuild() {
			this.header_sorting.active_id = "%u".printf(account._sorting);
			this.widgets.foreach(a => {
				expenses.remove(a);
				return true;
			});
			this.widgets = new Gee.ArrayList<ExpenseWidget>();
			foreach(var expense in this.account._expenses) {
				var widget = new ExpenseWidget(this.model, this.account, expense);
				this.widgets.add(widget);
				this.expenses.pack_start(widget, false, true, 2);
			}
		}
		internal void select(Account to_render) {
			this.account = to_render;
		}
	}

	internal class ExpenseWidget : Gtk.Box {
		// [About this expense][DeleteButton]
		// [Tags]
		// [Expander that expands to a widget that allows editing]
		Gtk.Box toplevel;
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
			// TODO: Change this ugly color
			provider.load_from_data("""
				.bordered {
					border: 1px solid #3F4747;
				}
			""");
			this.name = "bordered";
			this.get_style_context().add_class("bordered");
			this.get_style_context().add_provider(provider, -1);
			this.delete_button.clicked.connect(() => {
				info("Deleting");
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
	
	internal class EditWidget : Gtk.Box {
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
				Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
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
				foreach(var tag in expense._tags) {
					var btn = new ExtendedTagButton(tag, account, expense);
					this.tags.add(btn);
					this.third_line.pack_start(btn, true, true, 2);
				}
				this.add_tag = new Gtk.Button.from_icon_name("list-add");
				this.third_line.pack_start(this.add_tag, true, true, 2);
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
					var new_tag_list = new Gee.ArrayList<Tag>();
					foreach(var tag in this.tags) {
						new_tag_list.add(tag.get_tag());
					}
					expense.set_tags(new_tag_list);
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
					this.tags = new Gee.ArrayList<ExtendedTagButton>();
					foreach(var tag in expense._tags) {
						var btn = new ExtendedTagButton(tag, account, expense);
						this.tags.add(btn);
						this.third_line.pack_start(btn, true, true, 2);
					}
					this.queue_draw();
				});
				this.fourth_line.pack_start(this.cancel, true, true, 2);
				this.pack_start(this.fourth_line, true, true, 2);
			}
	}

	internal class ExtendedTagButton : Gtk.Box {
		Tag tag;
		internal ExtendedTagButton(Tag t, Account account, Expense expense) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 2);
			this.tag = t;
			var label = new Gtk.Label("");
			var colors = t._rgba;
			label.label = "<b><span foreground=\"#%02x%02x%02x%02x\" >".printf(colors[0], colors[1], colors[2], colors[3]) + t._name + "</span></b>";
			this.pack_start(label, true, true, 2);
			var button = new Gtk.Button.from_icon_name("edit-delete");
			button.tooltip_text = _("Delete Tag");
			this.pack_start(button, true, true, 2);
		}
		internal Tag get_tag() {
			return this.tag;
		}
	}

	internal class LocationButton : Gtk.Label {
		Location location;
		
		internal LocationButton(Location l) {
			this.location = l;
			this.label = l.id_string();
			this.get_style_context().add_class("circular");
		}
	}
	internal class TagButton : Gtk.Label {
		Tag tag;
		internal TagButton(Tag t) {
			this.tag = t;
			var colors = t._rgba;
			this.label = "<b><span foreground=\"#%02x%02x%02x%02x\" >".printf(colors[0], colors[1], colors[2], colors[3]) + this.tag._name + "</span></b>";
			this.get_style_context().add_class("circular");
		}
	}
	internal class ScrollBox : Gtk.ScrolledWindow {
		public Gtk.Orientation orientation{get; set construct;}
		public int spacing{get; set construct;}
		protected Gtk.Box box;
		internal ScrollBox(Gtk.Orientation orientation, int spacing) {
			this.box = new Gtk.Box(orientation, spacing);
			this.add(this.box);
		}
		internal void pack_start(Gtk.Widget child, bool expand = true, bool fill = true, uint padding = 0) {
			if(this.box == null) {
				this.box = new Gtk.Box(orientation, spacing);
				this.add(this.box);
			}
			this.box.pack_start(child, expand, fill, padding);
		}
	}
	internal class BigList : ScrollBox {
		Model model;
		Expander accounts;
		Expander locations;
		Expander tags;
		AddPanel addButtons;

		internal BigList(Model model) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
		}
		internal void rebuild(SelectAccountFunc func) {
			bool expanded_accounts = accounts == null ? false : accounts.get_expanded();
			bool expanded_locations = locations == null ? false : locations.get_expanded();
			bool expanded_tags = tags == null ? false : tags.get_expanded();
			this.box.get_children().@foreach(a => {this.box.remove(a);});
			this.accounts = new Expander(_("Accounts"), new AccountActionHandler(func, this.model), "text", false);
			foreach(var account in model._accounts) {
				this.accounts.append_string(account._name);
			}
			this.accounts.set_expanded(expanded_accounts);
			this.pack_start(this.accounts, false, false, 2);
			this.locations = new Expander(_("Locations"), new LocationActionHandler(this.model), "text", false);
			foreach(var location in model._locations) {
				var n = location._name;
				var c = location._city;
				var n_c = (c == null || c == "") ? n : "%s, %s".printf(n, c);
				this.locations.append_string(n_c, location.id_string());
			}
			this.locations.set_expanded(expanded_locations);
			this.pack_start(this.locations, false, false, 2);
			this.tags = new Expander(_("Tags"), new TagActionHandler(this.model), "markup");
			foreach(var tag in model._tags) {
				var colors = tag._rgba;
				this.tags.append_string(
					"<b><span foreground=\"#%02x%02x%02x%02x\" >".printf(colors[0], colors[1], colors[2], colors[3]) + tag._name + "</span></b>");
			}
			this.tags.set_expanded(expanded_tags);
			this.pack_start(this.tags, false, false, 2);
			this.addButtons = new AddPanel(this.model);
			this.pack_start(this.addButtons, false, false, 2);
		}
	}
	internal class AddPanel : Gtk.Box {
		Model model;
		internal AddPanel(Model model) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
			var add_account = new Gtk.Button.with_label(_("Create Account"));
			add_account.clicked.connect(() => {
				var label = new Gtk.Label(_("Name:"));
				var entry = new Gtk.Entry();
				var dialog = new Gtk.Dialog.with_buttons(_("Create Account"), null, Gtk.DialogFlags.MODAL);
				dialog.add_button(_("Create Account"), 0);
				dialog.add_button(_("Cancel"), 1);
				dialog.get_content_area().pack_start(label, true, true, 2);
				dialog.get_content_area().pack_start(entry, true, true, 2);
				entry.changed.connect(() => {
					var btn = ((Gtk.Button)dialog.get_widget_for_response(0));
					if(entry.buffer.text.length == 0 || model.account_exists(entry.buffer.text)) {
						btn.set_sensitive(false);
					} else {
						btn.set_sensitive(true);
					}
				});
				((Gtk.Button)dialog.get_widget_for_response(0)).set_sensitive(false);
				dialog.show_all();
				var result = dialog.run();
				if(result == 0) {
					var text = entry.buffer.text;
					dialog.destroy();
					model.add_account(new Account(text));
				} else {
					dialog.destroy();
				}
			});
			this.pack_start(add_account, true, true, 2);
			var add_tag = new Gtk.Button.with_label(_("Create Tag"));
			add_tag.clicked.connect(() => {
				var label = new Gtk.Label(_("Name:"));
				var entry = new Gtk.Entry();
				var dialog = new Gtk.Dialog.with_buttons(_("Create Tag"), null, Gtk.DialogFlags.MODAL);
				dialog.add_button(_("Create Tag"), 0);
				dialog.add_button(_("Cancel"), 1);
				var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
				var list = new Gee.ArrayList<ColoredRadioButton>();
				var color_button = new Gtk.ColorButton();
				var custom_color = new CustomColorButton(list);
				custom_color.toggled.connect(() => {
					color_button.set_visible(custom_color.get_active());
				});
				color_button.color_set.connect(() => {
					var rgba = color_button.get_rgba();
					var r = (uint8)(255 * rgba.red);
					var g = (uint8)(255 * rgba.green);
					var b = (uint8)(255 * rgba.blue);
					var a = (uint8)(255 * rgba.alpha);
					custom_color.set_color("#%02x%02x%02x%02x".printf(r, g, b, a));
				});
				box.pack_start(custom_color, true, true, 2);
				list.add(custom_color);
				foreach(var c in Colors.get_colors()) {
					var c2 = c.strip();
					if(c2.length == 0)
						continue;
					var btn = new RecommendedColorButton(c2, list);
					btn.join_group(custom_color);
					list.add(btn);
					box.pack_start(btn, true, true, 2);
				}
				var scr = new Gtk.ScrolledWindow(null, null);
				scr.add(box);
				entry.changed.connect(() => {
					var text = _("Sample text");
					if(entry.buffer.text.length != 0)
						text = entry.buffer.text;
					foreach(var btn in list) {
						btn.set_text(text);
					}
					var btn = ((Gtk.Button)dialog.get_widget_for_response(0));
					if(entry.buffer.text.length == 0 || model.search_tag(entry.buffer.text) != null) {
						btn.set_sensitive(false);
					} else {
						btn.set_sensitive(true);
					}
				});
				dialog.get_content_area().pack_start(label, false, false, 2);
				dialog.get_content_area().pack_start(entry, false, false, 2);
				dialog.get_content_area().pack_start(scr, true, true, 2);
				dialog.get_content_area().pack_start(color_button, false, false, 2);
				((Gtk.Button)dialog.get_widget_for_response(0)).set_sensitive(false);
				// Hacky way to show all widgets
				dialog.resize(200, 600);
				dialog.show_all();
				GLib.Signal.emit_by_name(entry, "changed");
				var result = dialog.run();
				if(result == 0) {
					var name = entry.buffer.text;
					var color = "";
					foreach(var item in list) {
						if(((Gtk.RadioButton)item).get_active()) {
							color = item.get_color();
							break;
						}
					}
					var rgba = new uint8[4];
					color.scanf("#%02x%02x,02x02x", out rgba[0], out rgba[1], out rgba[2], out rgba[3]);
					model.add_tag(new Tag(name, rgba));
				}
				dialog.destroy();
			});
			this.pack_start(add_tag, true, true, 2);
			var add_location = new Gtk.Button.with_label(_("Create Location"));
			add_location.clicked.connect(() => {
				var name_l = new Gtk.Label(_("Name:"));
				var name = new Gtk.Entry();
				var city_l = new Gtk.Label(_("City:"));
				var city = new Gtk.Entry();
				var info_l = new Gtk.Label(_("Further information"));
				var info = new Gtk.TextView();
				var dialog = new Gtk.Dialog.with_buttons(_("Create Tag"), null, Gtk.DialogFlags.MODAL);
				dialog.add_button(_("Create Location"), 0);
				dialog.add_button(_("Cancel"), 1);
				dialog.get_content_area().pack_start(name_l, false, false, 2);
				dialog.get_content_area().pack_start(name, false, false, 2);
				dialog.get_content_area().pack_start(city_l, false, false, 2);
				dialog.get_content_area().pack_start(city, false, false, 2);
				dialog.get_content_area().pack_start(info_l, false, false, 2);
				dialog.get_content_area().pack_start(info, true, true, 2);
				name.changed.connect(() => {
					var btn = ((Gtk.Button)dialog.get_widget_for_response(0));
					if(name.buffer.text.length == 0 || model.search_location(name.buffer.text, city.buffer.text) != null) {
						btn.set_sensitive(false);
					} else {
						btn.set_sensitive(true);
					}
				});
				city.changed.connect(() => {
					var btn = ((Gtk.Button)dialog.get_widget_for_response(0));
					if(name.buffer.text.length == 0 || model.search_location(name.buffer.text, city.buffer.text) != null) {
						btn.set_sensitive(false);
					} else {
						btn.set_sensitive(true);
					}
				});
				// Hacky way to show all widgets
				dialog.resize(200, 400);
				((Gtk.Button)dialog.get_widget_for_response(0)).set_sensitive(false);
				dialog.show_all();
				var result = dialog.run();
				if(result == 0) {
					var name_ = name.buffer.text;
					var city_ = city.buffer.text;
					var info_ = info.buffer.text;
					dialog.destroy();
					model.add_location(new Location(name_, city_, info_));
				} else {
					dialog.destroy();
				}
			});
			this.pack_start(add_location, true, true, 2);
		}
	}
	internal interface ColoredRadioButton : GLib.Object {
		internal abstract string get_color();
		internal abstract void set_text(string s);
	}
	internal class CustomColorButton : ColoredRadioButton, Gtk.RadioButton {
		string color;
		internal CustomColorButton(Gee.List<ColoredRadioButton> list) {
			Object(group: null);
			this.label = _("Select your own color");
			this.color = "#FFFFFF";
		}
		internal string get_color() {
			return this.color;
		}
		internal void set_color(string color) {
			this.color = color;
			if(this.get_child() is Gtk.Label) {
				((Gtk.Label)this.get_child()).set_markup("<b><span color=\"%s\">%s</span></b>".printf(color, _("Select your own color")));
			}
		}
		internal void set_text(string text) {
			
		}
	}
	internal class RecommendedColorButton : ColoredRadioButton, Gtk.RadioButton {
		string color;
		internal RecommendedColorButton(string color, Gee.List<ColoredRadioButton> list) {
			Object(group: null, label: "foo");
			this.color = color;
			this.realize.connect(() => {
				if(this.get_child() is Gtk.Label) {
					((Gtk.Label)this.get_child()).set_markup("<b><span color=\"%s\">foo</span></b>".printf(color));
				}
			});
		}
		internal string get_color() {
			return this.color;
		}
		internal void set_text(string text) {
			if(this.get_child() is Gtk.Label) {
				((Gtk.Label)this.get_child()).set_markup("<b><span color=\"%s\">%s</span></b>".printf(color, text));
			}
		}
	}
	// Normal color: CheckButton.label.set_markup(...)
	// Let the user choose: CheckButton with label "Select" ColorButton

	internal class Expander : Gtk.Expander {
		TreeViewWithAction treeView;

		internal Expander(string s, ActionHandler handler, string type = "text", bool editable = true) {
			Object(label: s);
			this.treeView = new TreeViewWithAction(s, handler, type, editable);
			this.add(this.treeView);
		}
		internal void append_string(string val, string shadow = "") {
			this.treeView.append_string(val, shadow == null ? "" : shadow);
		}
	}
	internal class TreeViewWithAction : Gtk.TreeView {
		Gtk.TreeIter tp;
		Gtk.ListStore store;

		internal TreeViewWithAction(string s, ActionHandler handler, string type =  "text", bool editable = true) {
			this.get_selection().set_mode(Gtk.SelectionMode.BROWSE);
			this.store = new Gtk.ListStore(3, GLib.Type.STRING, GLib.Type.STRING, GLib.Type.STRING);
			this.hover_selection = true;
			this.enable_search = true;
			var column = new Gtk.TreeViewColumn();
			column.set_title(s);
			var renderer = new Gtk.CellRendererText();
			renderer.editable = editable;
			column.pack_start(renderer, true);
			column.add_attribute(renderer, type, 0);
			this.append_column(column);
			this.set_model(this.store);
			this.set_events(Gdk.EventMask.ALL_EVENTS_MASK | Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK);
			this.button_press_event.connect((event) => {
				var selected = this.get_selection();
				Gtk.TreeModel model;
				Gtk.TreeIter iter;
				selected.get_selected(out model, out iter);
				var val = Value(typeof(string));
				this.store.get_value(iter, 0, out val);
				var val2 = Value(typeof(string));
				// id_string
				this.store.get_value(iter, 1, out val2);
				info("Shadow: %s", (string)val2);
				handler.handle_mouse_press((string)val, event);
				return false;
			});
			renderer.edited.connect((path, new_text) => {
				GLib.stdout.printf("%s//%s\n", path, new_text);
				var selected = this.get_selection();
				Gtk.TreeModel model;
				Gtk.TreeIter iter;
				selected.get_selected(out model, out iter);
				var val = Value(typeof(string));
				this.store.get_value(iter, 0, out val);
				string out_val = "";
				if(handler.handle_edit((string)val, new_text, out out_val))
					this.store.set_value(iter, 0, out_val == null ? new_text : out_val);
			});
			this.key_release_event.connect_after((event) => {
				var selected = this.get_selection();
				Gtk.TreeModel model;
				Gtk.TreeIter iter;
				selected.get_selected(out model, out iter);
				var val = Value(typeof(string));
				this.store.get_value(iter, 0, out val);
				handler.handle_key_press((string)val, event);
				return false;
			});
		}

		internal void append_string(string val, string shadow = "") {
			var val1 = Value(typeof(string));
			var val2 = Value(typeof(string));
			val1.set_string(val);
			val2.set_string(shadow);
			this.store.insert_with_valuesv(out tp, -1, new int[]{0, 1}, new Value[]{val1, val2});
		}
	}
	interface ActionHandler : GLib.Object {
		// If true, accept the change, else reject
		internal abstract bool handle_edit(string old, string @new, out string replacement);
		internal abstract void handle_mouse_press(string selected, Gdk.EventButton event);
		internal abstract void handle_key_press(string selected, Gdk.EventKey key);
	}
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
			info("Account selected: %s", selected);
			this.func(selected);
			// Open in the AccountInfo
		}
		void handle_key_press(string selected, Gdk.EventKey key) {
			
		}
	}
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
			// On doubleclick open info window where it can be edited
			// Open in the AccountInfo
			if(event.type == Gdk.EventType.@2BUTTON_PRESS) {
				// Show window
			}
		}
		void handle_key_press(string selected, Gdk.EventKey key) {
			
		}
	}
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
			// On doubleclick open info window where it can be edited
			// If rightclick, show menu with "Delete"
		}
		void handle_key_press(string selected, Gdk.EventKey key) {
			
		}
	}
}
