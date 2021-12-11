using Json;

namespace LFinance {
	internal errordomain ParsingErrors {
		INVALID_DATA, KEY_MISSING, WRONG_TYPE;
		internal static void check_node(Json.Object root, string key, NodeType type) throws Error {
			if(!root.has_member(key)) {
				throw new ParsingErrors.KEY_MISSING("Key \"%s\" not found!", key);
			}
			var obj = root.get_member(key);
			if(obj.get_node_type() != type) {
				throw new ParsingErrors.WRONG_TYPE("Expected key \"%s\" to be an %s, but got an %s", key, type.to_string(), obj.get_node_type().to_string());
			}
		}
	}
	internal interface ModelBuilder : GLib.Object {
		internal abstract Model build() throws Error;
	}
	internal class ModelBuilderFactory {
		internal static ModelBuilder from_file(string file) throws Error {
			var parser = new Parser();
			parser.load_from_file(file);
			var node = parser.get_root();
			if(node == null || node.get_node_type() != NodeType.OBJECT) {
				throw new ParsingErrors.INVALID_DATA("No object found");
			}
			var root = node.get_object();
			if(root == null) {
				throw new ParsingErrors.INVALID_DATA("No JSON-object found");
			}
			ParsingErrors.check_node(root, "version", NodeType.VALUE);
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
