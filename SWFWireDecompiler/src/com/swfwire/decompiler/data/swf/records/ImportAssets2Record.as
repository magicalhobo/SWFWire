package com.swfwire.decompiler.data.swf.records
{
	public class ImportAssets2Record
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