namespace MoneyWatch {
	internal class MoneyWatchPanel : Gtk.Box {
		BigList left;
		AccountInfo right;
		Model model;

		internal MoneyWatchPanel() {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 2);
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
			this.pack_start(left, true, true, 2);
			this.left.rebuild();
			this.right = new AccountInfo(model);
			this.pack_start(right, true, true, 2);
			this.right.rebuild();
			this.model.set_sharp(type => {
				this.left.rebuild();
				this.right.rebuild();
			});
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
		internal void rebuild() {
			this.foreach(e => this.remove(e));
			this.notebook = new Gtk.Notebook();
			this.pack_start(this.notebook, true, true, 2);
			if(this.model._accounts.size == 0)
				return;
			// Account was deleted
			if(!this.model.has_account(this.to_render))
				return;
			this.overview = new Overview(this.model, this.to_render);
			this.notebook.append_page(this.overview, new Gtk.Label(_("Overview")));
			this.expenses = new ExpenseList(this.model, this.to_render);
			this.notebook.append_page(this.expenses, new Gtk.Label(_("Expenses")));
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
	}
	internal class ExpenseList : ScrollBox {
		// [SortingOrder]
		// [Searchbar]
		// [Expander for extra infos]
		// [Expenselist]
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
					this.location_chooser.append(loc._name, loc._name);
				}
				this.location_chooser.active_id = expense._location == null ? "$$<<NU$$LL>>$$" : expense._location._name;
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
					
				});
				this.fourth_line.pack_start(this.edit, true, true, 2);
				this.cancel = new Gtk.Button.with_label(_("Reset changes"));
				this.cancel.get_style_context().add_class("destructive-action");
				this.cancel.clicked.connect(() => {
					
				});
				this.fourth_line.pack_start(this.cancel, true, true, 2);
				this.pack_start(this.fourth_line, true, true, 2);
			}
	}

	internal class ExtendedTagButton : Gtk.Box {
		internal ExtendedTagButton(Tag t, Account account, Expense expense) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 2);
			var label = new Gtk.Label("");
			var colors = t._rgba;
			label.label = "<b><span foreground=\"#%02x%02x%02x%02x\" >".printf(colors[0], colors[1], colors[2], colors[3]) + t._name + "</span></b>";
			this.pack_start(label, true, true, 2);
			var button = new Gtk.Button.from_icon_name("edit-delete");
			button.tooltip_text = _("Add Tag");
			this.pack_start(button, true, true, 2);
		}
	}

	internal class LocationButton : Gtk.Label {
		Location location;
		
		internal LocationButton(Location l) {
			this.location = l;
			this.label = "%s, %s".printf(l._name, l._city);
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
		internal BigList(Model model) {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 2);
			this.model = model;
		}
		internal void rebuild() {
			bool expanded_accounts = accounts == null ? false : accounts.get_expanded();
			bool expanded_locations = locations == null ? false : locations.get_expanded();
			bool expanded_tags = tags == null ? false : tags.get_expanded();
			this.foreach(e => this.remove(e));
			this.accounts = new Expander(_("Accounts"), new AccountActionHandler(this.model), "text", false);
			foreach(var account in model._accounts) {
				this.accounts.append_string(account._name);
			}
			this.accounts.set_expanded(expanded_accounts);
			this.pack_start(this.accounts, false, false, 2);
			this.locations = new Expander(_("Locations"), new LocationActionHandler(this.model), "text", false);
			foreach(var location in model._locations) {
				this.locations.append_string(location._name);
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
		}
	}
	internal class Expander : Gtk.Expander {
		TreeViewWithAction treeView;

		internal Expander(string s, ActionHandler handler, string type = "text", bool editable = true) {
			Object(label: s);
			this.treeView = new TreeViewWithAction(s, handler, type, editable);
			this.add(this.treeView);
		}
		internal void append_string(string val) {
			this.treeView.append_string(val);
		}
	}
	internal class TreeViewWithAction : Gtk.TreeView {
		Gtk.TreeIter tp;
		Gtk.ListStore store;

		internal TreeViewWithAction(string s, ActionHandler handler, string type =  "text", bool editable = true) {
			this.get_selection().set_mode(Gtk.SelectionMode.BROWSE);
			this.store = new Gtk.ListStore(1, GLib.Type.STRING);
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
				if(event.type == Gdk.EventType.@2BUTTON_PRESS)
					info("HERE"); // TODO: Mouse button
				var selected = this.get_selection();
				Gtk.TreeModel model;
				Gtk.TreeIter iter;
				selected.get_selected(out model, out iter);
				var val = Value(typeof(string));
				this.store.get_value(iter, 0, out val);
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
				if(handler.handle_edit((string)val, new_text))
					this.store.set_value(iter, 0, new_text);
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

		internal void append_string(string val) {
			this.store.insert_with_values(out tp, -1, 0, val, -1);
		}
	}
	interface ActionHandler : GLib.Object {
		// If true, accept the change, else reject
		internal abstract bool handle_edit(string old, string @new);
		internal abstract void handle_mouse_press(string selected, Gdk.EventButton event);
		internal abstract void handle_key_press(string selected, Gdk.EventKey key);
	}
	class AccountActionHandler : GLib.Object, ActionHandler {
		Model model;
		internal AccountActionHandler(Model model) {
			this.model = model;
		}
		bool handle_edit(string old, string @new) {
			warning("Didn't expect a call to AccountActionHandler::handle_edit!");
			return false; // Shouldn't be called
		}
		void handle_mouse_press(string selected, Gdk.EventButton event) {
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
		bool handle_edit(string old, string @new) {
			return true;
		}
		void handle_mouse_press(string selected, Gdk.EventButton event) {
			// On doubleclick open info window where it can be edited
			// Open in the AccountInfo
		}
		void handle_key_press(string selected, Gdk.EventKey key) {
			
		}
	}
	class TagActionHandler : GLib.Object, ActionHandler {
		Model model;
		internal TagActionHandler(Model model) {
			this.model = model;
		}
		bool handle_edit(string old, string @new) {
			// Extract ??? from <span...>???</span>
			return false;
		}
		void handle_mouse_press(string selected, Gdk.EventButton event) {
			// On doubleclick open info window where it can be edited
			// Open in the AccountInfo
		}
		void handle_key_press(string selected, Gdk.EventKey key) {
			
		}
	}
}
