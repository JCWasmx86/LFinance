namespace LFinance {
	internal class LFinancePanel : Gtk.Box {
		Gtk.Box left_box;
		BigList left;
		Gtk.Spinner spinner;
		AccountInfo right;
		Model model;
		int obj;
		int obj2;
		SelectAccountFunc func;

		internal LFinancePanel() throws Error {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 2);
			this.obj = 0;
			this.obj2 = 0;
			this.load_model();
			this.build_gui();
			this.model.set_sharp(type => {
				this.rebuild(type);
			});
		}
		void build_gui() {
			this.left_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			this.func = s => this.right.select(s);
			this.left = new BigList(this.model);
			this.left.rebuild(null, func);
			this.spinner = new Gtk.Spinner();
			this.left_box.pack_start(this.left, true, true, 2);
			this.left_box.pack_start(this.spinner, false, false, 2);
			this.pack_start(this.left_box, true, true, 2);

			this.right = new AccountInfo(model);
			this.right.rebuild(null);
			this.pack_start(this.right, true, true, 2);
			this.set_events(Gdk.EventMask.ALL_EVENTS_MASK);
		}

		void load_model() throws Error {
			var factor = 1000000.0;
			var before = get_monotonic_time() / factor;
			var data_dir = Environment.get_user_data_dir();
			var files = new string[]{Environment.get_home_dir() + "/.spendings.json",
										data_dir + "/LFinance/data.json"};
			if(FileUtils.test(files[1], FileTest.EXISTS)) {
				this.model = ModelBuilderFactory.from_file(files[1]).build();
			} else if(FileUtils.test(files[0], FileTest.EXISTS)) {
				this.model = ModelBuilderFactory.from_file(files[0]).build();
				try {
					File.new_for_path(data_dir + "/LFinance").make_directory_with_parents();
				} catch(Error e) {
					warning("Error creating directory: %s", e.message);
				}
			} else {
				this.model = new Model();
				try {
					File.new_for_path(data_dir + "/LFinance").make_directory_with_parents();
				} catch(Error e) {
					warning("Error creating directory: %s", e.message);
				}
			}
			var after = get_monotonic_time() / factor;
			this.model.sort();
			info("Loaded JSON: %.2fs", (after - before));
		}

		void rebuild(TriggerType type) {
			info("Rebuilding GUI!");
			lock(this.obj) {
				this.left.rebuild(type, func);
				this.right.rebuild(type);
				Gdk.threads_add_idle_full(Priority.HIGH_IDLE + 20, () => {
					this.left.show_all();
					this.right.show_all();
					this.queue_draw();
					return false;
				});
			}
		}
		internal void save() throws Error {
			lock(this.obj2) {
				var generator = new Json.Generator();
				generator.set_root(this.model.serialize());
				generator.indent_char = '\t';
				generator.pretty = true;
				var date = new DateTime.now();
				var base_dir = Environment.get_user_data_dir() + "/LFinance/";
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
					File.new_for_path(new_save_file).copy(File.new_for_path(old_save_file), FileCopyFlags.OVERWRITE, null, null);
				} catch(Error e) {
					warning("Error copying file: %s", e.message);
				}
				generator.to_file(new_save_file);
			}
		}

		internal override bool key_release_event(Gdk.EventKey key) {
			if((key.state & Gdk.ModifierType.CONTROL_MASK) != 0 && (key.keyval == Gdk.Key.s || key.keyval == Gdk.Key.S)) {
				this.spinner.start();
				new Thread<void>("save", () => {
					try {
						this.save();
					} catch(GLib.Error e) {
						critical(e.message);
					}
					this.spinner.stop();
				});
			}
			return true;
		}
		internal void export_all() {
			info("Export all");
			new PDFModelExporter(this.model, "test.pdf").export();
		}
	}
}
