package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	/**
	 * Allows known tags to be ignored to improve performance, in the case that you're only interested in certain tags.
	 */
	public class AsyncSWFReaderFiltered extends AsyncSWFReader
	{
		public var includedTags:Object = {};
		
		override protected function readTag(context:SWFReaderContext, header:TagHeaderRecord):SWFTag
		{
			if(includedTags[header.type])
			{
				return super.readTag(context, header);
			}
			else
			{
				return super.readUnknownTag(context, header);
			}
		}
	}
}