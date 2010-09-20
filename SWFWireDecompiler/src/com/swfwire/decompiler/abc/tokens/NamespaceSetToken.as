package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class NamespaceSetToken implements IToken
	{
		public var count:uint;
		public var namespaces:Vector.<uint>;

		public function NamespaceSetToken(count:uint = 0, namespaces:Vector.<uint> = null)
		{
			if(namespaces == null)
			{
				namespaces = new Vector.<uint>();
			}

			this.count = count;
			this.namespaces = namespaces;
		}
		
		public function read(abc:ABCByteArray):void
		{
			count = abc.readU30();
			namespaces = new Vector.<uint>(count);
			var iter:uint;
			for(iter = 0; iter < count; iter++)
			{
				var namespaceId:uint = abc.readU30();
				if(namespaceId == 0)
				{
					throw new Error('A namespace entry may not be 0');
				}
				namespaces[iter] = namespaceId;
			}
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(count);
			
			var iter:uint;
			for(iter = 0; iter < namespaces.length; iter++)
			{
				var namespaceId:uint = namespaces[iter];
				if(namespaceId == 0)
				{
					throw new Error('A namespace entry may not be 0');
				}
				abc.writeU30(namespaceId);
			}
		}
	}
}