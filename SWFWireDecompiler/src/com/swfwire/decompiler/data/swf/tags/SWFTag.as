package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	
	public class SWFTag
	{
		public var header:TagHeaderRecord;
		
		public function SWFTag(header:TagHeaderRecord = null)
		{
			if(!header)
			{
				header = new TagHeaderRecord();
			}
			
			this.header = header;
		}
	}
}