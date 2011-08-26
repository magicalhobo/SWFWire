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
	}
}