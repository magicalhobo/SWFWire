package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;

	public class FillStyleRecord implements IRecord
	{
		public var type:uint;
		public var color:RGBRecord;
		public var gradientMatrix:MatrixRecord;
		public var gradient:GradientRecord;
		public var bitmapId:uint;
		public var bitmapMatrix:MatrixRecord;
		
		public function FillStyleRecord(type:uint = 0)
		{
			this.type = type;
		}
		
		public function read(swf:SWFByteArray):void
		{
		}
		public function write(swf:SWFByteArray):void
		{
		}
	}
}
