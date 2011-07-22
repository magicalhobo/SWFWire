package com.swfwire.decompiler.data.swf.records
{
	public class GlowFilterRecord
	{
		public var color:RGBARecord;
		public var blurX:Number;
		public var blurY:Number;
		public var strength:Number;
		public var innerGlow:Boolean;
		public var knockout:Boolean;
		public var compositeSource:Boolean;
		public var passes:uint;

		public function GlowFilterRecord(color:RGBARecord = null, blurX:Number = NaN, blurY:Number = NaN, strength:Number = NaN, innerGlow:Boolean = false, knockout:Boolean = false, compositeSource:Boolean = false, passes:uint = 0)
		{
			if(color == null)
			{
				color = new RGBARecord();
			}

			this.color = color;
			this.blurX = blurX;
			this.blurY = blurY;
			this.strength = strength;
			this.innerGlow = innerGlow;
			this.knockout = knockout;
			this.compositeSource = compositeSource;
			this.passes = passes;
		}
	}
}