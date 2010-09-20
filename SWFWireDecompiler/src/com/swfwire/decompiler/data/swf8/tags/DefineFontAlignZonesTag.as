package com.swfwire.decompiler.data.swf8.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf8.records.ZoneRecord;
	
	public class DefineFontAlignZonesTag extends SWFTag
	{
		public var fontId:uint;
		public var csmTableHint:uint;
		public var reserved:uint;
		public var zoneTable:Vector.<ZoneRecord>;
	}
}