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
	}
}