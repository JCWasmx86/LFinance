namespace LFinance {
	internal class EncryptedFileWriter {
		internal void write(File file,
				    string data,
				    string password) throws Error {
			var ios = file.replace (null, false, FileCreateFlags.PRIVATE);
			var dos = new DataOutputStream (ios);
			dos.set_byte_order (DataStreamByteOrder.LITTLE_ENDIAN);
			dos.put_byte (0xEE);
			dos.put_byte ('N');
			dos.put_byte (0xCC);
			dos.put_byte ('R');
			dos.put_byte ('Y');
			dos.put_byte ('P');
			dos.put_byte ('T');
			dos.put_byte (0xEE);
			dos.put_byte ('D');
			dos.put_byte (0); // Version 0
			var clear_text_len = data.length;
			var new_data = new uint8[data.length + 4];
			new_data[0] = 0xAA;
			new_data[1] = 0xBB;
			new_data[2] = 0xCC;
			new_data[3] = 0xDD;
			Posix.memcpy (&new_data[4], data.data, data.data.length);
			var encrypted_bytes = encrypt (new_data, password);
			var encrypted_byte_len = encrypted_bytes.length;
			dos.set_byte_order (DataStreamByteOrder.LITTLE_ENDIAN);
			dos.put_int32 (clear_text_len);
			dos.put_int32 (encrypted_byte_len);
			dos.write (encrypted_bytes);
			dos.flush ();
		}
	}
}
