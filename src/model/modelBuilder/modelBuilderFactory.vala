namespace MoneyWatch {
	internal errordomain ParsingErrors {
		INVALID_DATA
	}
	internal interface ModelBuilder : GLib.Object {
		internal abstract Model build();
	}
	internal class ModelBuilderFactory {
		internal static ModelBuilder from_file(string file) throws Error {
			var parser = new Json.Parser();
			parser.load_from_file(file);
			var node = parser.get_root();
			if(node == null || node.get_node_type() != Json.NodeType.OBJECT) {
				throw new ParsingErrors.INVALID_DATA("No object found");
			}
			var root = node.get_object();
			if(root == null || !root.has_member("version")) {
				throw new ParsingErrors.INVALID_DATA("No object	found or version not found");
			}
			var version = root.get_int_member("version");
			switch(version) {
				case 1:
					return new ModelV1Builder(root);
				case 2:
					return new ModelV2Builder(root);
				default:
					throw new ParsingErrors.INVALID_DATA("Invalid version: %lld".printf(version));
			}
		}
	}
}
