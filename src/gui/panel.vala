namespace LFinance {
	internal class LFinancePanel : Gtk.Box {
		Gtk.Box left_box;
		BigList left;
		Gtk.Spinner spinner;
		AccountInfo right;
		Model model;
		int rebuild_lock;
		int save_lock;
		internal string password;
		SelectAccountFunc func;

		internal LFinancePanel(string password) throws Error {
			Object (orientation: Gtk.Orientation.HORIZONTAL, spacing: 2);
			this.rebuild_lock = 0;
			this.save_lock = 0;
			this.password = password;
			this.load_model ();
			this.build_gui ();
			this.model.set_sharp (type => {
				this.rebuild (type);
			});
		}
		void build_gui() {
			this.left_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
			this.func = s => this.right.select (s);
			this.left = new BigList (this.model);
			this.left.rebuild (null, func);
			this.spinner = new Gtk.Spinner ();
			this.left_box.pack_start (this.left, true, true, 2);
			this.left_box.pack_start (this.spinner, false, false, 2);
			this.pack_start (this.left_box, true, true, 2);

			this.right = new AccountInfo (this.model);
			this.right.rebuild (null);
			this.pack_start (this.right, true, true, 2);
			this.set_events (Gdk.EventMask.ALL_EVENTS_MASK);
		}

		void load_model() throws Error {
			var factor = 1000000.0;
			var before = get_monotonic_time () / factor;
			var data_dir = Environment.get_user_data_dir ();
			var files = new string[] {Environment.get_home_dir () + "/.spendings.json",
			    data_dir + "/LFinance/data.json", data_dir + "/LFinance/data.json.enc"};

			if(FileUtils.test (files[2], FileTest.EXISTS)) {
				this.model = ModelBuilderFactory.from_file (files[2], this.password, true).build ();
			}else if(FileUtils.test (files[1], FileTest.EXISTS)) {
				this.model = ModelBuilderFactory.from_file (files[1], this.password).build ();
			} else if(FileUtils.test (files[0], FileTest.EXISTS)) {
				this.model = ModelBuilderFactory.from_file (files[0], this.password).build ();
				try {
					File.new_for_path (data_dir + "/LFinance").make_directory_with_parents ();
				} catch(Error e) {
					warning ("Error creating directory: %s", e.message);
				}
			} else {
				this.model = new Model ();
				try {
					File.new_for_path (data_dir + "/LFinance").make_directory_with_parents ();
				} catch(Error e) {
					warning ("Error creating directory: %s", e.message);
				}
			}
			var after = get_monotonic_time () / factor;
			this.model.sort ();
			info ("Loaded JSON: %.2fs", (after - before));
		}

		void rebuild(TriggerType type) {
			info ("Rebuilding GUI!");
			lock (this.rebuild_lock) {
				this.left.rebuild (type, this.func);
				this.right.rebuild (type);
				Gdk.threads_add_idle_full (Priority.HIGH_IDLE + 20,
							   () => {
					this.left.show_all ();
					this.right.show_all ();
					this.queue_draw ();
					return false;
				});
			}
		}
		internal void save() throws Error {
			lock (this.save_lock) {
				var generator = new Json.Generator ();
				generator.set_root (this.model.serialize ());
				generator.indent_char = '\t';
				generator.pretty = true;
				var date = new DateTime.now ();
				var base_dir = Environment.get_user_data_dir () + "/LFinance/";
				var save_dir = base_dir + "/%d/%d/%d".printf (date.get_year (),
									      date.get_month (),
									      date.get_day_of_month ());
				try {
					File.new_for_path (save_dir).make_directory_with_parents ();
				} catch(Error e) {
					warning ("Error creating directory: %s", e.message);
				}
				var suffix = model.encrypted ? ".enc" : "";
				var new_save_file = base_dir + "/data.json" + suffix;
				var old_save_file = save_dir + "/%d_%d_%d.json%s".printf (
					date.get_hour (),
					date.get_minute (),
					date.get_second (),
					suffix);
				try {
					info ("Copying old save file to %s", old_save_file);
					File.new_for_path (new_save_file).copy (File.new_for_path (
											old_save_file),
										FileCopyFlags.OVERWRITE,
										null,
										null);
				} catch(Error e) {
					warning ("Error copying file: %s", e.message);
				}
				if(!model.encrypted) {
					generator.to_file (new_save_file);
				}
				else {
					try {
						var efw = new EncryptedFileWriter ();
						efw.write (File.new_for_path (new_save_file),
							   generator.to_gstring (
								   new StringBuilder ()).str,
							   model.password);
					} catch(Error e) {
						critical (e.message);
					}
				}
			}
		}

		internal override bool key_release_event(Gdk.EventKey key) {
			if((key.state & Gdk.ModifierType.CONTROL_MASK) != 0 &&
			   (key.keyval == Gdk.Key.s || key.keyval == Gdk.Key.S)) {
				this.spinner.start ();
				new Thread<void>("save",
						 () => {
					try {
						this.save ();
					} catch(Error e) {
						critical (e.message);
					}
					this.spinner.stop ();
				});
			}
			return true;
		}
		internal void export_all() {
			var dialog =
				new Gtk.FileChooserDialog (_("Export"),
							   null,
							   Gtk.FileChooserAction.SAVE,
							   _(
								   "_Cancel"),
							   Gtk.ResponseType.CANCEL,
							   _(
								   "Export"),
							   Gtk.ResponseType.OK);
			dialog.do_overwrite_confirmation = true;
			var result = dialog.run ();
			var file = dialog.get_filename ();
			dialog.destroy ();
			if(result == Gtk.ResponseType.OK) {
				var d = new ExportModelDialog (file, this.model);
				d.export ();
			}
		}
		internal bool already_encrypted() {
			return this.model.encrypted;
		}
		internal void setup_encryption() {
			var dialog = new EncryptionSetupDialog ();
			var r = dialog.run ();
			if(r == Gtk.ResponseType.OK) {
				var pwd = dialog.get_password ();
				this.model.secure (pwd);
				try {
					File.new_for_path (Environment.get_user_data_dir () +
							   "/LFinance/data.json").delete();
					this.save ();
				} catch(Error e) {
					warning (e.message);
				}
			}
			dialog.destroy ();
		}
	}
}
