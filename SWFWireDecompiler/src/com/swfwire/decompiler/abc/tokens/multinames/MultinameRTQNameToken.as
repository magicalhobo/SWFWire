package com.swfwire.decompiler.abc.tokens.multinames
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class MultinameRTQNameToken implements IMultiname
	{
		public var name:uint;

		public function MultinameRTQNameToken(name:uint = 0)
		{
			this.name = name;
		}
		
		public function read(abc:ABCByteArray):void
		{
			//cpool.strings
			name = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			//cpool.strings
			abc.writeU30(name);
		}
	}
}