package com.swfwire.decompiler
{
	import com.swfwire.decompiler.SWF4Reader;
	import com.swfwire.decompiler.data.swf.records.ClipActionRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.records.ClipEventFlagsRecord;
	import com.swfwire.decompiler.data.swf.records.ExportAssetRecord;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.ActionRecord;
	import com.swfwire.decompiler.data.swf3.tags.PlaceObject2Tag;
	import com.swfwire.decompiler.data.swf5.tags.ExportAssetsTag;
	
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
		
		override protected function readPlaceObject2Tag(context:SWFReaderContext, header:TagHeaderRecord):PlaceObject2Tag
		{
			var tag:PlaceObject2Tag = new PlaceObject2Tag();
			var placeFlagHasClipActions:Boolean = context.bytes.readFlag();
			var placeFlagHasClipDepth:Boolean = context.bytes.readFlag();
			var placeFlagHasName:Boolean = context.bytes.readFlag();
			var placeFlagHasRatio:Boolean = context.bytes.readFlag();
			var placeFlagHasColorTransform:Boolean = context.bytes.readFlag();
			var placeFlagHasMatrix:Boolean = context.bytes.readFlag();
			var placeFlagHasCharacter:Boolean = context.bytes.readFlag();
			
			tag.move = context.bytes.readFlag();
			
			tag.depth = context.bytes.readUI16();
			
			if(placeFlagHasCharacter)
			{
				tag.characterId = context.bytes.readUI16();
			}
			
			if(placeFlagHasMatrix)
			{
				tag.matrix = readMatrixRecord(context);
			}
			
			if(placeFlagHasColorTransform)
			{
				tag.colorTransform = readCXFormWithAlphaRecord(context);
			}
			
			if(placeFlagHasRatio)
			{
				tag.ratio = context.bytes.readUI16();
			}
			
			if(placeFlagHasName)
			{
				tag.name = context.bytes.readString();
			}
			
			if(placeFlagHasClipDepth)
			{
				tag.clipDepth = context.bytes.readUI16();
			}
			
			if(placeFlagHasClipActions)
			{
				tag.clipActions = readClipActionsRecord(context);
			}
			return tag;
		}

		protected function readClipActionsRecord(context:SWFReaderContext):ClipActionsRecord
		{
			var record:ClipActionsRecord = new ClipActionsRecord();
			
			record.reserved = context.bytes.readUI16();
			record.allEventFlags = readClipEventFlagsRecord(context);
			
			context.bytes.alignBytes();
			
			record.clipActionRecords = new Vector.<ClipActionRecord>();
			
			while(true)
			{
				var originalPosition:uint = context.bytes.getBytePosition();
				if(context.bytes.readUI16() == 0)
				{
					break;
				}
				context.bytes.setBytePosition(originalPosition);
				var clipActionRecord:ClipActionRecord = readClipActionRecord(context);
				record.clipActionRecords.push(clipActionRecord);
			}
			
			return record;
		}
		
		protected function readClipEventFlagsRecord(context:SWFReaderContext):ClipEventFlagsRecord
		{
			var record:ClipEventFlagsRecord = new ClipEventFlagsRecord();
			record.keyUp = context.bytes.readFlag();
			record.keyDown = context.bytes.readFlag();
			record.mouseUp = context.bytes.readFlag();
			record.mouseDown = context.bytes.readFlag();
			record.mouseMove = context.bytes.readFlag();
			record.unload = context.bytes.readFlag();
			record.enterFrame = context.bytes.readFlag();
			record.load = context.bytes.readFlag();
			record.dragOver = context.bytes.readFlag();
			record.rollOut = context.bytes.readFlag();
			record.rollOver = context.bytes.readFlag();
			record.releaseOutside = context.bytes.readFlag();
			record.release = context.bytes.readFlag();
			record.press = context.bytes.readFlag();
			record.initialize = context.bytes.readFlag();
			record.data = context.bytes.readFlag();
			record.construct = context.bytes.readFlag();
			record.keyPress = context.bytes.readFlag();
			record.dragOut = context.bytes.readFlag();
			return record;
		}
		
		protected function readClipActionRecord(context:SWFReaderContext):ClipActionRecord
		{
			var record:ClipActionRecord = new ClipActionRecord();
			record.eventFlags = readClipEventFlagsRecord(context);
			record.actionRecordSize = context.bytes.readUI32();
			
			if(record.eventFlags.keyPress)
			{
				record.keyCode = context.bytes.readUI8();
			}
			
			record.actions = new Vector.<ActionRecord>();
			
			while(true)
			{
				var originalPosition:uint = context.bytes.getBytePosition();
				if(context.bytes.readUI8() == 0)
				{
					break;
				}
				context.bytes.setBytePosition(originalPosition);
				record.actions.push(readActionRecord(context));
			}
			
			return record;
		}
	}
}