package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;
	
	public class RectangleRecord implements IRecord
	{
		public var nBits:uint;
		public var xMin:int;
		public var xMax:int;
		public var yMin:int;
		public var yMax:int;
		
		public function RectangleRecord(nBits:uint = 0, xMin:int = 0, xMax:int = 0, yMin:int = 0, yMax:int = 0)
		{
			this.nBits = nBits;
			this.xMin = xMin;
			this.xMax = xMax;
			this.yMin = yMin;
			this.yMax = yMax;
		}
		
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