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
		
		public function read(abc:ABCByteArray):void
		{
			var size:uint = abc.readU30();
			utf8 = abc.readString(size);
		}
		public function write(abc:ABCByteArray):void
		{
			var size:uint = ByteArrayUtil.getUTF8Length(utf8);
			abc.writeU30(size);
			abc.writeString(utf8);
		}
	}
}