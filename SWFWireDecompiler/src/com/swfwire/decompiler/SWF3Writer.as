package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.CurvedEdgeRecord;
	import com.swfwire.decompiler.data.swf.records.EndShapeRecord;
	import com.swfwire.decompiler.data.swf.records.IShapeRecord;
	import com.swfwire.decompiler.data.swf.records.StraightEdgeRecord;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.EndTag;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.*;
	import com.swfwire.decompiler.data.swf3.tags.*;
	
	import flash.utils.ByteArray;

	public class SWF3Writer extends SWF2Writer
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
				case DefineShape3Tag:
					writeDefineShape3Tag(context, DefineShape3Tag(tag));
					break;
				case DefineBitsJPEG3Tag:
					writeDefineBitsJPEG3Tag(context, DefineBitsJPEG3Tag(tag));
					break;
				case DefineSpriteTag:
					writeDefineSpriteTag(context, DefineSpriteTag(tag));
					break;
				case FrameLabelTag:
					writeFrameLabelTag(context, FrameLabelTag(tag));
					break;
				case DefineBitsLossless2Tag:
					writeDefineBitsLossless2Tag(context, DefineBitsLossless2Tag(tag));
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
				throw new Error('writeClipActionsRecord not implemented.');
				//writeClipActionsRecord(context, tag.clipActions);
			}
		}

		protected function writeDefineShape3Tag(context:SWFWriterContext, tag:DefineShape3Tag):void
		{
			context.bytes.writeUI16(tag.shapeId);
			writeRectangleRecord(context, tag.shapeBounds);
			writeShapeWithStyleRecord3(context, tag.shapes);
		}
		
		protected function writeDefineBitsJPEG3Tag(context:SWFWriterContext, tag:DefineBitsJPEG3Tag):void
		{
			var startPosition:uint = context.bytes.getBytePosition();
			context.bytes.writeUI16(tag.characterID);
			context.bytes.writeUI32(tag.imageData.length);
			if(tag.imageData.length > 0)
			{
				context.bytes.writeBytes(tag.imageData);
			}
			if(tag.bitmapAlphaData.length > 0)
			{
				context.bytes.writeBytes(tag.bitmapAlphaData);
			}
		}
		
		protected function writeDefineSpriteTag(context:SWFWriterContext, tag:DefineSpriteTag):void
		{
			context.bytes.writeUI16(tag.spriteId);
			context.bytes.writeUI16(tag.frameCount);
			writeControlTags(context, tag.controlTags);
		}
		
		protected function writeControlTags(context:SWFWriterContext, tags:Vector.<SWFTag>):void
		{
			for(var iter:uint = 0; iter < tags.length; iter++)
			{
				var tag:SWFTag = tags[iter];
				writeTagHeaderRecord(context, tag.header);
				writeTag(context, tag);
				if(tag is EndTag)
				{
					break;
				}
			}
		}
		
		protected function writeFrameLabelTag(context:SWFWriterContext, tag:FrameLabelTag):void
		{
			context.bytes.writeString(tag.name);
		}
		
		protected function writeDefineBitsLossless2Tag(context:SWFWriterContext, tag:DefineBitsLossless2Tag):void
		{
			context.bytes.writeUI16(tag.characterId);
			context.bytes.writeUI8(tag.bitmapFormat);
			context.bytes.writeUI16(tag.bitmapWidth);
			context.bytes.writeUI16(tag.bitmapHeight);
			if(tag.bitmapFormat == 3)
			{
				context.bytes.writeUI8(tag.bitmapColorTableSize);
			}
			if(tag.bitmapFormat == 3 || tag.bitmapFormat == 4 || tag.bitmapFormat == 5)
			{
				var unzippedData:ByteArray = new ByteArray();
				
				var unzippedDataContext:SWFWriterContext = new SWFWriterContext(new SWFByteArray(unzippedData), context.fileVersion, context.result);
				
				if(tag.bitmapFormat == 3)
				{
					var imageDataSize:uint = (tag.bitmapWidth + (8 - (tag.bitmapWidth % 8))) * tag.bitmapHeight;
					writeAlphaColorMapDataRecord(unzippedDataContext, tag.zlibBitmapData);
				}
				else if(tag.bitmapFormat == 4 || tag.bitmapFormat == 5)
				{
					var imageDataSize2:uint = tag.bitmapWidth * tag.bitmapHeight;
					writeAlphaBitmapDataRecord(unzippedDataContext, tag.zlibBitmapData);
				}
				
				if(unzippedData.length > 0)
				{
					unzippedData.position = 0;
					unzippedData.compress();

					context.bytes.writeBytes(unzippedData);
				}
			}
		}
		
		protected function writeShapeWithStyleRecord3(context:SWFWriterContext, record:ShapeWithStyleRecord3):void
		{
			writeFillStyleArrayRecord3(context, record.fillStyles);
			writeLineStyleArrayRecord2(context, record.lineStyles);
			
			var numFillBits:uint = record.numFillBits;
			var numLineBits:uint = record.numLineBits;
			
			context.bytes.writeUB(4, numFillBits);
			context.bytes.writeUB(4, numLineBits);
			
			for(var iter:uint = 0; iter < record.shapeRecords.length; iter++) 
			{
				var shapeRecord:IShapeRecord = record.shapeRecords[iter];
				writeShapeRecord3(context, numFillBits, numLineBits, shapeRecord);
				
				if(shapeRecord is StyleChangeRecord3)
				{
					if(StyleChangeRecord3(shapeRecord).stateNewStyles)
					{
						numFillBits = StyleChangeRecord3(shapeRecord).numFillBits;
						numLineBits = StyleChangeRecord3(shapeRecord).numLineBits;
					}
				}
				if(shapeRecord is EndShapeRecord)
				{
					break;
				}
			}
		}
		
		protected function writeFillStyleArrayRecord3(context:SWFWriterContext, record:FillStyleArrayRecord3):void
		{
			var count:uint = record.fillStyles.length;
			
			if(count < 0xFF)
			{
				context.bytes.writeUI8(count);
			}
			else
			{
				context.bytes.writeUI8(0xFF);
				context.bytes.writeUI16(count);
			}

			for(var iter:uint = 0; iter < count; iter++)
			{
				writeFillStyleRecord2(context, record.fillStyles[iter]);
			}
		}
		
		protected function writeFillStyleRecord2(context:SWFWriterContext, record:FillStyleRecord2):void
		{
			var type:uint = record.type;
			
			context.bytes.writeUI8(type);
			if(type == 0x00)
			{
				writeRGBARecord(context, record.color);
			}
			if(type == 0x10 || type == 0x12)
			{
				writeMatrixRecord(context, record.gradientMatrix);
				writeGradientRecord2(context, GradientRecord2(record.gradient));
			}
			if(type == 0x40 || type == 0x41 || type == 0x42 || type == 0x43)
			{
				context.bytes.writeUI16(record.bitmapId);
				writeMatrixRecord(context, record.bitmapMatrix);
			}
		}
		
		protected function writeLineStyleArrayRecord2(context:SWFWriterContext, record:LineStyleArrayRecord2):void
		{
			var count:uint = record.lineStyles.length;
			
			if(count < 0xFF)
			{
				context.bytes.writeUI8(count);
			}
			else
			{
				context.bytes.writeUI8(0xFF);
				context.bytes.writeUI16(count);
			}
			
			for(var iter:uint = 0; iter < count; iter++)
			{
				writeLineStyleRecord2(context, record.lineStyles[iter]);
			}
		}
		
		protected function writeLineStyleRecord2(context:SWFWriterContext, record:LineStyleRecord2):void
		{
			context.bytes.writeUI16(record.width);
			writeRGBARecord(context, record.color);
		}
		
		protected function writeShapeRecord3(context:SWFWriterContext, numFillBits:uint, numLineBits:uint, record:IShapeRecord):void
		{
			if(record is StyleChangeRecord3)
			{
				context.bytes.writeFlag(false);
				var styleChangeRecord:StyleChangeRecord3 = StyleChangeRecord3(record);
				context.bytes.writeFlag(styleChangeRecord.stateNewStyles);
				context.bytes.writeFlag(styleChangeRecord.stateLineStyle);
				context.bytes.writeFlag(styleChangeRecord.stateFillStyle1);
				context.bytes.writeFlag(styleChangeRecord.stateFillStyle0);
				context.bytes.writeFlag(styleChangeRecord.stateMoveTo);
				writeStyleChangeRecord3(context,
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
		
		protected function writeStyleChangeRecord3(context:SWFWriterContext, stateNewStyles:Boolean,
												  stateLineStyle:Boolean, stateFillStyle1:Boolean,
												  stateFillStyle0:Boolean, stateMoveTo:Boolean, 
												  numFillBits:uint, numLineBits:uint, record:StyleChangeRecord3):void
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
				writeFillStyleArrayRecord3(context, record.fillStyles);
				writeLineStyleArrayRecord2(context, record.lineStyles);
				context.bytes.writeUB(4, record.numFillBits);
				context.bytes.writeUB(4, record.numLineBits);
			}
		}
		
		protected function writeAlphaColorMapDataRecord(context:SWFWriterContext, record:AlphaColorMapDataRecord):void
		{
			var colorTableSize:uint = record.colorTableRGB.length;
			for(var iter:uint = 0; iter < colorTableSize; iter++)
			{
				writeRGBARecord(context, record.colorTableRGB[iter]);
			}
			var imageDataSize:uint = record.colormapPixelData.length; 
			for(iter = 0; iter < imageDataSize; iter++)
			{
				context.bytes.writeUI8(record.colormapPixelData[iter]);
			}
		}
		
		protected function writeARGBRecord(context:SWFWriterContext, record:ARGBRecord):void
		{			
			context.bytes.writeUI8(record.alpha);
			context.bytes.writeUI8(record.red);
			context.bytes.writeUI8(record.green);
			context.bytes.writeUI8(record.blue);
		}
		
		protected function writeAlphaBitmapDataRecord(context:SWFWriterContext, record:AlphaBitmapDataRecord):void
		{
			var imageDataSize:uint = record.bitmapPixelData.length;
			for(var iter:uint = 0; iter < imageDataSize; iter++)
			{
				writeARGBRecord(context, record.bitmapPixelData[iter]);
			}
		}
		
		protected function writeCXFormWithAlphaRecord(context:SWFWriterContext, record:CXFormWithAlphaRecord):void
		{
			context.bytes.alignBytes();
			
			context.bytes.writeFlag(record.hasAddTerms);
			context.bytes.writeFlag(record.hasMultTerms);
			
			var nBits:uint = 0;
			
			if(record.hasMultTerms)
			{
				nBits = Math.max(nBits,
					SWFByteArray.calculateSBBits(record.redMultTerm),
					SWFByteArray.calculateSBBits(record.greenMultTerm),
					SWFByteArray.calculateSBBits(record.blueMultTerm),
					SWFByteArray.calculateSBBits(record.alphaMultTerm));
			}
			
			if(record.hasAddTerms)
			{
				nBits = Math.max(nBits,
					SWFByteArray.calculateSBBits(record.redAddTerm),
					SWFByteArray.calculateSBBits(record.greenAddTerm),
					SWFByteArray.calculateSBBits(record.blueAddTerm),
					SWFByteArray.calculateSBBits(record.alphaAddTerm));
			}
			
			context.bytes.writeUB(4, nBits);
			
			if(record.hasMultTerms)
			{
				context.bytes.writeSB(nBits, record.redMultTerm);
				context.bytes.writeSB(nBits, record.greenMultTerm);
				context.bytes.writeSB(nBits, record.blueMultTerm);
				context.bytes.writeSB(nBits, record.alphaMultTerm);
			}
			
			if(record.hasAddTerms)
			{
				context.bytes.writeSB(nBits, record.redAddTerm);
				context.bytes.writeSB(nBits, record.greenAddTerm);
				context.bytes.writeSB(nBits, record.blueAddTerm);
				context.bytes.writeSB(nBits, record.alphaAddTerm);
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