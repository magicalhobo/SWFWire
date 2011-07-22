package com.swfwire.decompiler.data.swf.records
{
	public class FilterRecord
	{
		public var filterId:uint;
		public var dropShadowFilter:DropShadowFilterRecord;
		public var blurFilter:BlurFilterRecord;
		public var glowFilter:GlowFilterRecord;
		public var bevelFilter:BevelFilterRecord;
		public var gradientGlowFilter:GradientGlowFilterRecord;
		public var convolutionFilter:ConvolutionFilterRecord;
		public var colorMatrixFilter:ColorMatrixFilterRecord;
		public var gradientBevelFilter:GradientBevelFilterRecord;

		public function FilterRecord(filterId:uint = 0, dropShadowFilter:DropShadowFilterRecord = null, blurFilter:BlurFilterRecord = null, glowFilter:GlowFilterRecord = null, bevelFilter:BevelFilterRecord = null, gradientGlowFilter:GradientGlowFilterRecord = null, convolutionFilter:ConvolutionFilterRecord = null, colorMatrixFilter:ColorMatrixFilterRecord = null, gradientBevelFilter:GradientBevelFilterRecord = null)
		{
			if(dropShadowFilter == null)
			{
				dropShadowFilter = new DropShadowFilterRecord();
			}
			if(blurFilter == null)
			{
				blurFilter = new BlurFilterRecord();
			}
			if(glowFilter == null)
			{
				glowFilter = new GlowFilterRecord();
			}
			if(bevelFilter == null)
			{
				bevelFilter = new BevelFilterRecord();
			}
			if(gradientGlowFilter == null)
			{
				gradientGlowFilter = new GradientGlowFilterRecord();
			}
			if(convolutionFilter == null)
			{
				convolutionFilter = new ConvolutionFilterRecord();
			}
			if(colorMatrixFilter == null)
			{
				colorMatrixFilter = new ColorMatrixFilterRecord();
			}
			if(gradientBevelFilter == null)
			{
				gradientBevelFilter = new GradientBevelFilterRecord();
			}

			this.filterId = filterId;
			this.dropShadowFilter = dropShadowFilter;
			this.blurFilter = blurFilter;
			this.glowFilter = glowFilter;
			this.bevelFilter = bevelFilter;
			this.gradientGlowFilter = gradientGlowFilter;
			this.convolutionFilter = convolutionFilter;
			this.colorMatrixFilter = colorMatrixFilter;
			this.gradientBevelFilter = gradientBevelFilter;
		}
	}
}