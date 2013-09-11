package com.swfwire.decompiler.data.swf.records
{
	public class ShapeRecord
	{
		public var numFillBits:uint;
		public var numLineBits:uint;
		public var shapeRecords:Vector.<IShapeRecord>;

		public function ShapeRecord(numFillBits:uint = 0, numLineBits:uint = 0, shapeRecords:Vector.<IShapeRecord> = null)
		{
			if(shapeRecords == null)
			{
				shapeRecords = new Vector.<IShapeRecord>();
			}

			this.numFillBits = numFillBits;
			this.numLineBits = numLineBits;
			this.shapeRecords = shapeRecords;
		}
	}
}