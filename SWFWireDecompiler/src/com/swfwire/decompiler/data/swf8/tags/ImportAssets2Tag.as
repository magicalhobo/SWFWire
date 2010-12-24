package com.swfwire.decompiler.data.swf8.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.ImportAssets2Record;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	public class ImportAssets2Tag extends SWFTag
	{
		public var url:String;
		public var tags:Vector.<ImportAssets2Record>;

		public function ImportAssets2Tag(url:String = '', tags:Vector.<ImportAssets2Record> = null)
		{
			if(tags == null)
			{
				tags = new Vector.<ImportAssets2Record>();
			}

			this.url = url;
			this.tags = tags;
		}
	}
}