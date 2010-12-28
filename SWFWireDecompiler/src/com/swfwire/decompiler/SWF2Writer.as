package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf2.records.*;
	import com.swfwire.decompiler.data.swf2.tags.*;

	public class SWF2Writer extends SWFWriter
	{
		public static const TAG_IDS:Object = {
			17: DefineButtonSoundTag,
			20: DefineBitsLosslessTag,
			23: DefineButtonCxformTag,
			24: ProtectTag,
			21: DefineBitsJPEG2Tag,
			22: DefineShape2Tag
		};
		
		private static var FILE_VERSION:uint = 2;
		
		public function SWF2Writer()
		{
			version = FILE_VERSION;
			registerTags(TAG_IDS);
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case DefineBitsJPEG2Tag:
					writeDefineBitsJPEG2Tag(context, DefineBitsJPEG2Tag(tag));
					break;
				case DefineShape2Tag:
					writeDefineShape2Tag(context, DefineShape2Tag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeDefineBitsJPEG2Tag(context:SWFWriterContext, tag:DefineBitsJPEG2Tag):void
		{
			context.bytes.writeUI16(tag.characterID);
			if(tag.imageData.length > 0)
			{
				tag.imageData.position = 0;
				context.bytes.writeBytes(tag.imageData);
			}
		}
		
		protected function writeDefineShape2Tag(context:SWFWriterContext, tag:DefineShape2Tag):void
		{
			context.bytes.writeUI16(tag.shapeId);
			writeRectangleRecord(context, tag.shapeBounds);
			writeShapeWithStyleRecord2(context, tag.shapes);
		}
		
		protected function writeFillStyleArrayRecord2(context:SWFWriterContext, record:FillStyleArrayRecord2):void
		{
			context.bytes.writeUI8(record.count);
			if(record.count == 0xFF)
			{
				context.bytes.writeUI16(record.countExtended);
			}
			for(var iter:uint = 0; iter < record.fillStyles.length; iter++)
			{
				writeFillStyleRecord(context, record.fillStyles[iter]);
			}
		}

		protected function writeShapeRecord2(context:SWFWriterContext, numFillBits:uint, numLineBits:uint, record:IShapeRecord):void
		{
			if(record is StyleChangeRecord2)
			{
				context.bytes.writeFlag(false);
				var styleChangeRecord:StyleChangeRecord2 = StyleChangeRecord2(record);
				context.bytes.writeFlag(styleChangeRecord.stateNewStyles);
				context.bytes.writeFlag(styleChangeRecord.stateLineStyle);
				context.bytes.writeFlag(styleChangeRecord.stateFillStyle1);
				context.bytes.writeFlag(styleChangeRecord.stateFillStyle0);
				context.bytes.writeFlag(styleChangeRecord.stateMoveTo);
				writeStyleChangeRecord2(context,
					styleChangeRecord.stateNewStyles,
					styleChangeRecord.stateLineStyle,
					styleChangeRecord.stateFillStyle1,
					styleChangeRecord.stateFillStyle0,
					styleChangeRecord.stateMoveTo,
					numFillBits,
					numLineBits,
					styleChangeRecord);
			}
			else if(record is StraightEdgeRecord)
			{
				context.bytes.writeFlag(true);
				context.bytes.writeFlag(true);
				writeStraightEdgeRecord(context, StraightEdgeRecord(record));
			}
			else if(record is CurvedEdgeRecord)
			{
				context.bytes.writeFlag(true);
				context.bytes.writeFlag(false);
				writeCurvedEdgeRecord(context, CurvedEdgeRecord(record));
			}
			else if(record is EndShapeRecord)
			{
				context.bytes.writeUB(6, 0);
			}
			else
			{
				throw new Error('Unknown record.');
			}

		}
		
		protected function writeStyleChangeRecord2(context:SWFWriterContext, stateNewStyles:Boolean,
												  stateLineStyle:Boolean, stateFillStyle1:Boolean,
												  stateFillStyle0:Boolean, stateMoveTo:Boolean, 
												  numFillBits:uint, numLineBits:uint, record:StyleChangeRecord2):void
		{
			if(stateMoveTo)
			{
				context.bytes.writeUB(5, record.moveBits);
				context.bytes.writeSB(record.moveBits, record.moveDeltaX);
				context.bytes.writeSB(record.moveBits, record.moveDeltaY);
			}
			if(stateFillStyle0)
			{
				context.bytes.writeUB(numFillBits, record.fillStyle0);
			}
			if(stateFillStyle1)
			{
				context.bytes.writeUB(numFillBits, record.fillStyle1);
			}
			if(stateLineStyle)
			{
				context.bytes.writeUB(numLineBits, record.lineStyle);
			}
			if(stateNewStyles)
			{
				writeFillStyleArrayRecord2(context, record.fillStyles);
				writeLineStyleArrayRecord(context, record.lineStyles);
				context.bytes.writeUB(4, record.numFillBits);
				context.bytes.writeUB(4, record.numLineBits);
			}
		}

		protected function writeShapeWithStyleRecord2(context:SWFWriterContext, record:ShapeWithStyleRecord2):void
		{
			writeFillStyleArrayRecord2(context, record.fillStyles);
			writeLineStyleArrayRecord(context, record.lineStyles);
			var numFillBits:uint = record.numFillBits;
			var numLineBits:uint = record.numLineBits;
			context.bytes.writeUB(4, numFillBits);
			context.bytes.writeUB(4, numLineBits);
			
			for(var iter:uint = 0; iter < record.shapeRecords.length; iter++)
			{
				var shapeRecord:IShapeRecord = record.shapeRecords[iter];
				writeShapeRecord2(context, numFillBits, numLineBits, shapeRecord);
				if(shapeRecord is StyleChangeRecord2)
				{
					if(StyleChangeRecord2(shapeRecord).stateNewStyles)
					{
						numFillBits = StyleChangeRecord2(shapeRecord).numFillBits;
						numLineBits = StyleChangeRecord2(shapeRecord).numLineBits;
					}
				}
				if(shapeRecord is EndShapeRecord)
				{
					break;
				}
			}
		}
	}
}