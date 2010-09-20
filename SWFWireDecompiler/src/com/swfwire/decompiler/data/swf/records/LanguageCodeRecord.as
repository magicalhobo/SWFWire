package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class LanguageCodeRecord implements IRecord
	{
		public static const LANGUAGE_CODE_LATIN:uint = 1;
		public static const LANGUAGE_CODE_JAPANESE:uint = 2;
		public static const LANGUAGE_CODE_KOREAN:uint = 3;
		public static const LANGUAGE_CODE_SIMPLIFIED_CHINESE:uint = 4;
		public static const LANGUAGE_CODE_TRADITIONAL_CHINESE:uint = 5;
		
		public var languageCode:uint;
	}
}