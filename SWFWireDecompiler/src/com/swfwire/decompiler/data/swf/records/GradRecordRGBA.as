package com.swfwire.decompiler.data.swf.records
{
	public class GradRecordRGBA
	{
		public var ratio:uint;
		public var color:RGBARecord;

		public function GradRecordRGBA(ratio:uint = 0, color:RGBARecord = null)
		{
			if(color == null)
			{
				color = new RGBARecord();
			}

			this.ratio = ratio;
			this.color = color;
		}
	}
}