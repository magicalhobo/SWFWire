package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;

	public interface IToken
	{
		function read(abc:ABCByteArray):void;
		function write(abc:ABCByteArray):void;
	}
}