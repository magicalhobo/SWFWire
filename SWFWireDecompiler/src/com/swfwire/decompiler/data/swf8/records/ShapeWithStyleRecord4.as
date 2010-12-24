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

		public function ShapeWithStyleRecord4(fillStyles:FillStyleArrayRecord3 = null,
											  lineStyles:LineStyle2ArrayRecord = null,
											  numFillBits:uint = 0, numLineBits:uint = 0,
											  shapeRecords:Vector.<IShapeRecord> = null)
		{
			this.fillStyles = fillStyles;
			this.lineStyles = lineStyles;
			this.numFillBits = numFillBits;
			this.numLineBits = numLineBits;
			this.shapeRecords = shapeRecords;
		}
	}
}