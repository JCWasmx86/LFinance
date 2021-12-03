namespace LFinance {
	class Constants {
		[CCode (cheader_filename="config.h", cname="APPLICATION_ID")]
		internal extern const string APPLICATION_ID;
		[CCode (cheader_filename="config.h", cname="PACKAGE_VERSION")]
		internal extern const string PACKAGE_VERSION;
		[CCode (cheader_filename="config.h", cname="APPLICATION_INSTALL_PREFIX")]
		internal extern const string APPLICATION_INSTALL_PREFIX;
	}
	internal class Colors {
		// From https://stackoverflow.com/a/20298027
		// and from the GNOME HIG(Starting at #E85EBE): https://developer.gnome.org/hig/reference/palette.html
		internal static string[] get_colors() {
			return """
				#000000
				#00FF00
				#0000FF
				#FF0000
				#01FFFE
				#FFA6FE
				#FFDB66
				#006401
				#010067
				#95003A
				#007DB5
				#FF00F6
				#FFEEE8
				#774D00
				#90FB92
				#0076FF
				#D5FF00
				#FF937E
				#6A826C
				#FF029D
				#FE8900
				#7A4782
				#7E2DD2
				#85A900
				#FF0056
				#A42400
				#00AE7E
				#683D3B
				#BDC6FF
				#263400
				#BDD393
				#00B917
				#9E008E
				#001544
				#C28C9F
				#FF74A3
				#01D0FF
				#004754
				#E56FFE
				#788231
				#0E4CA1
				#91D0CB
				#BE9970
				#968AE8
				#BB8800
				#43002C
				#DEFF74
				#00FFC6
				#FFE502
				#620E00
				#008F9C
				#98FF52
				#7544B1
				#B500FF
				#00FF78
				#FF6E41
				#005F39
				#6B6882
				#5FAD4E
				#A75740
				#A5FFD2
				#FFB167
				#009BFF
				#E85EBE
				#99C1F1
				#62A0EA
				#3584E4
				#1C71D8
				#1A5FB4
				#8FF0A4
				#57E389
				#33D17A
				#2EC27E
				#26A269
				#F9F06B
				#F8E45C
				#F6D32D
				#F5C211
				#E5A50A
				#FFBE6F
				#FFA348
				#FF7800
				#E66100
				#C64600
				#F66151
				#ED333B
				#E01B24
				#C01C28
				#A51D2D
				#DC8ADD
				#C061CB
				#9141AC
				#813D9C
				#613583
				#CDAB8F
				#B5835A
				#986A44
				#865E3C
				#63452C
				#FFFFFF
				#F6F5F4
				#DEDDDA
				#C0BFBC
				#9A9996
				#77767B
				#5E5C64
				#3D3846
				#241F31
			""".replace("\t\t\t\t", "").replace(" ", "").split("\n");
		}
	}
}
