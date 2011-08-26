package com.swfwire.decompiler.abc.tokens.cpool
{
	public class CPoolIndex
	{
		public static const INVALID:int = -1;
		
		public var value:int;
		
		public function CPoolIndex(value:int = -1)
		{
			this.value = value;
		}
	}
}