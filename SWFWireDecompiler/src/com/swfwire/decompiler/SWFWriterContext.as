package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	import flash.utils.ByteArray;

	public class SWFWriterContext
	{
		public var fileVersion:uint;
		public var bytes:SWFByteArray;
		public var tagBytes:Vector.<ByteArray>;
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