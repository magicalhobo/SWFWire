package com.swfwire.decompiler.abc.tokens.multinames
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class MultinameMultinameLToken implements IMultiname
	{
		public var nsSet:uint;

		public function MultinameMultinameLToken(nsSet:uint = 0)
		{
			this.nsSet = nsSet;
		}
		
		public function read(abc:ABCByteArray):void
		{
			//cpool.nsSets
			nsSet = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(nsSet);
		}
	}
}