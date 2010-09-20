package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class SceneRecord implements IRecord
	{
		public var offset:uint;
		public var name:String;
		
		public function SceneRecord(offset:uint = 0, name:String = '')
		{
			this.offset = offset;
			this.name = name;
		}
		public function read(swf:SWFByteArray):void
		{
			offset = swf.readEncodedUI32();
			name = swf.readString();
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI32(offset);
			swf.writeString(name);
		}
	}
}