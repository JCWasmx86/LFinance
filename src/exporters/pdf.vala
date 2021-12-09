namespace LFinance {
	internal errordomain PDFModelExporterErrors {
		COMPILATION_FAILED, COMMANDS_NOT_FOUND, PACKAGE_NOT_FOUND
	}
	/*
	 * 1. Check for the command we will use to compile the document
	 * 2. Check for the required packages
	 * 3. Build the document.
	 * 4. Compile the document. If the command = "latexmk", then only once, otherwise five(?) times
	 * 5. Copy generated .pdf file to real outputfile
	 * 5. Remove all tmp files
	 */
	internal class PDFModelExporter {
		GLib.File file;
		Model model;

		double max_frac = 19;
		uint curr_frac = 0;
		string? working;

		internal PDFModelExporter(Model model, string file_name) {
			this.model = model;
			this.file = GLib.File.new_for_path(file_name);
		}
		internal void export() throws GLib.Error {
			this.search_for_latex();
			// longtable, xcolor, geometry, hyphenat, tikz, pdfplots
			this.check_for_packages();
			this.write_file();
			info("Done");
		}
		void write_file() throws GLib.Error {
			try {
				this.progress_update(_("Exporting to LaTeX…"), curr_frac / max_frac);
				curr_frac++;
				FileIOStream iostream;
				var file = File.new_tmp("tpl_XXXXXX.tex", out iostream);
				var os = iostream.output_stream;
				var dos = new DataOutputStream(os);
				dos.put_string(this.build());
				dos.close();
				this.progress_update(_("Compiling LaTeX…"), curr_frac / max_frac);
				curr_frac++;
				this.compile_document_multiple_times(file);
				this.progress_update(_("Compiled LaTeX successfully"), curr_frac / max_frac);
				curr_frac++;
				var path = file.get_path();
				var len = path.length;
				var replaced = path.splice(len - 4, len, ".pdf");
				this.progress_update(_("Copying output to %s…").printf(this.file.get_path()), curr_frac / max_frac);
				curr_frac++;
				GLib.File.new_for_path(replaced).copy(this.file, FileCopyFlags.OVERWRITE|FileCopyFlags.ALL_METADATA);
				this.progress_update(_("Finished!"), curr_frac / max_frac);
				curr_frac++;
			} catch(GLib.Error e) {
				info("%s", e.message);
				throw new PdfExporterErrors.COMPILATION_FAILED(e.message);
			}
		}
		string build() {
			var builder = new StringBuilder.sized(50000);
			builder.append("\\documentclass{article}\n");
			builder.append("\\usepackage[a4paper, total={6in, 8in}]{geometry}\n");
			builder.append("\\usepackage{longtable}\n");
			builder.append("\\usepackage[utf8]{inputenc}\n");
			builder.append("\\usepackage{xcolor}\n");
			builder.append("\\usepackage{pgfplots}\n");
			builder.append("\\usepackage{tikz}\n");
			builder.append("\\usepackage[none]{hyphenat}\n\n");
			builder.append("\\usepgfplotslibrary{dateplot}\n");
			builder.append("\\title{%s}".printf(_("Accounting Report")));
			builder.append("\\author{%s}".printf(Environment.get_user_name()));
			builder.append("\\begin{document}\n");
			builder.append("\\def\\monthnames{{1,2,3,4,5,6,7,8,9,10,11,12}}\n");
			builder.append("\\maketitle\n\\newpage\n\\tableofcontents\n\\newpage\n");
			foreach(var account in this.model._accounts) {
				var copy = account.sorted_copy();
				builder.append(generate_for_account(copy));
			}
			builder.append("\\end{document}\n");
			info("\n%s", builder.str);
			return builder.str;
		}
		string generate_for_account(Account account) {
			var builder = new StringBuilder.sized(800 * account._expenses.size);
			builder.append("\\section{Account: %s}\n".printf(account._name));
			builder.append("\\begin{longtable}{|l|l|l|p{5cm}|}\n");
			builder.append("\\hline \\multicolumn{1}{|c|}{\\textbf{%s}} & \\multicolumn{1}{c|}{\\textbf{%s}} & \\multicolumn{1}{c|}{\\textbf{%s}} & \\multicolumn{1}{c|}{\\textbf{%s}} \\\\ \\hline \\endfirsthead\n".printf(_("Purpose"), _("Date"), _("Amount"), _("Further Information")));
			builder.append("\\hline \\multicolumn{4}{|r|}{{%s}} \\\\ \\hline \\endfoot\n".printf(_("Continued on the next page")));
			builder.append("\\hline \\hline \\endlastfoot\n");
			for(var i = 0; i < account._expenses.size; i++) {
				var expense = account._expenses[i];
				builder.append(this.escape_latex(expense._purpose));
				builder.append(" & ");
				builder.append(this.escape_latex(expense._date.format("%x")));
				builder.append(" & ");
				builder.append(this.escape_latex(expense.format_amount().replace("\u202f", " ")));
				builder.append(" & ");
				builder.append(this.build_extra_info(expense));
				if(i == account._expenses.size)
					builder.append("\\");
				else
					builder.append(" \\\\\n");
			}
			builder.append("\\end{longtable}\n");
			builder.append("\\subsection{%s}\n".printf(_("Diagrams")));
			var stats = new Stats(account._expenses);
			this.build_last_week(builder, stats);
			this.build_last_month(builder, stats);
			this.build_last_year(builder, stats);
			this.build_total(builder, stats);
			return builder.str;
		}
		void generate_expense_diagram(StringBuilder builder, Range r, string time) {
			// TODO: The averages seem to be wrong
			builder.append("\\subsubsection{%s}\n".printf(time));
			builder.append("\\begin{tikzpicture}[baseline]\n");
			builder.append("\\begin{axis}[x tick label style={rotate=45,anchor=east},legend style={at={(0.5,1.1)},anchor=south},width=\\textwidth,height=\\axisdefaultheight, date coordinates in=x, xticklabel=\\month-\\day,");
			builder.append("xmin=").append(this.latexify_date(r.start_date)).append(",xmax=").append(this.latexify_date(r.end_date));
			builder.append(",ymin=0,ymax=").append("%lf".printf(r.max_expense_value * 1.05)).append(",date ZERO=").append(this.latexify_date(r.start_date));
			builder.append("]\n");
			builder.append("\\addplot[smooth,red] coordinates {");
			for(var i = 0; i < r.each_expense.size; i++) {
				builder.append("(%s, %lf)\n".printf(this.latexify_date(r.dates[i]), r.each_expense[i]));
			}
			builder.append("};\n");
			builder.append("\\addplot[smooth,blue] coordinates {");
			builder.append("(%s, %lf)".printf(this.latexify_date(r.dates[0]), r.average_per_day));
			builder.append("(%s, %lf)".printf(this.latexify_date(r.dates[r.dates.size - 1]), r.average_per_day));
			builder.append("};\n");
			builder.append("\\legend {").append(_("Amount")).append(",").append(_("Average Amount")).append("}\n");
			builder.append("\\end{axis}");
			builder.append("\\end{tikzpicture}\n\\newline");
			builder.append("\\begin{tikzpicture}[baseline]\n");
			builder.append("\\begin{axis}[x tick label style={rotate=45,anchor=east},legend style={at={(0.5,1.1)},anchor=south},width=\\textwidth,height=\\axisdefaultheight, date coordinates in=x, xticklabel=\\month-\\day,");
			builder.append("xmin=").append(this.latexify_date(r.start_date)).append(",xmax=").append(this.latexify_date(r.end_date));
			builder.append(",ymin=0,ymax=").append("%lf".printf(r.accumulated[r.accumulated.size - 1] * 1.05)).append(",date ZERO=").append(this.latexify_date(r.start_date));
			builder.append("]\n");
			builder.append("\\addplot[smooth,red] coordinates {");
			for(var i = 0; i < r.accumulated.size; i++) {
				builder.append("(%s, %lf)\n".printf(this.latexify_date(r.dates[i]), r.accumulated[i]));

			}
			builder.append("};\n");
			builder.append("\\addplot[smooth,blue] coordinates {");
			builder.append("(%s, %lf)".printf(this.latexify_date(r.dates[0]), r.accumulated[0]));
			builder.append("(%s, %lf)".printf(this.latexify_date(r.dates[r.dates.size - 1]), r.accumulated[r.accumulated.size - 1]));
			builder.append("};\n");
			builder.append("\\legend {").append(_("Accumulated Amount")).append(",").append(_("Average amount per day")).append("}\n");
			builder.append("\\end{axis}");
			builder.append("\\end{tikzpicture}\n");
		}
		void build_last_week(StringBuilder builder, Stats stats) {
			var r = stats.last_week;
			this.generate_expense_diagram(builder, r, _("Last week"));
		}
		void build_last_month(StringBuilder builder, Stats stats) {
			var r = stats.last_month;
			if(r.dates.size == stats.last_week.dates.size)
				return;
			this.generate_expense_diagram(builder, r, _("Last month"));
		}
		void build_last_year(StringBuilder builder, Stats stats) {
			var r = stats.last_year;
			if(r.dates.size == stats.last_month.dates.size)
				return;
			this.generate_expense_diagram(builder, r, _("Last year"));
		}
		void build_total(StringBuilder builder, Stats stats) {
			var r = stats.total;
			if(r.dates.size == stats.last_year.dates.size)
				return;
			this.generate_expense_diagram(builder, r, _("All time"));
		}
		string latexify_date(GLib.DateTime time) {
			return "%d-%d-%d".printf(time.get_year(), time.get_month(), time.get_day_of_month());
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
		void search_for_latex() throws GLib.Error {
			var latexes = new string[]{"latexmk", "pdflatex", "xelatex", "lualatex"};
			foreach(var latex in latexes) {
				var status = 0;
				try {
					Process.spawn_sync("/", new string[]{latex, "--version"}, Environ.get(), SpawnFlags.SEARCH_PATH, null, null, null, out status);
					if(status == 0) {
						this.progress_update(_("Found command: %s").printf(latex), this.curr_frac / this.max_frac);
						this.curr_frac++;
						if(latex != "latexmk")
							this.max_frac += 8; // Latexmk needs only one round
						info("Found command: %s", latex);
						this.working = latex;
						return;
					}
				} catch(SpawnError e) {
					info("%s", e.message);
				}
			}
			throw new PDFModelExporterErrors.COMMANDS_NOT_FOUND(_("Please install TexLive, LuaLaTeX or XeLaTeX"));
		}
		void check_for_packages() throws GLib.Error {
			this.check_for_package("longtable");
			this.check_for_package("xcolor");
			this.check_for_package("geometry");
			this.check_for_package("hyphenat");
			this.check_for_package("tikz");
			this.check_for_package("pgfplots");
		}
		void check_for_package(string name) throws GLib.Error {
			try {
				this.progress_update(_("Checking for package %s…").printf(name), this.curr_frac / this.max_frac);
				this.curr_frac++;
				FileIOStream iostream;
				var file = File.new_tmp("tpl_XXXXXX.tex", out iostream);
				var os = iostream.output_stream;
				var dos = new DataOutputStream(os);
				info("Testing package %s", name);
				dos.put_string("\\documentclass{article}\n");
				dos.put_string("\\usepackage{" + name + "}\n");
				dos.put_string("\\begin{document}\nHello World\n\\end{document}\n");
				dos.close();
				var status = this.compile_document(file);
				if(status == 0) {
					info("Compiling using package %s succeeded!", name);
				} else {
					info("Failed to use package %s with status: %d", name, status);
					this.cleanup(file);
					throw new PdfExporterErrors.PACKAGE_NOT_FOUND(_("Package not found: %s").printf(name));
				}
				this.progress_update(_("Found package %s!").printf(name), this.curr_frac / this.max_frac);
				this.curr_frac++;
				this.cleanup(file);
			} catch(GLib.Error e) {
				warning("%s", e.message);
				throw new PdfExporterErrors.PACKAGE_NOT_FOUND(e.message);
			}
		}
		void cleanup(GLib.File file, bool cleanup_pdf = true) {
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
		int compile_document(GLib.File file) throws GLib.Error {
			var parent_dir = file.get_parent();
			var args = this.working == "latexmk" ? new string[]{this.working, "-pdf", file.get_path(), "-interaction=nonstopmode"} : new string[]{this.working, file.get_path(), "-interaction=nonstopmode"};
			var status = 0;
			string stderr;
			string stdout;
			Process.spawn_sync(parent_dir.get_path(), args, Environ.get(), SpawnFlags.SEARCH_PATH, null, out stdout, out stderr, out status);
			return status;
		}
		void compile_document_multiple_times(GLib.File file) throws GLib.Error {
			var n = this.working == "latexmk" ? 1 : 5;
			for(var i = 1; i <= n; i++) {
				this.progress_update(_("Round %u of %u…").printf(i, n), curr_frac / max_frac);
				curr_frac++;
				this.compile_document(file);
				this.progress_update(_("Success!"), curr_frac / max_frac);
				curr_frac++;
			}
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
		internal signal void progress_update(string to_add, double fraction);
	}
}
