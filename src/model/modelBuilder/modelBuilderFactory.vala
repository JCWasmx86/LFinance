using Json;

namespace LFinance {
	internal errordomain ParsingErrors {
		INVALID_DATA, KEY_MISSING, WRONG_TYPE;
		internal static void check_node(Json.Object root, string key, NodeType type) throws Error {
			if(!root.has_member (key)) {
				throw new ParsingErrors.KEY_MISSING ("Key \"%s\" not found!", key);
			}
			var obj = root.get_member (key);
			if(obj.get_node_type () != type) {
				throw new ParsingErrors.WRONG_TYPE ("Expected key \"%s\" to be an %s, but got an %s",
								    key,
								    type.to_string (),
								    obj.get_node_type ().to_string ());
			}
		}
	}
	internal interface ModelBuilder : GLib.Object {
		internal abstract Model build () throws Error;
	}
	internal class ModelBuilderFactory {
		internal static ModelBuilder from_file(string file, string? password = "",
						       bool pwd = false) throws Error {
			Json.Node node;
			if(!pwd) {
				var parser = new Parser ();
				parser.load_from_file (file);
				node = parser.get_root ();
			} else {
				node = ModelBuilderFactory.decrypt_data (password);
			}
			if(node == null || node.get_node_type () != NodeType.OBJECT) {
				throw new ParsingErrors.INVALID_DATA ("No object found");
			}
			var root = node.get_object ();
			if(root == null) {
				throw new ParsingErrors.INVALID_DATA ("No JSON-object found");
			}
			ParsingErrors.check_node (root, "version", NodeType.VALUE);
			var version = root.get_int_member ("version");
			switch(version) {
			case 1:
				return new ModelV1Builder (root, password, pwd);
			case 2:
				return new ModelV2Builder (root, password, pwd);
			default:
				throw new ParsingErrors.INVALID_DATA ("Invalid version: %lld".printf (version));
			}
		}
		static Json.Node decrypt_data(string password) throws GLib.Error {
			var path = Environment.get_user_data_dir () + "/LFinance/data.json.enc";
			var file = File.new_for_path (path);
			var @in = file.read ();
			var dis = new DataInputStream (@in);
			dis.set_byte_order (DataStreamByteOrder.LITTLE_ENDIAN);
			dis.skip (10);
			var clear_text_len = dis.read_int32 ();
			var encrypted_text_len = dis.read_int32 ();
			var bytes = new uint8[encrypted_text_len];
			size_t read;
			dis.read_all (bytes, out read, null);
			var decrypted = decrypt (bytes, password);
			var sb = new StringBuilder.sized (clear_text_len);
			for(var i = 0; i < clear_text_len; i++) {
				// +4 for marker value
				sb.append_c ((char)decrypted[i + 4]);
			}
			var str = sb.str;
			var parser = new Parser ();
			parser.load_from_data (str, str.length);
			return parser.get_root ();
		}
		internal static bool encrypted_data() {
			var base_dir = Environment.get_user_data_dir () + "/LFinance/";
			if(!File.new_for_path (base_dir).query_exists ()) {
				return false;
			}
			var encrypted = base_dir + "data.json.enc";
			if(File.new_for_path (encrypted).query_exists ()) {
				return true;
			}
			return false;
		}
		internal static bool check_password(string password) throws GLib.Error {
			var path = Environment.get_user_data_dir () + "/LFinance/data.json.enc";
			var file = File.new_for_path (path);
			var @in = file.read ();
			var dis = new DataInputStream (@in);
			dis.set_byte_order (DataStreamByteOrder.LITTLE_ENDIAN);
			dis.skip (18);
			var bytes = new uint8[16];
			size_t read;
			dis.read_all (bytes, out read, null);
			var decrypted = decrypt (bytes, password);
			return decrypted[0] == 0xAA || decrypted[1] == 0xBB || decrypted[2] == 0xCC ||
			       decrypted[3] == 0xDD;
		}
	}
}
