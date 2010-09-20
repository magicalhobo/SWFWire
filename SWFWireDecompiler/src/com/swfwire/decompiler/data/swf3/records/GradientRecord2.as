package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.data.swf.records.IGradientRecord;
	
	public class GradientRecord2 implements IGradientRecord
	{
		public var spreadMode:uint;
		public var interpolationMode:uint;
		public var numGradients:uint;
		public var gradientRecords:Vector.<GradientControlPointRecord2>;
	}
}