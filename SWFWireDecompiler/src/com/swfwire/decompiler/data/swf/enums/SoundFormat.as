package com.swfwire.decompiler.data.swf.enums
{
	public class SoundFormat
	{
		public static const UNCOMPRESSED:String = 'uncompressed';
		public static const ADPCM:String = 'adpcm';
		public static const MP3:String = 'mp3';
		public static const UNCOMPRESSED_LITTLE_ENDIAN:String = 'uncompressedLittleEndian';
		public static const NELLYMOSER:String = 'nellymoser';
		public static const SPEEX:String = 'speex';
		
		public function IdFromString(string:String):int
		{
			var result:int = -1;
			switch(string)
			{
				case UNCOMPRESSED:
					result = 0;
					break;
				case ADPCM:
					result = 1;
					break;
				case MP3:
					result = 2;
					break;
				case UNCOMPRESSED_LITTLE_ENDIAN:
					result = 3;
					break;
				case NELLYMOSER:
					result = 4;
					break;
				case SPEEX:
					result = 11;
					break;
			}
			return result;
		}
		
		public function stringFromId(id:uint):String
		{
			var result:String = null;
			switch(id)
			{
				case 0:
					result = UNCOMPRESSED;
					break;
				case 1:
					result = ADPCM;
					break;
				case 2:
					result = MP3;
					break;
				case 3:
					result = UNCOMPRESSED_LITTLE_ENDIAN;
					break;
				case 4:
				case 5:
				case 6:
					result = NELLYMOSER;
					break;
				case 11:
					result = SPEEX;
					break;
			}
			return result;
		}
	}
}