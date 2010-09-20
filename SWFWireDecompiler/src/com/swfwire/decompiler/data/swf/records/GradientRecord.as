package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;
	
	public class GradientRecord implements IGradientRecord
	{
		public var reserved:uint;
		public var numGradients:uint;
		public var gradientRecords:Vector.<GradientControlPointRecord>;
		
		public function read(swf:SWFByteArray):void
		{
			
		}
		
		public function write(swf:SWFByteArray):void
		{
		}
	}
}