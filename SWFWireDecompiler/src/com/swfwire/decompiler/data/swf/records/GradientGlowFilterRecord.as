package com.swfwire.decompiler.data.swf.records
{
	public class GradientGlowFilterRecord
	{
		public var numColors:uint;
		public var gradientColors:Vector.<RGBARecord>;
		public var gradientRatio:Vector.<uint>;
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
	}
}