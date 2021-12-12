using GCrypt;

namespace LFinance {
	internal static uint8[] decrypt(uint8[] data, string password) {
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
		var len = (data.length / 16 + 1) * 16;
		uchar[] out_buffer = new uchar[len];
		error = cipher.decrypt(out_buffer, data);
		if(error != ErrorCode.NO_ERROR) {
			warning("Cipher::decrypt failed: %s", error.to_string());
			return new uint8[0];
		}
		return out_buffer;
	}
}
