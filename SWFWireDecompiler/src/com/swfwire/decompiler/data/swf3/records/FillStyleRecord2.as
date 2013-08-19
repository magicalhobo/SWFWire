package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.data.swf.records.IGradientRecord;
	import com.swfwire.decompiler.data.swf.records.MatrixRecord;
	import com.swfwire.decompiler.data.swf.records.RGBARecord;

	public class FillStyleRecord2
	{
		public var type:uint;
		public var color:RGBARecord;
		public var gradientMatrix:MatrixRecord;
		public var gradient:IGradientRecord
		public var bitmapId:uint;
		public var bitmapMatrix:MatrixRecord;
		
		public function FillStyleRecord2(type:uint = 0, color:RGBARecord = null, gradientMatrix:MatrixRecord = null, gradient:IGradientRecord = null, 
										 bitmapId:uint = 0, bitmapMatrix:MatrixRecord = null)
		{
			this.type = type;
			this.color = color;
			this.gradientMatrix = gradientMatrix;
			this.gradient = gradient;
			this.bitmapId = bitmapId;
			this.bitmapMatrix = bitmapMatrix;
		}
	}
}
