package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class GradRecordRGB implements IRecord
	{
		public var ratio:uint;
		public var color:RGBRecord;
		
		public function read(swf:SWFByteArray):void
		{
			ratio = swf.readUI8();
			color = new RGBRecord();
			color.read(swf);
		}
		
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI8(ratio);
			color.write(swf);
		}
	}
}