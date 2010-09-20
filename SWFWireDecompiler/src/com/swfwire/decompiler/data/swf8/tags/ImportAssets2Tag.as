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
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			var iter:uint;
			
			url = swfcontext.bytes.readString();
			
			var count:uint = swfcontext.bytes.readUI16();
			tags = new Vector.<ImportAssets2Record>(count);
			for(iter = 0; iter < count; iter++)
			{
				var tag:ImportAssets2Record = new ImportAssets2Record();
				tag.read(swfBytes);
				tags[iter] = tag;
			}
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			var iter:uint;
			
			swfBytes.writeUI16(tags.length);
			for(iter = 0; iter < tags.length; iter++)
			{
				tags[iter].write(swfBytes);
			}
		}
		*/
	}
}