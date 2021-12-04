namespace LFinance {
	/*
	 * 1. Check for the command we will use to compile the document
	 * 2. Check for the required packages
	 * 3. Build the document.
	 * 4. Compile the document. If the command = "latexmk", then only once, otherwise five times
	 * 5. Copy generated .pdf file to real outputfile
	 * 5. Remove all tmp files
	 */
	internal class PDFModelExporter {
		GLib.File file;
		
		internal PDFModelExporter(Model model, string file_name) {
			this.file = GLib.File.new_for_path(file_name);
		}
		
		internal signal void progress_update(string to_add, double fraction);
	}
}
