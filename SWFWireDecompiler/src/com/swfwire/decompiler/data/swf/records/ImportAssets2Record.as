package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class ImportAssets2Record implements IRecord
	{
		public var tag:uint;
		public var name:String;
		
		public function read(swf:SWFByteArray):void
		{
			tag = swf.readUI16();
			name = swf.readString();
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI16(tag);
			swf.writeString(name);
		}
	}
}