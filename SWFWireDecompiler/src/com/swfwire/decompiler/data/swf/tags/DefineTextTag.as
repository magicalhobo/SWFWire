package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.records.MatrixRecord;
	import com.swfwire.decompiler.data.swf.records.RectangleRecord;
	import com.swfwire.decompiler.data.swf.records.TextRecord;
	
	public class DefineTextTag extends SWFTag
	{
		public var characterId:uint;
		public var textBounds:RectangleRecord;
		public var textMatrix:MatrixRecord;
		public var glyphBits:uint;
		public var advanceBits:uint;
		public var textRecords:Vector.<TextRecord>;
	}
}