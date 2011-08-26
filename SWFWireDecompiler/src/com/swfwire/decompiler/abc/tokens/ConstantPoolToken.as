package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;

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
	}
}