package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class ParamInfoToken implements IToken
	{
		public var value:uint;

		public function ParamInfoToken(value:uint = 0)
		{
			this.value = value;
		}
		
		public function read(abc:ABCByteArray):void
		{
			value = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(value);
		}
	}
}