package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.ClipActionRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.ActionRecord;
	import com.swfwire.decompiler.SWF5Reader;
	import com.swfwire.decompiler.data.swf6.tags.*;

	public class SWF6Reader extends SWF5Reader
	{
		private static var FILE_VERSION:uint = 6;
		
		public function SWF6Reader()
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
					case 60: tag = readDefineVideoStreamTag(context, header);
					case 61: tag = readVideoFrameTag(context, header);
					case 62: tag = readDefineFontInfo2Tag(context, header);
					*/
					case 59:
						tag = readDoInitActionTag(context, header);
						break;
					case 64:
						tag = readEnableDebugger2Tag(context, header);
						break;
					default:
						tag = super.readTag(context, header);
						break;
				}
			}
			return tag;
		}
		
		protected function readDoInitActionTag(context:SWFReaderContext, header:TagHeaderRecord):DoInitActionTag
		{
			var tag:DoInitActionTag = new DoInitActionTag();
			tag.spriteId = context.bytes.readUI16();
			tag.actions = new Vector.<ActionRecord>();
			while(true)
			{
				var originalPosition:uint = context.bytes.getBytePosition();
				if(context.bytes.readUI8() == 0)
				{
					break;
				}
				context.bytes.setBytePosition(originalPosition);
				tag.actions.push(readActionRecord(context));
			}
			return tag;
		}
		
		protected function readEnableDebugger2Tag(context:SWFReaderContext, header:TagHeaderRecord):EnableDebugger2Tag
		{
			var tag:EnableDebugger2Tag = new EnableDebugger2Tag();
			tag.reserved = context.bytes.readUI16();
			tag.password = context.bytes.readString();
			return tag;
		}
		
		override protected function readClipActionsRecord(context:SWFReaderContext):ClipActionsRecord
		{
			var record:ClipActionsRecord = new ClipActionsRecord();
			
			record.reserved = context.bytes.readUI16();
			record.allEventFlags = readClipEventFlagsRecord(context);
			
			context.bytes.alignBytes();
			
			record.clipActionRecords = new Vector.<ClipActionRecord>();
			var originalPosition:uint;
			while(true)
			{
				originalPosition = context.bytes.getBytePosition();
				if(context.bytes.readUI32() == 0)
				{
					break;
				}
				context.bytes.setBytePosition(originalPosition);
				var clipActionRecord:ClipActionRecord = readClipActionRecord(context);
				record.clipActionRecords.push(clipActionRecord);
			}
			
			return record;
		}
		

		/*
		protected function getFillStyle(type:uint, parent:Class):Class
		{
			switch(type)
			{
				case 0x00:
					if(parent is DefineShapeTag || parent is DefineShape2Tag)
					{
						return FillStyleSolid;
					}
					else
					{
						return FillStyleSolidShape3;
					}
					break;
				case 0x10:
					return FillStyleLinearGradient;
					break;
				case 0x12:
					return FillStyleRadialGradient;
					break;
				case 0x40:
					return FillStyleRepeatingBitmapFill;
					break;
				case 0x41:
					return FillStyleClippedBitmapFill;
					break;
				case 0x42:
					return FillStyleNonSmoothedRepeatingBitmap;
					break;
				case 0x43:
					return FillStyleNonSmoothedClippedBitmap;
					break;
			}
			return null;
		}
		*/
	}
}