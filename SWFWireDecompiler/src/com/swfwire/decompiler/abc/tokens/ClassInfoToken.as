package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class ClassInfoToken implements IToken
	{
		public var cinit:uint;
		public var traitCount:uint;
		public var traits:Vector.<TraitsInfoToken>;

		public function ClassInfoToken(cinit:uint = 0, traitCount:uint = 0, traits:Vector.<TraitsInfoToken> = null)
		{
			if(traits == null)
			{
				traits = new Vector.<TraitsInfoToken>();
			}

			this.cinit = cinit;
			this.traitCount = traitCount;
			this.traits = traits;
		}
		
		public function read(abc:ABCByteArray):void
		{
			var iter:uint;
			cinit = abc.readU30();
			traitCount = abc.readU30();
			traits = new Vector.<TraitsInfoToken>(traitCount);
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
			abc.writeU30(cinit);
			abc.writeU30(traits.length);
			for(iter = 0; iter < traits.length; iter++)
			{
				traits[iter].write(abc);
			}
		}
	}
}