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

		public function TextRecord(styleFlagsReserved:uint = 0, styleFlagsHasFont:Boolean = false, styleFlagsHasColor:Boolean = false, styleFlagsHasYOffset:Boolean = false, styleFlagsHasXOffset:Boolean = false, fontId:uint = 0, textColor:RGBRecord = null, xOffset:int = 0, yOffset:int = 0, textHeight:uint = 0, glyphCount:uint = 0, glyphEntries:Vector.<GlyphEntryRecord> = null)
		{
			if(textColor == null)
			{
				textColor = new RGBRecord();
			}
			if(glyphEntries == null)
			{
				glyphEntries = new Vector.<GlyphEntryRecord>();
			}

			this.styleFlagsReserved = styleFlagsReserved;
			this.styleFlagsHasFont = styleFlagsHasFont;
			this.styleFlagsHasColor = styleFlagsHasColor;
			this.styleFlagsHasYOffset = styleFlagsHasYOffset;
			this.styleFlagsHasXOffset = styleFlagsHasXOffset;
			this.fontId = fontId;
			this.textColor = textColor;
			this.xOffset = xOffset;
			this.yOffset = yOffset;
			this.textHeight = textHeight;
			this.glyphCount = glyphCount;
			this.glyphEntries = glyphEntries;
		}
	}
}