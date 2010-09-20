package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.*;
	
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