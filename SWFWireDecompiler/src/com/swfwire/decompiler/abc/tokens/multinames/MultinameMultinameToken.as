package com.swfwire.decompiler.abc.tokens.multinames
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class MultinameMultinameToken implements IMultiname
	{
		public var name:uint;
		public var nsSet:uint;

		public function MultinameMultinameToken(name:uint = 0, nsSet:uint = 0)
		{
			this.name = name;
			this.nsSet = nsSet;
		}
		
		public function read(abc:ABCByteArray):void
		{
			//cpool.strings
			name = abc.readU30();
			//cpool.nsSets
			nsSet = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			//cpool.strings
			abc.writeU30(name);
			//cpool.nsSets
			abc.writeU30(nsSet);
		}
	}
}