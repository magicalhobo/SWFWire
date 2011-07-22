package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;
	
	public class GradientRecord implements IGradientRecord
	{
		public var reserved:uint;
		public var numGradients:uint;
		public var gradientRecords:Vector.<GradientControlPointRecord>;

		public function GradientRecord(reserved:uint = 0, numGradients:uint = 0, gradientRecords:Vector.<GradientControlPointRecord> = null)
		{
			if(gradientRecords == null)
			{
				gradientRecords = new Vector.<GradientControlPointRecord>();
			}

			this.reserved = reserved;
			this.numGradients = numGradients;
			this.gradientRecords = gradientRecords;
		}
	}
}