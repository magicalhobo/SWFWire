package com.swfwire.decompiler.data.swf.records
{
	public class BevelFilterRecord
	{
		public var shadowColor:RGBARecord;
		public var highlightColor:RGBARecord;
		public var blurX:Number;
		public var blurY:Number;
		public var angle:Number;
		public var distance:Number;
		public var strength:Number;
		public var innerShadow:Boolean;
		public var knockout:Boolean;
		public var compositeSource:Boolean;
		public var onTop:Boolean;
		public var passes:uint;

		public function BevelFilterRecord(shadowColor:RGBARecord = null, highlightColor:RGBARecord = null, blurX:Number = NaN, blurY:Number = NaN, angle:Number = NaN, distance:Number = NaN, strength:Number = NaN, innerShadow:Boolean = false, knockout:Boolean = false, compositeSource:Boolean = false, onTop:Boolean = false, passes:uint = 0)
		{
			if(shadowColor == null)
			{
				shadowColor = new RGBARecord();
			}
			if(highlightColor == null)
			{
				highlightColor = new RGBARecord();
			}

			this.shadowColor = shadowColor;
			this.highlightColor = highlightColor;
			this.blurX = blurX;
			this.blurY = blurY;
			this.angle = angle;
			this.distance = distance;
			this.strength = strength;
			this.innerShadow = innerShadow;
			this.knockout = knockout;
			this.compositeSource = compositeSource;
			this.onTop = onTop;
			this.passes = passes;
		}
	}
}