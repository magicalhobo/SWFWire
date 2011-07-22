package com.swfwire.decompiler.data.swf.records
{
	public class BlurFilterRecord
	{
		public var blurX:Number;
		public var blurY:Number;
		public var passes:uint;
		public var reserved:uint;

		public function BlurFilterRecord(blurX:Number = NaN, blurY:Number = NaN, passes:uint = 0, reserved:uint = 0)
		{
			this.blurX = blurX;
			this.blurY = blurY;
			this.passes = passes;
			this.reserved = reserved;
		}
	}
}