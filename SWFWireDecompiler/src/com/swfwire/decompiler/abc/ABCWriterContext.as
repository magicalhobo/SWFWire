package com.swfwire.decompiler.abc
{
	public class ABCWriterContext
	{
		public var bytes:ABCByteArray;
		public var result:ABCWriteResult;
		
		public function ABCWriterContext(bytes:ABCByteArray, result:ABCWriteResult)
		{
			this.bytes = bytes;
			this.result = result;
		}
	}
}