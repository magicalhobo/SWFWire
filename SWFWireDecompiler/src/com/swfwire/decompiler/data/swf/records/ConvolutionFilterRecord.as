package com.swfwire.decompiler.data.swf.records
{
	public class ConvolutionFilterRecord
	{
		public var matrixX:uint;
		public var matrixY:uint;
		public var divisor:Number;
		public var bias:Number;
		public var matrix:Vector.<Number>;
		public var defaultColor:RGBARecord;
		public var reserved:uint;
		public var clamp:Boolean;
		public var preserveAlpha:Boolean;

		public function ConvolutionFilterRecord(matrixX:uint = 0, matrixY:uint = 0, divisor:Number = NaN, bias:Number = NaN, matrix:Vector.<Number> = null, defaultColor:RGBARecord = null, reserved:uint = 0, clamp:Boolean = false, preserveAlpha:Boolean = false)
		{
			if(matrix == null)
			{
				matrix = new Vector.<Number>();
			}
			if(defaultColor == null)
			{
				defaultColor = new RGBARecord();
			}

			this.matrixX = matrixX;
			this.matrixY = matrixY;
			this.divisor = divisor;
			this.bias = bias;
			this.matrix = matrix;
			this.defaultColor = defaultColor;
			this.reserved = reserved;
			this.clamp = clamp;
			this.preserveAlpha = preserveAlpha;
		}
	}
}