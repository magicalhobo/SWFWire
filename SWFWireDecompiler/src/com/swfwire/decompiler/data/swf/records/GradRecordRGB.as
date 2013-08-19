package com.swfwire.decompiler.data.swf.records
{
	public class GradRecordRGB
	{
		public var ratio:uint;
		public var color:RGBRecord;

		public function GradRecordRGB(ratio:uint = 0, color:RGBRecord = null)
		{
			if(color == null)
			{
				color = new RGBRecord();
			}

			this.ratio = ratio;
			this.color = color;
		}
	}
}