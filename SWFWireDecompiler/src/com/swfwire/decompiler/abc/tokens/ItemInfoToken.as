package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	
	public class ItemInfoToken implements IToken
	{
		public var key:uint;
		public var value:uint;

		public function ItemInfoToken(key:uint = 0, value:uint = 0)
		{
			this.key = key;
			this.value = value;
		}
	}
}