package com.swfwire.decompiler
{
	import com.swfwire.decompiler.SWF5Reader;
	import com.swfwire.decompiler.data.swf.records.ClipActionRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.ActionRecord;
	import com.swfwire.decompiler.data.swf6.records.IVideoPacketRecord;
	import com.swfwire.decompiler.data.swf6.records.VP6SWFVideoPacketRecord;
	import com.swfwire.decompiler.data.swf6.tags.DefineVideoStreamTag;
	import com.swfwire.decompiler.data.swf6.tags.DoInitActionTag;
	import com.swfwire.decompiler.data.swf6.tags.EnableDebugger2Tag;
	import com.swfwire.decompiler.data.swf6.tags.VideoFrameTag;

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
					case 62: tag = readDefineFontInfo2Tag(context, header);
					*/
					case 59:
						tag = readDoInitActionTag(context, header);
						break;
					case 60: 
						tag = readDefineVideoStreamTag(context, header);
						break;
					case 61:
						tag = readVideoFrameTag(context, header);
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
		
		protected function readDefineVideoStreamTag(context:SWFReaderContext, header:TagHeaderRecord):DefineVideoStreamTag
		{
			var tag:DefineVideoStreamTag = new DefineVideoStreamTag();
			tag.characterId = context.bytes.readUI16();
			tag.numFrames = context.bytes.readUI16();
			tag.width = context.bytes.readUI16();
			tag.height = context.bytes.readUI16();
			var reserved:uint = context.bytes.readUB(4);
			tag.videoFlagsDeblocking = context.bytes.readUB(3);
			tag.videoFlagsSmoothing = context.bytes.readFlag();
			tag.codecId = context.bytes.readUI8();
			context.videoStreams[tag.characterId] = tag;
			return tag;
		}
		
		protected function readVideoFrameTag(context:SWFReaderContext, header:TagHeaderRecord):VideoFrameTag
		{
			var tag:VideoFrameTag = new VideoFrameTag();
			tag.streamId = context.bytes.readUI16();
			tag.frameNum = context.bytes.readUI16();
			var videoStreamTag:DefineVideoStreamTag = context.videoStreams[tag.streamId] as DefineVideoStreamTag;
			if(videoStreamTag)
			{
				switch(videoStreamTag.codecId)
				{
					/*
					case 2:
						tag.videoData = readH263VideoPacketRecord();
						break;
					case 3:
						tag.videoData = readScreenVideoPacketRecord();
						break;
					*/
					case 4:
						tag.videoData = readVP6SWFVideoPacketRecord(context);
						break;
					/*
					case 5:
						tag.videoData = readVP6SWFAlphaVideoPacketRecord();
						break;
					case 6:
						tag.videoData = readScreenV2VideoPacketRecord();
						break;
					*/
					default:
						context.result.errors.push('Invalid codec id: ' + videoStreamTag.codecId);
						break;
				}
			}
			else
			{
				context.result.errors.push('Video stream id ' + tag.streamId + ' not found while reading VideoFrameTag.');
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
			
			while(true)
			{
				var originalPosition:uint = context.bytes.getBytePosition();
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
		
		private function readVP6SWFVideoPacketRecord(context:SWFReaderContext):VP6SWFVideoPacketRecord
		{
			var record:VP6SWFVideoPacketRecord = new VP6SWFVideoPacketRecord();
			var remaining:int = context.currentTagEnd - context.bytes.getBytePosition();
			context.bytes.readBytes(record.data, 0, remaining);
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