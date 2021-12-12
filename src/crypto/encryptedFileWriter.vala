namespace LFinance {
	internal class EncryptedFileWriter {
		internal void write(File file, string data, string password) throws Error {
			var ios = file.replace(null, false, FileCreateFlags.PRIVATE);
			var dos = new DataOutputStream(ios);
			dos.set_byte_order(DataStreamByteOrder.LITTLE_ENDIAN);
			dos.put_byte(0xEE);
			dos.put_byte('N');
			dos.put_byte(0xCC);
			dos.put_byte('R');
			dos.put_byte('Y');
			dos.put_byte('P');
			dos.put_byte('T');
			dos.put_byte(0xEE);
			dos.put_byte('D');
			dos.put_byte(0); // Version 0
			var clear_text_len = data.length;
			var encrypted_bytes = encrypt(data, password);
			var encrypted_byte_len = encrypted_bytes.length;
			dos.set_byte_order(DataStreamByteOrder.LITTLE_ENDIAN);
			dos.put_int32(clear_text_len);
			dos.put_int32(encrypted_byte_len);
			dos.write(encrypted_bytes);
			dos.flush();
		}
	}
}
