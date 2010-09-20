package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	
	public class SWFTag
	{
		private var _header:TagHeaderRecord;
		public function get header():TagHeaderRecord
		{
			return _header;
		}
		public function set header(value:TagHeaderRecord):void
		{
			_header = value;
		}
		
		public function SWFTag()
		{
			//throw new Error('Class SWFTag cannot be instantiated');
		}
		/*
		public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
		}
		public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
		}
		public function normalize():void
		{
		}
		*/
	}
}