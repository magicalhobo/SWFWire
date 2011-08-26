package com.swfwire.decompiler.abc
{
	import flash.utils.ByteArray;

	public class ABCWriteResult
	{
		public var bytes:ByteArray;
		public var metadata:ABCWriterMetadata;
		
		public function ABCWriteResult(bytes:ByteArray = null, metadata:ABCWriterMetadata = null)
		{
			if(!bytes)
			{
				bytes = new ByteArray();
			}
			if(!metadata)
			{
				metadata = new ABCWriterMetadata();
			}
			
			this.bytes = bytes;
			this.metadata = metadata;
		}
	}
}