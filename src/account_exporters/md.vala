namespace LFinance {
	internal errordomain MDExporterErrors {
		GENERIC_ERROR
	}

	internal class MDExporter : Exporter, GLib.Object {
		GLib.File file;
		Account? account;
		double max_frac = 3;
		uint curr_frac;

		internal MDExporter(string file) {
			this.file = GLib.File.new_for_path(file);
		}

		internal void export(Account account) throws GLib.Error {
			this.account = account;
			this.write_file();
			info("Done");
		}
		void write_file() throws GLib.Error {
			try {
				this.progress(_("Exporting to Markdown..."), curr_frac / max_frac);
				curr_frac++;
				FileIOStream iostream;
				var file = File.new_tmp("tpl_XXXXXX.md", out iostream);
				var os = iostream.output_stream;
				var dos = new DataOutputStream(os);
				dos.put_string(this.build());
				dos.close();
				this.progress(_("Success!"), curr_frac / max_frac);
				curr_frac++;
				this.progress(_("Copying output to %s...").printf(this.file.get_path()), curr_frac / max_frac);
				curr_frac++;
				file.copy(this.file, FileCopyFlags.OVERWRITE|FileCopyFlags.ALL_METADATA);
				this.progress(_("Finished!"), curr_frac / max_frac);
				curr_frac++;
			} catch(GLib.Error e) {
				info("%s", e.message);
				throw new MDExporterErrors.GENERIC_ERROR(e.message);
			}
		}
		string build() {
			var sb = new StringBuilder();
			sb.append(_("# Expenses for account %s").printf(this.account._name)).append("\n\n");
			sb.append("| %s    | %s     | %s    | %s    | %s    |\n".printf(_("Purpose"), _("Date"), _("Amount"), _("Location"), _("Tags")));
			sb.append("| :---: | :----: | :---: | :---: | :---: |\n");
			for(var i = 0; i < this.account._expenses.size; i++) {
				var expense = this.account._expenses[i];
				sb.append("|");
				sb.append(" %s |".printf(this.escape_md(expense._purpose)));
				sb.append(" %s |".printf(this.escape_md(expense._date.format("%x"))));
				sb.append(" %s |".printf(this.escape_md(expense.format_amount().replace("\u202f", " "))));
				if(expense._location != null) {
					sb.append(this.escape_md(expense._location._name));
					if(expense._location._city != null)
						sb.append(", ").append(this.escape_md(expense._location._city));
					sb.append(" |");
				} else {
					sb.append("/ |");
				}
				for(var j = 0; j < expense._tags.size; j++) {
					var tag = expense._tags[j];
					sb.append("`");
					sb.append(this.escape_md(tag._name));
					sb.append("`");
					if(j != expense._tags.size - 1)
						sb.append(", ");
				}
				sb.append("|\n");
			}
			return sb.str;
		}
		string escape_md(string input) {
			var builder = new StringBuilder.sized(input.length + 20);
			var map = new Gee.HashMap<string, string>();
			map["\\"] = "\\\\";
			map["`"] = "\\`";
			map["*"] = "\\*";
			map["_"] = "\\_";
			map["{"] = "\\{";
			map["}"] = "\\}";
			map["["] = "\\[";
			map["]"] = "\\]";
			map["<"] = "\\<";
			map[">"] = "\\>";
			map["("] = "\\(";
			map[")"] = "\\)";
			map["#"] = "\\#";
			map["+"] = "\\+";
			map["-"] = "\\-";
			map["."] = "\\.";
			map["!"] = "\\!";
			map["|"] = "\\|";
			for(var i = 0; i < input.length; i++) {
				var as_string = "%c".printf(input[i]);
				if(map.has_key(as_string)) {
					builder.append(map[as_string]);
				} else {
					builder.append_c(input[i]);
				}
			}
			return builder.str;
		}
	}
}
