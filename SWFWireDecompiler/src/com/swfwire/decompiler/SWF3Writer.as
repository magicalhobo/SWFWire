package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf3.records.GradientControlPointRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientRecord2;
	import com.swfwire.decompiler.data.swf3.tags.DefineBitsJPEG3Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineBitsLossless2Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineButton2Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineFont2Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineMorphShapeTag;
	import com.swfwire.decompiler.data.swf3.tags.DefineShape3Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineSpriteTag;
	import com.swfwire.decompiler.data.swf3.tags.DefineText2Tag;
	import com.swfwire.decompiler.data.swf3.tags.DoActionTag;
	import com.swfwire.decompiler.data.swf3.tags.FrameLabelTag;
	import com.swfwire.decompiler.data.swf3.tags.PlaceObject2Tag;
	import com.swfwire.decompiler.data.swf3.tags.RemoveObject2Tag;
	import com.swfwire.decompiler.data.swf3.tags.SoundStreamHead2Tag;
	import com.swfwire.utils.Debug;

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