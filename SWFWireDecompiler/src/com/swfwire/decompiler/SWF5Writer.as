package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.ClipActionRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.records.ClipEventFlagsRecord;
	import com.swfwire.decompiler.data.swf.records.ExportAssetRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.tags.PlaceObject2Tag;
	import com.swfwire.decompiler.data.swf5.tags.EnableDebuggerTag;
	import com.swfwire.decompiler.data.swf5.tags.ExportAssetsTag;
	import com.swfwire.decompiler.data.swf5.tags.ImportAssetsTag;
	
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
		
		override protected function writePlaceObject2Tag(context:SWFWriterContext, tag:PlaceObject2Tag):void
		{
			context.bytes.writeFlag(tag.clipActions != null);
			context.bytes.writeFlag(tag.clipDepth != null);
			context.bytes.writeFlag(tag.name != null);
			context.bytes.writeFlag(tag.ratio != null);
			context.bytes.writeFlag(tag.colorTransform != null);
			context.bytes.writeFlag(tag.matrix != null);
			context.bytes.writeFlag(tag.characterId != null);
			
			context.bytes.writeFlag(tag.move);
			
			context.bytes.writeUI16(tag.depth);
			
			if(tag.characterId)
			{
				context.bytes.writeUI16(uint(tag.characterId));
			}
			
			if(tag.matrix)
			{
				writeMatrixRecord(context, tag.matrix);
			}
			
			if(tag.colorTransform)
			{
				writeCXFormWithAlphaRecord(context, tag.colorTransform);
			}
			
			if(tag.ratio)
			{
				context.bytes.writeUI16(uint(tag.ratio));
			}
			
			if(tag.name)
			{
				context.bytes.writeString(tag.name);
			}
			
			if(tag.clipDepth)
			{
				context.bytes.writeUI16(uint(tag.clipDepth));
			}
			
			if(tag.clipActions)
			{
				writeClipActionsRecord(context, tag.clipActions);
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
		
		protected function writeClipActionsRecord(context:SWFWriterContext, record:ClipActionsRecord):void
		{
			context.bytes.writeUI16(record.reserved);
			writeClipEventFlagsRecord(context, record.allEventFlags);
			
			context.bytes.alignBytes();
			
			for(var iter:uint = 0; iter < record.clipActionRecords.length; iter++)
			{
				writeClipActionRecord(context, record.clipActionRecords[iter]);
			}
			
			context.bytes.writeUI16(0);
		}
		
		protected function writeClipEventFlagsRecord(context:SWFWriterContext, record:ClipEventFlagsRecord):void
		{
			context.bytes.writeFlag(record.keyUp);
			context.bytes.writeFlag(record.keyDown);
			context.bytes.writeFlag(record.mouseUp);
			context.bytes.writeFlag(record.mouseDown);
			context.bytes.writeFlag(record.mouseMove);
			context.bytes.writeFlag(record.unload);
			context.bytes.writeFlag(record.enterFrame);
			context.bytes.writeFlag(record.load);
			context.bytes.writeFlag(record.dragOver);
			context.bytes.writeFlag(record.rollOut);
			context.bytes.writeFlag(record.rollOver);
			context.bytes.writeFlag(record.releaseOutside);
			context.bytes.writeFlag(record.release);
			context.bytes.writeFlag(record.press);
			context.bytes.writeFlag(record.initialize);
			context.bytes.writeFlag(record.data);
			context.bytes.writeFlag(record.construct);
			context.bytes.writeFlag(record.keyPress);
			context.bytes.writeFlag(record.dragOut);
		}
		
		protected function writeClipActionRecord(context:SWFWriterContext, record:ClipActionRecord):void
		{
			writeClipEventFlagsRecord(context, record.eventFlags);
			context.bytes.writeUI32(record.actionRecordSize);
			
			if(record.eventFlags.keyPress)
			{
				context.bytes.writeUI8(record.keyCode);
			}
			
			for(var iter:uint = 0; iter < record.actions.length; iter++)
			{
				writeActionRecord(context, record.actions[iter]);
			}
			
			context.bytes.writeUI8(0);
		}
	}
}