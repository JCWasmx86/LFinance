namespace LFinance {
	internal errordomain ExporterErrors {
		EXTENSION_NOT_SUPPORTED
	}

	internal interface Exporter : Object {
		internal abstract void export (Account account) throws Error;
		internal signal void progress (string text, double frac);
	}

	internal class ExporterFactory {
		internal static Exporter? for_file (string file) throws Error {
			var dot = 0;
			for(var i = file.length; i >= 0; i--) {
				if(file[i] == '.') {
					dot = i;
					break;
				}
			}
			var extension = file.substring (dot + 1).down ();
			if(extension == "pdf") { // Search for LaTeX
				return new PDFExporter (file);
			}
			else if(extension == "md") {
				return new MDExporter (file);
			}
			else if(extension == "html") {
				throw new ExporterErrors.EXTENSION_NOT_SUPPORTED (_("Not implemented"));
			}
			else{
				throw new ExporterErrors.EXTENSION_NOT_SUPPORTED (_(
											  "Only .pdf, .md and .html are supported!"));
			}
		}
	}
}
