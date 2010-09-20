package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.data.swf.records.*;

	public class FillStyleRecord2 implements IRecord
	{
		public var type:uint;
		public var color:RGBARecord;
		public var gradientMatrix:MatrixRecord;
		public var gradient:IGradientRecord
		public var bitmapId:uint;
		public var bitmapMatrix:MatrixRecord;
	}
}
