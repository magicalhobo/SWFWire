package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;

	public class ConstantPoolToken implements IToken
	{
		public var integers:Vector.<int>;
		public var uintegers:Vector.<uint>;
		public var doubles:Vector.<Number>;
		public var strings:Vector.<StringToken>;
		public var namespaces:Vector.<NamespaceToken>;
		public var nsSets:Vector.<NamespaceSetToken>;
		public var multinames:Vector.<MultinameToken>;

		public function ConstantPoolToken(integers:Vector.<int> = null, uintegers:Vector.<uint> = null,
			  doubles:Vector.<Number> = null, strings:Vector.<StringToken> = null,
			  namespaces:Vector.<NamespaceToken> = null, nsSets:Vector.<NamespaceSetToken> = null,
			  multinames:Vector.<MultinameToken> = null)
		{
			if(integers == null)
			{
				integers = new Vector.<int>();
			}
			if(uintegers == null)
			{
				uintegers = new Vector.<uint>();
			}
			if(doubles == null)
			{
				doubles = new Vector.<Number>();
			}
			if(strings == null)
			{
				strings = new Vector.<StringToken>();
			}
			if(namespaces == null)
			{
				namespaces = new Vector.<NamespaceToken>();
			}
			if(nsSets == null)
			{
				nsSets = new Vector.<NamespaceSetToken>();
			}
			if(multinames == null)
			{
				multinames = new Vector.<MultinameToken>();
			}

			this.integers = integers;
			this.uintegers = uintegers;
			this.doubles = doubles;
			this.strings = strings;
			this.namespaces = namespaces;
			this.nsSets = nsSets;
			this.multinames = multinames;
		}
		
		public function read(abc:ABCByteArray):void
		{
			var iter:uint;
			
			var intCount:uint = abc.readU30();
			integers = new Vector.<int>(intCount);
			integers[0] = 0;
			for(iter = 1; iter < intCount; iter++)
			{
				integers[iter] = abc.readS32();
			}
			
			var uintCount:uint = abc.readU30();
			uintegers = new Vector.<uint>(uintCount);
			uintegers[0] = 0;
			for(iter = 1; iter < uintCount; iter++)
			{
				uintegers[iter] = abc.readU32();
			}
			
			var doubleCount:uint = abc.readU30();
			doubles = new Vector.<Number>(doubleCount);
			doubles[0] = 0;
			for(iter = 1; iter < doubleCount; iter++)
			{
				doubles[iter] = abc.readD64();
			}
			
			var stringCount:uint = abc.readU30();
			strings = new Vector.<StringToken>(stringCount);
			strings[0] = new StringToken();
			for(iter = 1; iter < stringCount; iter++)
			{
				var string:StringToken = new StringToken();
				string.read(abc);
				strings[iter] = string;
			}
			
			var namespaceCount:uint = abc.readU30();
			namespaces = new Vector.<NamespaceToken>(namespaceCount);
			namespaces[0] = new NamespaceToken();
			for(iter = 1; iter < namespaceCount; iter++)
			{
				var namespaceToken:NamespaceToken = new NamespaceToken();
				namespaceToken.read(abc);
				namespaces[iter] = namespaceToken;
			}
			
			var nsSetCount:uint = abc.readU30();
			nsSets = new Vector.<NamespaceSetToken>(nsSetCount);
			nsSets[0] = new NamespaceSetToken();
			for(iter = 1; iter < nsSetCount; iter++)
			{
				var nsSet:NamespaceSetToken = new NamespaceSetToken();
				nsSet.read(abc);
				nsSets[iter] = nsSet;
			}
			
			var multinameCount:uint = abc.readU30();
			multinames = new Vector.<MultinameToken>(multinameCount);
			multinames[0] = new MultinameToken();
			for(iter = 1; iter < multinameCount; iter++)
			{
				var multiname:MultinameToken = new MultinameToken();
				multiname.read(abc);
				multinames[iter] = multiname;
			}
		}
		public function write(abc:ABCByteArray):void
		{
			var iter:uint;
			
			abc.writeU30(integers.length == 1 ? 0 : integers.length);
			for(iter = 1; iter < integers.length; iter++)
			{
				abc.writeS32(integers[iter]);
			}
			
			abc.writeU30(uintegers.length == 1 ? 0 : uintegers.length);
			for(iter = 1; iter < uintegers.length; iter++)
			{
				abc.writeU32(uintegers[iter]);
			}
			
			abc.writeU30(doubles.length == 1 ? 0 : doubles.length);
			for(iter = 1; iter < doubles.length; iter++)
			{
				abc.writeD64(doubles[iter])
			}
			
			abc.writeU30(strings.length == 1 ? 0 : strings.length);
			for(iter = 1; iter < strings.length; iter++)
			{
				strings[iter].write(abc);
			}
			
			abc.writeU30(namespaces.length == 1 ? 0 : namespaces.length);
			for(iter = 1; iter < namespaces.length; iter++)
			{
				namespaces[iter].write(abc);
			}
			
			abc.writeU30(nsSets.length == 1 ? 0 : nsSets.length);
			for(iter = 1; iter < nsSets.length; iter++)
			{
				nsSets[iter].write(abc);
			}
			
			abc.writeU30(multinames.length == 1 ? 0 : multinames.length);
			for(iter = 1; iter < multinames.length; iter++)
			{
				multinames[iter].write(abc);
			}
		}
	}
}