package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf6.tags.EnableDebugger2Tag;
	
	public class SWF6Writer extends SWF5Writer
	{
		public static const TAG_IDS:Object = {
			64: EnableDebugger2Tag
		};
		
		private static var FILE_VERSION:uint = 6;
		
		public function SWF6Writer()
		{
			version = FILE_VERSION;
			registerTags(TAG_IDS);
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case EnableDebugger2Tag:
					writeEnableDebugger2Tag(context, EnableDebugger2Tag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeEnableDebugger2Tag(context:SWFWriterContext, tag:EnableDebugger2Tag):void
		{
			context.bytes.writeUI16(tag.reserved);
			context.bytes.writeString(tag.password);
		}
		
		override protected function writeClipActionsRecord(context:SWFWriterContext, record:ClipActionsRecord):void
		{
			context.bytes.writeUI16(record.reserved);
			writeClipEventFlagsRecord(context, record.allEventFlags);
			
			context.bytes.alignBytes();
			
			for(var iter:uint = 0; iter < record.clipActionRecords.length; iter++)
			{
				writeClipActionRecord(context, record.clipActionRecords[iter]);
			}
			
			context.bytes.writeUI32(0);
		}
	}
}