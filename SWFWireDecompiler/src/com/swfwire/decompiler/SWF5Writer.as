package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.ExportAssetRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf5.tags.*;
	
	public class SWF5Writer extends SWF4Writer
	{
		public static const TAG_IDS:Object = {
			57: ImportAssetsTag,
			58: EnableDebuggerTag,
			56: ExportAssetsTag
		};
		
		private static var FILE_VERSION:uint = 5;
		
		public function SWF5Writer()
		{
			version = FILE_VERSION;
			registerTags(TAG_IDS);
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case ExportAssetsTag:
					writeExportAssetsTag(context, ExportAssetsTag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeExportAssetRecord(context:SWFWriterContext, record:ExportAssetRecord):void
		{
			context.bytes.writeUI16(record.tag);
			context.bytes.writeString(record.name);
		}

		protected function writeExportAssetsTag(context:SWFWriterContext, tag:ExportAssetsTag):void
		{
			var count:uint = tag.tags.length;
			context.bytes.writeUI16(count);
			for(var iter:uint = 0; iter < count; iter++)
			{
				writeExportAssetRecord(context, tag.tags[iter]);
			}
		}
	}
}