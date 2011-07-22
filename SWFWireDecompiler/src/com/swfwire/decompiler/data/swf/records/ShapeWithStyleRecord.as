package com.swfwire.decompiler.data.swf.records
{
	public class ShapeWithStyleRecord
	{
		public var fillStyles:FillStyleArrayRecord;
		public var lineStyles:LineStyleArrayRecord;
		public var numFillBits:uint;
		public var numLineBits:uint;
		public var shapeRecords:Vector.<IShapeRecord>;

		public function ShapeWithStyleRecord(fillStyles:FillStyleArrayRecord = null, lineStyles:LineStyleArrayRecord = null, numFillBits:uint = 0, numLineBits:uint = 0, shapeRecords:Vector.<IShapeRecord> = null)
		{
			if(fillStyles == null)
			{
				fillStyles = new FillStyleArrayRecord();
			}
			if(lineStyles == null)
			{
				lineStyles = new LineStyleArrayRecord();
			}
			if(shapeRecords == null)
			{
				shapeRecords = new Vector.<IShapeRecord>();
			}

			this.fillStyles = fillStyles;
			this.lineStyles = lineStyles;
			this.numFillBits = numFillBits;
			this.numLineBits = numLineBits;
			this.shapeRecords = shapeRecords;
		}
	}
}