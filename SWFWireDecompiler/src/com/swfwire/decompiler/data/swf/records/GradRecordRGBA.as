package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class GradRecordRGBA implements IRecord
	{
		public var ratio:uint;
		public var color:RGBARecord;
		
		public function read(swf:SWFByteArray):void
		{
			ratio = swf.readUI8();
			color = new RGBARecord();
			color.read(swf);
		}
		
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI8(ratio);
			color.write(swf);
		}
	}
}