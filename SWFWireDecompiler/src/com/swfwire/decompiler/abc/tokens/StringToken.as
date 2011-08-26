package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.utils.ByteArrayUtil;

	public class StringToken implements IToken
	{
		public var utf8:String;
		
		public function StringToken(utf8:String = '')
		{
			this.utf8 = utf8;
		}
	}
}