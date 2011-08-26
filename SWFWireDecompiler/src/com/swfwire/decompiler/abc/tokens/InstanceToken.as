package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	
	public class InstanceToken implements IToken
	{
		public static const FLAG_CLASS_SEALED:uint			 = 1 << 0;
		public static const FLAG_CLASS_FINAL:uint			 = 1 << 1;
		public static const FLAG_CLASS_INTERFACE:uint		 = 1 << 2;
		public static const FLAG_CLASS_PROTECTED_NS:uint	 = 1 << 3;
		
		public var name:uint;
		public var superName:uint;
		public var flags:uint;
		public var protectedNs:uint;
		public var interfaceCount:uint;
		public var interfaces:Vector.<uint>;
		public var iinit:uint;
		public var traitCount:uint;
		public var traits:Vector.<TraitsInfoToken>;

		public function InstanceToken(name:uint = 0, superName:uint = 0, flags:uint = 0, protectedNs:uint = 0, interfaceCount:uint = 0, interfaces:Vector.<uint> = null, iinit:uint = 0, traitCount:uint = 0, traits:Vector.<TraitsInfoToken> = null)
		{
			if(interfaces == null)
			{
				interfaces = new Vector.<uint>();
			}
			if(traits == null)
			{
				traits = new Vector.<TraitsInfoToken>();
			}

			this.name = name;
			this.superName = superName;
			this.flags = flags;
			this.protectedNs = protectedNs;
			this.interfaceCount = interfaceCount;
			this.interfaces = interfaces;
			this.iinit = iinit;
			this.traitCount = traitCount;
			this.traits = traits;
		}
	}
}