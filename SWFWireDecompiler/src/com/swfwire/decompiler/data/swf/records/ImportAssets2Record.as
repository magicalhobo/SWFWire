package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class ImportAssets2Record implements IRecord
	{
		public var tag:uint;
		public var name:String;

		public function ImportAssets2Record(tag:uint = 0, name:String = '')
		{
			this.tag = tag;
			this.name = name;
		}
	}
}