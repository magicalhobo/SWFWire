package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class RectangleRecord implements IRecord
	{
		public var nBits:uint;
		public var xMin:int;
		public var xMax:int;
		public var yMin:int;
		public var yMax:int;
		
		public function read(swf:SWFByteArray):void
		{
			nBits = swf.readUB(5);
			xMin = swf.readSB(nBits);
			xMax = swf.readSB(nBits);
			yMin = swf.readSB(nBits);
			yMax = swf.readSB(nBits);
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUB(5, nBits);
			swf.writeSB(nBits, xMin);
			swf.writeSB(nBits, xMax);
			swf.writeSB(nBits, yMin);
			swf.writeSB(nBits, yMax);
		}
	}
}