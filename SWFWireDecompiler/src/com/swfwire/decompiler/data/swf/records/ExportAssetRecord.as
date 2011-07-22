package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class ExportAssetRecord
	{
		public var tag:uint;
		public var name:String;

		public function ExportAssetRecord(tag:uint = 0, name:String = '')
		{
			this.tag = tag;
			this.name = name;
		}
	}
}