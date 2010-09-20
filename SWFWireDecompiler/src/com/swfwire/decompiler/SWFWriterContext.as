package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class SWFWriterContext
	{
		public var uncompressedBytes:SWFByteArray;
		public var bytes:SWFByteArray;
		public var fileVersion:uint;
		public var tagId:int;
		public var tagStack:Vector.<SWFTag>;
		
		public function SWFWriterContext(uncompressedBytes:SWFByteArray, bytes:SWFByteArray, fileVersion:uint)
		{
			this.uncompressedBytes = uncompressedBytes;
			this.bytes = bytes;
			this.fileVersion = fileVersion;
			this.tagStack = new Vector.<SWFTag>;
		}
	}
}