package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	
	public class MetadataInfoToken implements IToken
	{
		public var name:uint;
		public var itemCount:uint;
		public var items:Vector.<ItemInfoToken>;

		public function MetadataInfoToken(name:uint = 0, itemCount:uint = 0, items:Vector.<ItemInfoToken> = null)
		{
			if(items == null)
			{
				items = new Vector.<ItemInfoToken>();
			}

			this.name = name;
			this.itemCount = itemCount;
			this.items = items;
		}
	}
}