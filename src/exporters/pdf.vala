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
		double max_frac = 50;
		uint curr_frac = 0;
		string? working;

		internal PDFModelExporter(Model model, string file_name) {
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
				this.progress_update(_("Exporting to LaTeX..."), curr_frac / max_frac);
				curr_frac++;
				FileIOStream iostream;
				var file = File.new_tmp("tpl_XXXXXX.tex", out iostream);
				var os = iostream.output_stream;
				var dos = new DataOutputStream(os);
				dos.put_string(this.build());
				dos.close();
				this.progress_update(_("Compiling LaTeX..."), curr_frac / max_frac);
				curr_frac++;
				this.compile_document(file, false);
				this.progress_update(_("Success!"), curr_frac / max_frac);
				curr_frac++;
				var path = file.get_path();
				var len = path.length;
				var replaced = path.splice(len - 4, len, ".pdf");
				this.progress_update(_("Copying output to %s...").printf(this.file.get_path()), curr_frac / max_frac);
				curr_frac++;
				GLib.File.new_for_path(replaced).copy(this.file, FileCopyFlags.OVERWRITE|FileCopyFlags.ALL_METADATA);
				// this.cleanup(file, true);
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
			builder.append("\\usepackage{xcolor}\n\n");
			builder.append("\\usepackage[none]{hyphenat}\n");
			builder.append("\\title{%s}".printf(_("Accounting Report")));
			builder.append("\\author{%s}".printf(Environment.get_user_name()));
			builder.append("\\begin{document}\n");
			builder.append("\\maketitle");
			builder.append("\\end{document}\n");
			return builder.str;
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
						if(latex == "latexmk")
							this.max_frac -= 3;
						info("Found command: %s", latex);
						this.working = latex;
						return;
					}
				} catch(SpawnError e) {
					info("%s", e.message);
				}
			}
			throw new PDFModelExporterErrors.COMMANDS_NOT_FOUND(_("Please install TexLive, LuaLaTeX or XeLaTeX")); // Throw exception
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
				this.progress_update(_("Checking for package %s...").printf(name), this.curr_frac / this.max_frac);
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
		int compile_document(GLib.File file, bool cleanup_pdf = true) throws GLib.Error {
			var parent_dir = file.get_parent();
			var args = this.working == "latexmk" ? new string[]{this.working, "-pdf", file.get_path(), "-interaction=nonstopmode"} : new string[]{this.working, file.get_path(), "-interaction=nonstopmode"};
			var status = 0;
			string stderr;
			string stdout;
			Process.spawn_sync(parent_dir.get_path(), args, Environ.get(), SpawnFlags.SEARCH_PATH, null, out stdout, out stderr, out status);
			return status;
		}
		internal signal void progress_update(string to_add, double fraction);
	}
}
