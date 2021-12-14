using GCrypt;

namespace LFinance {
	internal uint8[] derive(string password,
				uint8[] salt) {
		var keybuffer = new uint8[32];
		GCrypt.KeyDerivation.derive (
			password.data,
			GCrypt.KeyDerivation.Algorithm.PBKDF2,
			GCrypt.Hash.Algorithm.SHA256,
			salt,
			1048576,
			keybuffer);
		return keybuffer;
	}
}
