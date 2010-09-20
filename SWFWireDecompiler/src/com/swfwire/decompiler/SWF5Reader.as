package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.ExportAssetRecord;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.SWF4Reader;
	import com.swfwire.decompiler.data.swf5.tags.*;
	
	public class SWF5Reader extends SWF4Reader
	{
		private static var FILE_VERSION:uint = 5;
		
		public function SWF5Reader()
		{
			version = FILE_VERSION;
		}
		
		override protected function readTag(context:SWFReaderContext, header:TagHeaderRecord):SWFTag
		{
			var tag:SWFTag;
			if(context.fileVersion < FILE_VERSION)
			{
				tag = super.readTag(context, header);
			}
			else
			{
				switch(header.type)
				{
					/*
					case 57: tag = readImportAssetsTag(context, header);
					case 58: tag = readEnableDebuggerTag(context, header);
					*/
					case 56:
						tag = readExportAssetsTag(context, header);
						break;
					default:
						tag = super.readTag(context, header);
						break;
				}
			}
			return tag;
		}
		
		protected function readExportAssetRecord(context:SWFReaderContext):ExportAssetRecord
		{
			var record:ExportAssetRecord = new ExportAssetRecord();
			record.tag = context.bytes.readUI16();
			record.name = context.bytes.readString();
			return record;
		}
		
		protected function readExportAssetsTag(context:SWFReaderContext, header:TagHeaderRecord):ExportAssetsTag
		{
			var tag:ExportAssetsTag = new ExportAssetsTag();
			
			var count:uint = context.bytes.readUI16();
			tag.tags = new Vector.<ExportAssetRecord>(count);
			for(var iter:uint = 0; iter < count; iter++)
			{
				tag.tags[iter] = readExportAssetRecord(context);
			}
			
			return tag;
		}
	}
}