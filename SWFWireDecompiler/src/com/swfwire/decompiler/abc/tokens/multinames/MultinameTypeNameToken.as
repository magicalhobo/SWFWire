package com.swfwire.decompiler.abc.tokens.multinames
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class MultinameTypeNameToken implements IMultiname
	{
		public var name:uint;
		public var count:uint;
		public var subType:uint;

		public function MultinameTypeNameToken(name:uint = 0, count:uint = 0, subType:uint = 0)
		{
			this.name = name;
			this.count = count;
			this.subType = subType;
		}
		
		public function read(abc:ABCByteArray):void
		{
			//cpool.mutlinames
			name = abc.readU30();
			//always 1, until there are vectors with 2 types
			count = abc.readU30();
			//cpool.mutlinames
			subType = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			//cpool.mutlinames
			abc.writeU30(name);
			//always 1, until there are vectors with 2 types
			abc.writeU30(count);
			//cpool.mutlinames
			abc.writeU30(subType);
		}
	}
}