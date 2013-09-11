package com.swfwire.decompiler.data.swf.tags
{
	public class DefineFontInfoTag extends SWFTag
	{
		public var fontId:uint;
		public var fontName:Vector.<uint>;
		public var fontFlagsReserved:uint;
		public var fontFlagsSmallText:Boolean;
		public var fontFlagsShiftJIS:Boolean;
		public var fontFlagsANSI:Boolean;
		public var fontFlagsItalic:Boolean;
		public var fontFlagsBold:Boolean;
		public var fontFlagsWideCodes:Boolean;
		public var codeTable:Vector.<uint>;
		
		public function DefineFontInfoTag(fontId:uint = 0, fontName:Vector.<uint> = null, fontFlagsReserved:uint = 0, fontFlagsSmallText:Boolean = false, fontFlagsShiftJIS:Boolean = false, fontFlagsANSI:Boolean = false, fontFlagsItalic:Boolean = false, fontFlagsBold:Boolean = false, fontFlagsWideCodes:Boolean = false, codeTable:Vector.<uint> = null)
		{
			if(fontName == null)
			{
				fontName = new Vector.<uint>();
			}
			if(codeTable == null)
			{
				codeTable = new Vector.<uint>();
			}
			
			this.fontId = fontId;
			this.fontName = fontName;
			this.fontFlagsReserved = fontFlagsReserved;
			this.fontFlagsSmallText = fontFlagsSmallText;
			this.fontFlagsShiftJIS = fontFlagsShiftJIS;
			this.fontFlagsANSI = fontFlagsANSI;
			this.fontFlagsItalic = fontFlagsItalic;
			this.fontFlagsBold = fontFlagsBold;
			this.codeTable = codeTable;
		}
	}
}