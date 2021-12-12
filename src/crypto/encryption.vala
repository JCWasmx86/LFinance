using GCrypt;

namespace LFinance {
	internal static uint8[] encrypt(string data, string password) {
		var padded = data;
		while((padded.length % 32) != 0)
			padded += "$";
		Cipher.Cipher cipher;
		var error = Cipher.Cipher.open(out cipher, Cipher.Algorithm.AES256, Cipher.Mode.CBC, Cipher.Flag.SECURE);
		if(error != ErrorCode.NO_ERROR) {
			warning("Cipher::open failed: %s", error.to_string());
			return new uint8[0];
		}
		error = cipher.set_key(derive(password, password.data));
		if(error != ErrorCode.NO_ERROR) {
			warning("Cipher::set_key failed: %s", error.to_string());
			return new uint8[0];
		}
		// https://stackoverflow.com/a/3284136
		uchar[] out_buffer = new uchar[(padded.length / 16 + 1) * 16];
		error = cipher.encrypt(out_buffer, padded.data);
		if(error != ErrorCode.NO_ERROR) {
			warning("Cipher::set_key failed: %s", error.to_string());
			return new uint8[0];
		}
		return out_buffer;
	}
}
