namespace LFinance {
	namespace CryptoTest {
		static void main(string[] args) {
			Test.init(ref args);
			Test.add_func("/pwd_derivation_test", () => {
				CryptoTest.pwd_derivation_test();
			});
			Test.add_func("/encryption", () => {
				CryptoTest.encryption();
			});
			Test.add_func("/decryption", () => {
				CryptoTest.decryption();
			});
			Test.add_func("/decryption_fail", () => {
				CryptoTest.decryption_fail();
			});
			Test.run();
		}
		static void pwd_derivation_test() {
			var pwd = "reallySecurePassword";
			var derived = derive(pwd, pwd.data);
			info("Derived: %s", CryptoTest.format(derived));
			var derived2 = derive(pwd, pwd.data);
			info("Derived: %s", CryptoTest.format(derived2));
			assert(CryptoTest.format(derived) == CryptoTest.format(derived2));
			var derived3 = derive(pwd, pwd.data);
			info("Derived: %s", CryptoTest.format(derived3));
			var pwd2 = "otherPass";
			var derived4 = derive(pwd2, pwd2.data);
			info("Derived: %s", CryptoTest.format(derived4));
			assert(CryptoTest.format(derived3) != CryptoTest.format(derived4));
		}

		static void encryption() {
			var pwd = "reallySecurePassword";
			var encrypted = encrypt("data", pwd);
			info("Encrypted: %s", CryptoTest.format(encrypted));
			var encrypted2 = encrypt("data", pwd);
			info("Encrypted: %s", CryptoTest.format(encrypted2));
			assert(CryptoTest.format(encrypted) == CryptoTest.format(encrypted2));
			var pwd2 = "otherPass";
			var encrypted3 = encrypt("data", pwd);
			info("Encrypted: %s", CryptoTest.format(encrypted3));
			var encrypted4 = encrypt("data", pwd2);
			info("Encrypted: %s", CryptoTest.format(encrypted4));
			assert(CryptoTest.format(encrypted3) != CryptoTest.format(encrypted4));
		}

		static void decryption() {
			var pwd = "reallySecurePassword";
			var clear_text = "abcabcabcfoodatadata";
			var encrypted = encrypt(clear_text, pwd);
			info("Encrypted: %s", CryptoTest.format(encrypted));
			var decrypted = decrypt(encrypted, pwd);
			info("Decrypted: %s", CryptoTest.format(decrypted));
			var reconstructed = "";
			for(var i = 0; i < clear_text.length; i++)
				reconstructed += "%c".printf(decrypted[i]);
			info("Decrypted as string: %s", reconstructed);
			assert(reconstructed == clear_text);
		}
		static void decryption_fail() {
			var pwd = "reallySecurePassword";
			var clear_text = "abcabcabcfoodatadata";
			var encrypted = encrypt(clear_text, pwd);
			info("Encrypted: %s", CryptoTest.format(encrypted));
			var decrypted = decrypt(encrypted, pwd + "_fail");
			info("Decrypted: %s", CryptoTest.format(decrypted));
			var reconstructed = "";
			for(var i = 0; i < clear_text.length; i++)
				reconstructed += "%c".printf(decrypted[i]);
			info("Decrypted as string: %s", reconstructed);
			assert(reconstructed != clear_text);
		}

		string format(uint8[] data) {
			var sb = new StringBuilder.sized(data.length * 2);
			for(var i = 0; i < data.length; i++)
				sb.append("%02x".printf(data[i]));
			return sb.str;
		}
	}
}
