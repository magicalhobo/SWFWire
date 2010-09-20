package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
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
		
		public function read(abc:ABCByteArray):void
		{
			name = abc.readU30();
			itemCount = abc.readU30();
			items = new Vector.<ItemInfoToken>(itemCount);
			var iter:uint = 0;
			for(iter = 0; iter < itemCount; iter++)
			{
				var item:ItemInfoToken = new ItemInfoToken();
				item.read(abc);
				items[iter] = item;
			}
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(name);
			abc.writeU30(itemCount);
			var iter:uint = 0;
			for(iter = 0; iter < items.length; iter++)
			{
				items[iter].write(abc);
			}
		}
	}
}