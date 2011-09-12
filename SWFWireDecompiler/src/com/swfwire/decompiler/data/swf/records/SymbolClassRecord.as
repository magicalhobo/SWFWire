package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class SymbolClassRecord
	{
		public var characterId:uint;
		public var className:String;

		public function SymbolClassRecord(characterId:uint = 0, className:String = '')
		{
			this.characterId = characterId;
			this.className = className;
		}
	}
}