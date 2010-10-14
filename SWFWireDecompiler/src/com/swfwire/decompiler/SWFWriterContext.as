package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class SWFWriterContext
	{
		public var fileVersion:uint;
		public var bytes:SWFByteArray;
		public var result:SWFWriteResult;
		
		public var tagId:int;
		public var tagStack:Vector.<SWFTag>;
		
		public function SWFWriterContext(bytes:SWFByteArray, fileVersion:uint, result:SWFWriteResult)
		{
			this.bytes = bytes;
			this.fileVersion = fileVersion;
			this.result = result;
			
			this.tagStack = new Vector.<SWFTag>;
		}
	}
}