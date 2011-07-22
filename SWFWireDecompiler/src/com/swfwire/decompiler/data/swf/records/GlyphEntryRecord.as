package com.swfwire.decompiler.data.swf.records
{
	public class GlyphEntryRecord
	{
		public var glyphIndex:uint;
		public var glyphAdvance:int;

		public function GlyphEntryRecord(glyphIndex:uint = 0, glyphAdvance:int = 0)
		{
			this.glyphIndex = glyphIndex;
			this.glyphAdvance = glyphAdvance;
		}
	}
}