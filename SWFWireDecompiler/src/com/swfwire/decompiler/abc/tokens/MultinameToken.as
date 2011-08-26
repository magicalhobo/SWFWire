package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.abc.tokens.multinames.*;
	
	public class MultinameToken implements IToken
	{
		public static const KIND_QName:uint			 = 0x07;
		public static const KIND_QNameA:uint		 = 0x0D;
		public static const KIND_RTQName:uint		 = 0x0F;
		public static const KIND_RTQNameA:uint		 = 0x10;
		public static const KIND_RTQNameL:uint		 = 0x11;
		public static const KIND_RTQNameLA:uint		 = 0x12;
		public static const KIND_Multiname:uint		 = 0x09;
		public static const KIND_MultinameA:uint	 = 0x0E;
		public static const KIND_MultinameL:uint	 = 0x1B;
		public static const KIND_MultinameLA:uint	 = 0x1C;
		public static const KIND_TypeName:uint		 = 0x1D;
		
		public static function getClassFromKind(kind:uint):Class
		{
			var dataClass:Class;
			switch(kind)
			{
				case KIND_QName:
				case KIND_QNameA:
					dataClass = MultinameQNameToken;
					break;
				case KIND_RTQName:
				case KIND_RTQNameA:
					dataClass = MultinameRTQNameToken;
					break;
				case KIND_RTQNameL:
				case KIND_RTQNameLA:
					dataClass = MultinameRTQNameLToken;
					break;
				case KIND_Multiname:
				case KIND_MultinameA:
					dataClass = MultinameMultinameToken;
					break;
				case KIND_MultinameL:
				case KIND_MultinameLA:
					dataClass = MultinameMultinameLToken;
					break;
				case KIND_TypeName:
					dataClass = MultinameTypeNameToken;
					break;
			}
			return dataClass;
		}
		
		public var kind:uint;
		public var data:IMultiname;

		public function MultinameToken(kind:uint = 0, data:IMultiname = null)
		{
			this.kind = kind;
			this.data = data;
		}
	}
}