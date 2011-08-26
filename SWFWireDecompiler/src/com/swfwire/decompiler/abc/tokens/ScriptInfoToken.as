package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class ScriptInfoToken implements IToken
	{
		public var init:uint;
		public var traitCount:uint;
		public var traits:Vector.<TraitsInfoToken>;

		public function ScriptInfoToken(init:uint = 0, traitCount:uint = 0, traits:Vector.<TraitsInfoToken> = null)
		{
			if(traits == null)
			{
				traits = new Vector.<TraitsInfoToken>();
			}

			this.init = init;
			this.traitCount = traitCount;
			this.traits = traits;
		}
	}
}