package com.swfwire.decompiler.data.swf8.records
{
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf3.records.FillStyleArrayRecord3;

	public class ShapeWithStyleRecord4
	{
		public var fillStyles:FillStyleArrayRecord3;
		public var lineStyles:LineStyle2ArrayRecord;
		public var numFillBits:uint;
		public var numLineBits:uint;
		public var shapeRecords:Vector.<IShapeRecord>;
	}
}