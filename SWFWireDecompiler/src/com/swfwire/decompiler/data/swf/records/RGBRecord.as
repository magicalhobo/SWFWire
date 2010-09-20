package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class RGBRecord implements IRGBRecord
	{
		public var red:uint;
		public var green:uint;
		public var blue:uint;
		
		public function RGBRecord(red:uint = 0, green:uint = 0, blue:uint = 0)
		{
			this.red = red;
			this.green = green;
			this.blue = blue;
		}
		
		public function read(swf:SWFByteArray):void
		{
			red = swf.readUI8();
			green = swf.readUI8();
			blue = swf.readUI8();
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI8(red);
			swf.writeUI8(green);
			swf.writeUI8(blue);
		}
	}
}