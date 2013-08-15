package com.swfwire.decompiler.data.swf3.records
{
	public class BlendModeRecord
	{
		public static const NORMAL1:int = 0;
		public static const NORMAL2:int = 1;
		public static const LAYER:int = 2;
		public static const MULTIPLY:int = 3;
		public static const SCREEN:int = 4;
		public static const LIGHTEN:int = 5;
		public static const DARKEN:int = 6;
		public static const DIFFERENCE:int = 7;
		public static const ADD:int = 8;
		public static const SUBTRACT:int = 9;
		public static const INVERT:int = 10;
		public static const ALPHA:int = 11;
		public static const ERASE:int = 12;
		public static const OVERLAY:int = 13;
		public static const HARDLIGHT:int = 14;
		
		public var blendMode:uint;
	}
}