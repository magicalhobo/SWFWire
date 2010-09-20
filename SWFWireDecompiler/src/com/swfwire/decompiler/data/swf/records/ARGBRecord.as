package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class ARGBRecord implements IRGBRecord
	{
		public var alpha:uint;
		public var red:uint;
		public var green:uint;
		public var blue:uint;
		
		public function read(swf:SWFByteArray):void
		{
			alpha = swf.readUI8();
			red = swf.readUI8();
			green = swf.readUI8();
			blue = swf.readUI8();
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI8(alpha);
			swf.writeUI8(red);
			swf.writeUI8(green);
			swf.writeUI8(blue);
		}
	}
}