package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class NamespaceToken implements IToken
	{
		public static var KIND_PrivateNs:uint			 = 0x05;
		public static var KIND_Namespace:uint			 = 0x08;
		public static var KIND_PackageNamespace:uint	 = 0x16;
		public static var KIND_PackageInternalNs:uint	 = 0x17;
		public static var KIND_ProtectedNamespace:uint	 = 0x18;
		public static var KIND_ExplicitNamespace:uint	 = 0x19;
		public static var KIND_StaticProtectedNs:uint	 = 0x1A;
		
		public var kind:uint;
		public var name:uint;

		public function NamespaceToken(kind:uint = 0, name:uint = 0)
		{
			this.kind = kind;
			this.name = name;
		}
		
		public function read(abc:ABCByteArray):void
		{
			kind = abc.readU8();
			name = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU8(kind);
			abc.writeU30(name);
		}
	}
}