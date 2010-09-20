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
		
		public function read(abc:ABCByteArray):void
		{
			var iter:uint;
			init = abc.readU30();
			traitCount = abc.readU30();
			traits = new Vector.<TraitsInfoToken>();
			for(iter = 0; iter < traitCount; iter++)
			{
				var trait:TraitsInfoToken = new TraitsInfoToken();
				trait.read(abc);
				traits[iter] = trait;
			}
		}
		public function write(abc:ABCByteArray):void
		{
			var iter:uint;
			abc.writeU30(init);
			abc.writeU30(traitCount);
			for(iter = 0; iter < traits.length; iter++)
			{
				traits[iter].write(abc);
			}
		}
	}
}