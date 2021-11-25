namespace MoneyWatch {
	internal delegate void SelectAccountFunc(string name);

	internal class ExtendedTagButton : Gtk.Box {
		Tag tag;
		internal ExtendedTagButton(Tag t, Account account, Expense expense, Gee.List<ExtendedTagButton> btns) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 2);
			this.tag = t;
			var colors = t._rgba;
			var label = new Gtk.Label("");
			label.set_markup("<b><span foreground=\"#%02x%02x%02x%02x\" >".printf(colors[0], colors[1], colors[2], colors[3]) + t._name + "</span></b>");
			this.pack_start(label, false, false, 2);
			var button = new Gtk.Button.from_icon_name("edit-delete");
			button.tooltip_text = _("Delete Tag");
			button.clicked.connect(() => {
				var parent = this.get_parent();
				btns.remove(this);
				parent.remove(this);
			});
			this.pack_start(button, false, false, 2);
			var provider = new Gtk.CssProvider();
			provider.load_from_data("""
				.bordered {
					border: 1px solid #3F4747;
				}
			""");
			this.name = "bordered";
			this.get_style_context().add_class("bordered");
			this.get_style_context().add_provider(provider, -1);
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
			this.set_markup("<b><span foreground=\"#%02x%02x%02x%02x\" >".printf(colors[0], colors[1], colors[2], colors[3]) + this.tag._name + "</span></b>");
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
