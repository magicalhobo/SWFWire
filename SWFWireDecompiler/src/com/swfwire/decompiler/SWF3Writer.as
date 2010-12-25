package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.GradientControlPointRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientRecord2;
	import com.swfwire.decompiler.data.swf3.tags.*;

	public class SWF3Writer extends SWFWriter
	{
		public static const TAG_IDS:Object = {
			12: DoActionTag,
			26: PlaceObject2Tag,
			28: RemoveObject2Tag,
			32: DefineShape3Tag,
			33: DefineText2Tag,
			34: DefineButton2Tag,
			35: DefineBitsJPEG3Tag,
			36: DefineBitsLossless2Tag,
			39: DefineSpriteTag,
			43: FrameLabelTag,
			45: SoundStreamHead2Tag,
			46: DefineMorphShapeTag,
			48: DefineFont2Tag
		};
		
		private static var FILE_VERSION:uint = 3;
		
		public function SWF3Writer()
		{
			version = FILE_VERSION;
			registerTags(TAG_IDS);
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case PlaceObject2Tag:
					writePlaceObject2Tag(context, PlaceObject2Tag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writePlaceObject2Tag(context:SWFWriterContext, tag:PlaceObject2Tag):void
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
				//tag.colorTransform = readCXFormWithAlphaRecord(context);
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
				//tag.clipActions = readClipActionsRecord(context);
			}
		}
		
		protected function writeGradientControlPointRecord2(context:SWFWriterContext, record:GradientControlPointRecord2):void
		{
			context.bytes.writeUI8(record.ratio);
			writeRGBARecord(context, record.color);
		}
		
		protected function writeGradientRecord2(context:SWFWriterContext, record:GradientRecord2):void
		{
			context.bytes.alignBytes();
			
			context.bytes.writeUB(2, record.spreadMode);
			context.bytes.writeUB(2, record.interpolationMode);
			context.bytes.writeUB(4, record.numGradients);
			for(var iter:uint = 0; iter < record.numGradients; iter++)
			{
				writeGradientControlPointRecord2(context, record.gradientRecords[iter]);
			}
		}
	}
}