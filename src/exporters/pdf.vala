namespace LFinance {
	internal errordomain PdfExporterErrors {
		COMMANDS_NOT_FOUND, PACKAGE_NOT_FOUND
	}

	internal class PDFExporter : Exporter, GLib.Object {
		GLib.File file;
		Account? account;
		string? working;

		internal PDFExporter(string file) {
			this.file = GLib.File.new_for_path(file);
		}

		internal void export(Account account) throws GLib.Error {
			this.account = account;
			this.search_for_latex();
			this.check_for_packages();
			this.write_file();
			info("Done");
		}
		void search_for_latex() throws GLib.Error {
			var latexes = new string[]{"latexmk", "pdflatex", "xelatex", "lualatex"};
			foreach(var latex in latexes) {
				var status = 0;
				try {
					Process.spawn_sync("/", new string[]{latex, "--version"}, Environ.get(), SpawnFlags.SEARCH_PATH, null, null, null, out status);
					if(status == 0) {
						info("Found command: %s", latex);
						this.working = latex;
						return;
					}
				} catch(SpawnError e) {
					info("%s", e.message);
				}
			}
			throw new PdfExporterErrors.COMMANDS_NOT_FOUND(_("Please install TexLive, LuaLaTeX or XeLaTeX")); // Throw exception
		}
		void write_file() throws GLib.Error {
			try {
				FileIOStream iostream;
				var file = File.new_tmp("tpl_XXXXXX.tex", out iostream);
				var os = iostream.output_stream;
				var dos = new DataOutputStream(os);
				dos.put_string(this.build());
				dos.close();
				this.compile_document(file, false);
				var path = file.get_path();
				var len = path.length;
				var replaced = path.splice(len - 4, len, ".pdf");
				GLib.File.new_for_path(replaced).copy(this.file, FileCopyFlags.OVERWRITE|FileCopyFlags.ALL_METADATA);
				this.cleanup(file, true);
			} catch(GLib.Error e) {
				info("%s", e.message);
			}
		}
		void check_for_packages() throws GLib.Error {
			this.check_for_package("longtable");
			this.check_for_package("xcolor");
			this.check_for_package("geometry");
			this.check_for_package("hyphenat");
		}
		void check_for_package(string name, bool cleanup_pdf = true) throws GLib.Error {
			try {
				FileIOStream iostream;
				var file = File.new_tmp("tpl_XXXXXX.tex", out iostream);
				var os = iostream.output_stream;
				var dos = new DataOutputStream(os);
				info("Testing package %s", name);
				dos.put_string("\\documentclass{article}\n");
				dos.put_string("\\usepackage{" + name + "}\n");
				dos.put_string("\\begin{document}\nHello World\n\\end{document}\n");
				dos.close();
				var status = this.compile_document(file, cleanup_pdf);
				if(status == 0) {
					info("Compiling using package %s succeeded!", name);
				} else {
					info("Failed to use package %s with status: %d", name, status);
					this.cleanup(file, cleanup_pdf);
					throw new PdfExporterErrors.PACKAGE_NOT_FOUND(_("Package not found: %s").printf(name));
				}
				this.cleanup(file, cleanup_pdf);
			} catch(GLib.Error e) {
				warning("%s", e.message);
				throw new PdfExporterErrors.PACKAGE_NOT_FOUND(e.message);
			}
		}
		void cleanup(GLib.File file, bool cleanup_pdf) {
			info("Cleaning temp files created after compiling %s", file.get_path());
			this.clean(file, ".aux");
			this.clean(file, ".fdb_latexmk");
			this.clean(file, ".fls");
			this.clean(file, ".log");
			this.clean(file, ".tex");
			if(cleanup_pdf)
				this.clean(file, ".pdf");
		}
		void clean(GLib.File file, string extension) {
			var path = file.get_path();
			var len = path.length;
			var replaced = path.splice(len - 4, len, extension);
			try {
				File.new_for_path(replaced).@delete();
			} catch(Error e) {
				info("Error deleting %s: %s", replaced, e.message);
			}
		}
		int compile_document(GLib.File file, bool cleanup_pdf = true) throws GLib.Error {
			var parent_dir = file.get_parent();
			var args = this.working == "latexmk" ? new string[]{this.working, "-pdf", file.get_path(), "-interaction=nonstopmode"} : new string[]{this.working, file.get_path(), "-interaction=nonstopmode"};
			var status = 0;
			string stderr;
			string stdout;
			Process.spawn_sync(parent_dir.get_path(), args, Environ.get(), SpawnFlags.SEARCH_PATH, null, out stdout, out stderr, out status);
			return status;
		}
		string build() {
			var builder = new StringBuilder.sized(500 * this.account._expenses.size);
			builder.append("\\documentclass{article}\n");
			builder.append("\\usepackage[a4paper, total={6in, 8in}]{geometry}\n");
			builder.append("\\usepackage{longtable}\n");
			builder.append("\\usepackage{xcolor}\n\n");
			builder.append("\\usepackage[none]{hyphenat}\n");
			builder.append("\\begin{document}\n");
			builder.append("\\begin{longtable}{|l|l|l|p{5cm}|}\n");
			builder.append("\\hline \\multicolumn{1}{|c|}{\\textbf{%s}} & \\multicolumn{1}{c|}{\\textbf{%s}} & \\multicolumn{1}{c|}{\\textbf{%s}} & \\multicolumn{1}{c|}{\\textbf{%s}} \\\\ \\hline \\endfirsthead\n".printf(_("Purpose"), _("Date"), _("Amount"), _("Further Information")));
			builder.append("\\hline \\multicolumn{4}{|r|}{{%s}} \\\\ \\hline \\endfoot\n".printf(_("Continued on the next page")));
			builder.append("\\hline \\hline \\endlastfoot\n");
			for(var i = 0; i < this.account._expenses.size; i++) {
				var expense = this.account._expenses[i];
				builder.append(this.escape_latex(expense._purpose));
				builder.append(" & ");
				builder.append(this.escape_latex(expense._date.format("%x")));
				builder.append(" & ");
				builder.append(this.escape_latex(expense.format_amount().replace("\u202f", " ")));
				builder.append(" & ");
				builder.append(this.build_extra_info(expense));
				if(i == this.account._expenses.size)
					builder.append("\\");
				else
					builder.append(" \\\\\n");
			}
			builder.append("\\end{longtable}\n");
			builder.append("\\end{document}\n");
			return builder.str;
		}
		string build_extra_info(Expense expense) {
			var ret = new StringBuilder();
			if(expense._location != null) {
				ret.append("\\textbf{");
				ret.append(this.escape_latex(expense._location._name));
				if(expense._location._city != null)
					ret.append(", ").append(this.escape_latex(expense._location._city));
				ret.append("}");
				if(expense._tags.size > 0)
					ret.append(", ");
			}
			for(var i = 0; i < expense._tags.size; i++) {
				var tag = expense._tags[i];
				ret.append("\\textcolor[RGB]{%u, %u, %u}{\\textbf{[".printf(tag._rgba[0], tag._rgba[1], tag._rgba[2]));
				ret.append(this.escape_latex(tag._name));
				ret.append("}]}\\allowbreak");
			}
			return ret.str == "" ? "" : ret.str;
		}
		string escape_latex(string input) {
			// Based on https://github.com/dangmai/escape-latex/blob/master/src/index.js
			var builder = new StringBuilder.sized(input.length + 20);
			var map = new Gee.HashMap<string, string>();
			map["{"] = "\\{";
			map["}"] = "\\}";
			map["\\"] = "\\textbackslash{}";
			map["#"] = "\\#";
			map["$"] = "\\$";
			map["%"] = "\\%";
			map["&"] = "\\&";
			map["^"] = "\\textasciicircum{}";
			map["_"] = "\\_";
			map["~"] = "\\textasciitilde{}";
			map["\t"] = "\\qquad{}";
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
