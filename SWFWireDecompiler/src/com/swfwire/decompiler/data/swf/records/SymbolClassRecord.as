package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class SymbolClassRecord
	{
		public var characterId:uint;
		public var className:String;
		
		public function read(swf:SWFByteArray):void
		{
			characterId = swf.readUI16();
			className = swf.readString();
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI16(characterId);
			swf.writeString(className);
		}
	}
}