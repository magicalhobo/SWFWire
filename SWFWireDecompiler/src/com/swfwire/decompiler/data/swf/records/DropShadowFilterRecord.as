package com.swfwire.decompiler.data.swf.records
{
	public class DropShadowFilterRecord
	{
		public var color:RGBARecord;
		public var blurX:Number;
		public var blurY:Number;
		public var angle:Number;
		public var distance:Number;
		public var strength:Number;
		public var innerShadow:Boolean;
		public var knockout:Boolean;
		public var compositeSource:Boolean;
		public var passes:uint;

		public function DropShadowFilterRecord(color:RGBARecord = null, blurX:Number = NaN, blurY:Number = NaN, angle:Number = NaN, distance:Number = NaN, strength:Number = NaN, innerShadow:Boolean = false, knockout:Boolean = false, compositeSource:Boolean = false, passes:uint = 0)
		{
			if(color == null)
			{
				color = new RGBARecord();
			}

			this.color = color;
			this.blurX = blurX;
			this.blurY = blurY;
			this.angle = angle;
			this.distance = distance;
			this.strength = strength;
			this.innerShadow = innerShadow;
			this.knockout = knockout;
			this.compositeSource = compositeSource;
			this.passes = passes;
		}
	}
}