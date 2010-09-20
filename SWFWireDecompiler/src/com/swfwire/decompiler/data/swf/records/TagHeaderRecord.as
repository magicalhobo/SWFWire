package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class TagHeaderRecord implements IRecord
	{
		public static var SHORT_HEADER_MAX_LENGTH:uint = 0x3F;
		
		public var type:uint;
		public var length:uint;
		public var forceLong:Boolean;
		
		public function isLong():Boolean
		{
			return length >= SHORT_HEADER_MAX_LENGTH;
		}
		
		public function read(swf:SWFByteArray):void
		{
			var tagInfo:uint = swf.readUI16();
			type = tagInfo >> 6;
			length = tagInfo & ((1 << 6) - 1);
			if(length == SHORT_HEADER_MAX_LENGTH)
			{
				length = swf.readSI32();
				forceLong = true;
			}
		}
		public function write(swf:SWFByteArray):void
		{
			var tagInfo:uint = type << 6;
			var firstLength:uint = forceLong || isLong() ? SHORT_HEADER_MAX_LENGTH : length;
			tagInfo = tagInfo | (firstLength & ((1 << 6) - 1));
			swf.writeUI16(tagInfo);
			if(firstLength == SHORT_HEADER_MAX_LENGTH)
			{
				swf.writeSI32(length);
			}
		}
	}
}