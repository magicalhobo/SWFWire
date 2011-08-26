package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	
	public class OptionDetailToken implements IToken
	{
		public static const KIND_INT:uint					 = 0x03;
		public static const KIND_UINT:uint					 = 0x04;
		public static const KIND_DOUBLE:uint				 = 0x06;
		public static const KIND_UTF8:uint					 = 0x01;
		public static const KIND_TRUE:uint					 = 0x0B;
		public static const KIND_FALSE:uint					 = 0x0A;
		public static const KIND_NULL:uint					 = 0x0C;
		public static const KIND_UNDEFINED:uint				 = 0x00;
		public static const KIND_NAMESPACE:uint				 = 0x08;
		public static const KIND_PACKAGE_NAMESPACE:uint		 = 0x16;
		public static const KIND_PACKAGE_INTERNAL_NS:uint	 = 0x17;
		public static const KIND_PROTECTED_NAMESPACE:uint	 = 0x18;
		public static const KIND_EXPLICIT_NAMESPACE:uint	 = 0x19;
		public static const KIND_STATIC_PROTECTED_NS:uint	 = 0x1A;
		public static const KIND_PRIVATE_NS:uint			 = 0x05;
		
		public var val:uint;
		public var kind:uint;

		public function OptionDetailToken(val:uint = 0, kind:uint = 0)
		{
			this.val = val;
			this.kind = kind;
		}
	}
}