package com.swfwire.decompiler.data.swf.records
{
	public class GradientGlowFilterRecord implements IFilterRecord
	{
		public var gradientColors:Vector.<RGBARecord>;
		public var gradientRatios:Vector.<uint>;
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
		
		public function get filterId():uint
		{
			return 4;
		}

		public function GradientGlowFilterRecord(gradientColors:Vector.<RGBARecord> = null, gradientRatio:Vector.<uint> = null, blurX:Number = NaN, blurY:Number = NaN, angle:Number = NaN, distance:Number = NaN, strength:Number = NaN, innerShadow:Boolean = false, knockout:Boolean = false, compositeSource:Boolean = false, onTop:Boolean = false, passes:uint = 0)
		{
			if(gradientColors == null)
			{
				gradientColors = new Vector.<RGBARecord>();
			}
			if(gradientRatio == null)
			{
				gradientRatio = new Vector.<uint>();
			}

			this.gradientColors = gradientColors;
			this.gradientRatios = gradientRatio;
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