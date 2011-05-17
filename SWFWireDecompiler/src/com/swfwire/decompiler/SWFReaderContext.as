package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	/**
	 * Provides the context for SWFReader when reading a single tag.  
	 * <p>
	 * Necessary because parsing a tag could depend on previous tags.
	 * e.g. DefineFontAlignZonesTag requires data from any previously parsed DefineFont3Tag
	 * </p>
	 */
	public class SWFReaderContext
	{
		public var fileVersion:uint;
		public var bytes:SWFByteArray;
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
	}
}