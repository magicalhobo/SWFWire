package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class ItemInfoToken implements IToken
	{
		public var key:uint;
		public var value:uint;

		public function ItemInfoToken(key:uint = 0, value:uint = 0)
		{
			this.key = key;
			this.value = value;
		}
		
		public function read(abc:ABCByteArray):void
		{
			key = abc.readU30();
			value = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(key);
			abc.writeU30(value);
		}
	}
}