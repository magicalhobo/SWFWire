package com.swfwire.decompiler.data.swf.records
{
	public class TextRecord
	{
		public var styleFlagsReserved:uint;
		public var styleFlagsHasFont:Boolean;
		public var styleFlagsHasColor:Boolean;
		public var styleFlagsHasYOffset:Boolean;
		public var styleFlagsHasXOffset:Boolean;
		public var fontId:uint;
		public var textColor:RGBRecord;
		public var xOffset:int;
		public var yOffset:int;
		public var textHeight:uint;
		public var glyphCount:uint;
		public var glyphEntries:Vector.<GlyphEntryRecord>;
	}
}