package com.swfwire.decompiler.data.swf3.enums
{
	public class BlendModeEnum
	{
		public static const NORMAL:String = 'normal';
		public static const LAYER:String = 'layer';
		public static const MULTIPLY:String = 'multiply';
		public static const SCREEN:String = 'screen';
		public static const LIGHTEN:String = 'lighten';
		public static const DARKEN:String = 'darken';
		public static const DIFFERENCE:String = 'difference';
		public static const ADD:String = 'add';
		public static const SUBTRACT:String = 'subtract';
		public static const INVERT:String = 'invert';
		public static const ALPHA:String = 'alpha';
		public static const ERASE:String = 'erase';
		public static const OVERLAY:String = 'overlay';
		public static const HARDLIGHT:String = 'hardlight';
		
		public function IdFromString(string:String):int
		{
			var result:int = -1;
			switch(string)
			{
				case NORMAL:
					result = 1;
					break;
				case LAYER:
					result = 2;
					break;
				case MULTIPLY:
					result = 3;
					break;
				case SCREEN:
					result = 4;
					break;
				case LIGHTEN:
					result = 5;
					break;
				case DARKEN:
					result = 6;
					break;
				case DIFFERENCE:
					result = 7;
					break;
				case ADD:
					result = 8;
					break;
				case SUBTRACT:
					result = 9;
					break;
				case INVERT:
					result = 10;
					break;
				case ALPHA:
					result = 11;
					break;
				case ERASE:
					result = 12;
					break;
				case OVERLAY:
					result = 13;
					break;
				case HARDLIGHT:
					result = 14;
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
				case 1:
					result = NORMAL;
					break;
				case 2:
					result = LAYER;
					break;
				case 3:
					result = MULTIPLY;
					break;
				case 4:
					result = SCREEN;
					break;
				case 5:
					result = LIGHTEN;
					break;
				case 6:
					result = DARKEN;
					break;
				case 7:
					result = DIFFERENCE;
					break;
				case 8:
					result = ADD;
					break;
				case 9:
					result = SUBTRACT;
					break;
				case 10:
					result = INVERT;
					break;
				case 11:
					result = ALPHA;
					break;
				case 12:
					result = ERASE;
					break;
				case 13:
					result = OVERLAY;
					break;
				case 14:
					result = HARDLIGHT;
					break;
			}
			return result;
		}
	}
}


