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
	}
}