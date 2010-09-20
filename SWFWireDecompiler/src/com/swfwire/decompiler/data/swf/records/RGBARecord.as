package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class RGBARecord implements IRGBRecord
	{
		public var red:uint;
		public var green:uint;
		public var blue:uint;
		public var alpha:uint;
		
		public function read(swf:SWFByteArray):void
		{
			red = swf.readUI8();
			green = swf.readUI8();
			blue = swf.readUI8();
			alpha = swf.readUI8();
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI8(red);
			swf.writeUI8(green);
			swf.writeUI8(blue);
			swf.writeUI8(alpha);
		}
	}
}