package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
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
		
		public function read(abc:ABCByteArray):void
		{
			//Must be a QName
			name = abc.readU30();
			//0 means no base class
			superName = abc.readU30();
			flags = abc.readU8();
			if(flags & FLAG_CLASS_PROTECTED_NS)
			{
				protectedNs = abc.readU30();
			}
			interfaceCount = abc.readU30();
			var iter:uint;
			interfaces = new Vector.<uint>(interfaceCount);
			for(iter = 0; iter < interfaceCount; iter++)
			{
				interfaces[iter] = abc.readU30();
			}
			iinit = abc.readU30();
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
			//Must be a QName
			abc.writeU30(name);
			//0 means no base class
			abc.writeU30(superName);
			abc.writeU8(flags);
			if(flags & FLAG_CLASS_PROTECTED_NS)
			{
				abc.writeU30(protectedNs);
			}
			abc.writeU30(interfaceCount);
			var iter:uint;
			for(iter = 0; iter < interfaces.length; iter++)
			{
				abc.writeU30(interfaces[iter]);
			}
			abc.writeU30(iinit);
			abc.writeU30(traitCount);
			for(iter = 0; iter < traits.length; iter++)
			{
				traits[iter].write(abc);
			}
		}
	}
}