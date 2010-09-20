package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class SWFReaderContext
	{
		public var bytes:SWFByteArray;
		public var fileVersion:uint;
		public var result:SWFReadResult;
		
		public var fontGlyphCounts:Object;
		public var tagId:int;
		public var tagStack:Vector.<SWFTag>;
		
		public function SWFReaderContext(bytes:SWFByteArray, fileVersion:uint, result:SWFReadResult)
		{
			this.bytes = bytes;
			this.fileVersion = fileVersion;
			this.result = result;
			
			tagStack = new Vector.<SWFTag>();
			fontGlyphCounts = {};
		}
		
		public function pushTag(tag:SWFTag):void
		{
			tagStack.push(tag);
		}
		
		public function popTag(tag:SWFTag):void
		{
			tagStack.pop();
		}
	}
}