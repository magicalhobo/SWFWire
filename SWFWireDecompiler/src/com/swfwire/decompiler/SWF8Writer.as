package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.*;
	import com.swfwire.decompiler.data.swf8.records.*;
	import com.swfwire.decompiler.data.swf8.tags.*;

	public class SWF8Writer extends SWF7Writer
	{
		public static const TAG_IDS:Object = {
			21: DefineBitsJPEG2Tag2,
			60: DefineVideoStreamTag,
			69: FileAttributesTag,
			70: PlaceObject3Tag,
			71: ImportAssets2Tag,
			73: DefineFontAlignZonesTag,
			74: CSMTextSettingsTag,
			75: DefineFont3Tag,
			78: DefineScalingGridTag,
			83: DefineShape4Tag,
			84: DefineMorphShape2Tag
		};

		private static var FILE_VERSION:uint = 8;
		
		public function SWF8Writer()
		{
			version = FILE_VERSION;
			registerTags(TAG_IDS);
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case FileAttributesTag:
					writeFileAttributesTag(context, FileAttributesTag(tag));
					break;
				case DefineFontAlignZonesTag:
					writeDefineFontAlignZonesTag(context, DefineFontAlignZonesTag(tag));
					break;
				case DefineShape4Tag:
					writeDefineShape4Tag(context, DefineShape4Tag(tag));
					break;
				case CSMTextSettingsTag:
					writeCSMTextSettingsTag(context, CSMTextSettingsTag(tag));
					break;
				case DefineFont3Tag:
					writeDefineFont3Tag(context, DefineFont3Tag(tag));
					break;
				case DefineScalingGridTag:
					writeDefineScalingGridTag(context, DefineScalingGridTag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeFileAttributesTag(context:SWFWriterContext, tag:FileAttributesTag):void
		{
			context.bytes.writeUB(1, 0);
			context.bytes.writeFlag(tag.useDirectBlit);
			context.bytes.writeFlag(tag.useGPU);
			context.bytes.writeFlag(tag.hasMetadata);
			context.bytes.writeFlag(tag.actionScript3);
			context.bytes.writeUB(2, 0);
			context.bytes.writeFlag(tag.useNetwork);
			context.bytes.writeUB(24, 0);
		}
		
		protected function writeDefineShape4Tag(context:SWFWriterContext, tag:DefineShape4Tag):void
		{
			context.bytes.writeUI16(tag.shapeId);
			writeRectangleRecord(context, tag.shapeBounds);
			writeRectangleRecord(context, tag.edgeBounds);
			context.bytes.writeUB(5, tag.reserved);
			context.bytes.writeFlag(tag.usesFillWindingRule);
			context.bytes.writeFlag(tag.usesNonScalingStrokes);
			context.bytes.writeFlag(tag.usesScalingStrokes);
			writeShapeWithStyleRecord4(context, tag.shapes);
		}
		
		protected function writeDefineFontAlignZonesTag(context:SWFWriterContext, tag:DefineFontAlignZonesTag):void
		{
			context.bytes.writeUI16(tag.fontId);
			context.bytes.writeUB(2, tag.csmTableHint);
			context.bytes.writeUB(6, tag.reserved);

			var numGlyphs:uint = context.fontGlyphCounts[tag.fontId];
			
			for(var iter:uint = 0; iter < numGlyphs; iter++)
			{
				writeZoneRecord(context, tag.zoneTable[iter]);
			}
		}
		
		protected function writeZoneDataRecord(context:SWFWriterContext, record:ZoneDataRecord):void
		{
			context.bytes.writeFloat16(record.alignmentCoordinate);
			context.bytes.writeFloat16(record.range);
		}
		
		protected function writeZoneRecord(context:SWFWriterContext, record:ZoneRecord):void
		{
			context.bytes.writeUI8(record.numZoneData);
			for(var iter:uint = 0; iter < record.numZoneData; iter++)
			{
				writeZoneDataRecord(context, record.zoneData[iter]);
			}
			context.bytes.writeUB(6, record.reserved);
			context.bytes.writeUB(1, record.zoneMaskY);
			context.bytes.writeUB(1, record.zoneMaskX);
		}
		
		protected function writeCSMTextSettingsTag(context:SWFWriterContext, tag:CSMTextSettingsTag):void
		{
			context.bytes.writeUI16(tag.textId);
			context.bytes.writeUB(2, tag.useFlashType);
			context.bytes.writeUB(3, tag.gridFit);
			context.bytes.writeUB(3, tag.reserved);
			context.bytes.writeFloat(tag.thickness);
			context.bytes.writeFloat(tag.sharpness);
			context.bytes.writeUI8(tag.reserved2);
		}
		
		protected function writeDefineFont3Tag(context:SWFWriterContext, tag:DefineFont3Tag):void
		{
			var iter:uint;
			
			context.bytes.writeUI16(tag.fontId);
			context.bytes.writeFlag(tag.fontFlagsHasLayout);
			context.bytes.writeFlag(tag.fontFlagsShiftJIS);
			context.bytes.writeFlag(tag.fontFlagsSmallText);
			context.bytes.writeFlag(tag.fontFlagsANSI);
			context.bytes.writeFlag(tag.fontFlagsWideOffsets);
			context.bytes.writeFlag(tag.fontFlagsWideCodes);
			context.bytes.writeFlag(tag.fontFlagsItalic);
			context.bytes.writeFlag(tag.fontFlagsBold);
			writeLanguageCodeRecord(context, tag.languageCode);
			context.bytes.writeUI8(tag.fontNameLen);
			for(iter = 0; iter < tag.fontNameLen; iter++)
			{
				context.bytes.writeUI8(tag.fontName[iter]);
			}
			context.bytes.writeUI16(tag.numGlyphs);
			
			context.fontGlyphCounts[tag.fontId] = tag.numGlyphs;
			
			if(tag.fontFlagsWideOffsets)
			{
				for(iter = 0; iter < tag.numGlyphs; iter++)
				{
					context.bytes.writeUI32(tag.offsetTable[iter]);
				}
			}
			else
			{
				for(iter = 0; iter < tag.numGlyphs; iter++)
				{
					context.bytes.writeUI16(tag.offsetTable[iter]);
				}
			}
			if(tag.fontFlagsWideOffsets)
			{
				context.bytes.writeUI32(tag.codeTableOffset);
			}
			else
			{
				context.bytes.writeUI16(tag.codeTableOffset);
			}
			for(iter = 0; iter < tag.numGlyphs; iter++)
			{
				writeFontShapeRecord(context, tag.glyphShapeTable[iter]);
			}
			for(iter = 0; iter < tag.numGlyphs; iter++)
			{
				context.bytes.writeUI16(tag.codeTable[iter]);
			}
			if(tag.fontFlagsHasLayout)
			{
				context.bytes.writeSI16(tag.fontAscent);
				context.bytes.writeSI16(tag.fontDescent);
				context.bytes.writeSI16(tag.fontLeading);
				for(iter = 0; iter < tag.numGlyphs; iter++)
				{
					context.bytes.writeSI16(tag.fontAdvanceTable[iter]);
				}
				for(iter = 0; iter < tag.numGlyphs; iter++)
				{
					writeRectangleRecord(context, tag.fontBoundsTable[iter]);
				}
				context.bytes.writeUI16(tag.kerningCount);
				for(iter = 0; iter < tag.kerningCount; iter++)
				{
					writeKerningRecord(context, tag.fontFlagsWideCodes, tag.fontKerningTable[iter]);
				}
			}
		}
		
		protected function writeDefineScalingGridTag(context:SWFWriterContext, tag:DefineScalingGridTag):void
		{
			context.bytes.writeUI16(tag.characterId);
			writeRectangleRecord(context, tag.splitter);
		}
		
		protected function writeShapeWithStyleRecord4(context:SWFWriterContext, record:ShapeWithStyleRecord4):void
		{
			writeFillStyleArrayRecord4(context, record.fillStyles);
			writeLineStyle2ArrayRecord(context, record.lineStyles);
			
			context.bytes.alignBytes();
			
			var numFillBits:uint = record.numFillBits;
			var numLineBits:uint = record.numLineBits;
			
			context.bytes.writeUB(4, numFillBits);
			context.bytes.writeUB(4, numLineBits);

			for(var iter:uint = 0; iter < record.shapeRecords.length; iter++) 
			{
				var shapeRecord:IShapeRecord = record.shapeRecords[iter];
				writeShapeRecord4(context, numFillBits, numLineBits, shapeRecord);
				
				if(shapeRecord is StyleChangeRecord4)
				{
					if(StyleChangeRecord4(shapeRecord).stateNewStyles)
					{
						numFillBits = StyleChangeRecord4(shapeRecord).numFillBits;
						numLineBits = StyleChangeRecord4(shapeRecord).numLineBits;
					}
				}
				
				if(shapeRecord is EndShapeRecord)
				{
					break;
				}
			}
		}
		
		protected function writeFontShapeRecord(context:SWFWriterContext, record:FontShapeRecord):void
		{
			context.bytes.alignBytes();
			
			var numFillBits:uint = record.numFillBits;
			var numLineBits:uint = record.numLineBits;
			context.bytes.writeUB(4, numFillBits);
			context.bytes.writeUB(4, numLineBits);
			for(var iter:uint = 0; iter < record.shapeRecords.length; iter++)
			{
				var shapeRecord:IShapeRecord = record.shapeRecords[iter];
				writeShapeRecord4(context, numFillBits, numLineBits, shapeRecord);
				if(shapeRecord is StyleChangeRecord4)
				{
					if(StyleChangeRecord4(shapeRecord).stateNewStyles)
					{
						numFillBits = StyleChangeRecord4(shapeRecord).numFillBits;
						numLineBits = StyleChangeRecord4(shapeRecord).numLineBits;
					}
				}
				if(shapeRecord is EndShapeRecord)
				{
					break;
				}
			}
		}
		
		protected function writeKerningRecord(context:SWFWriterContext, fontFlagsWideCodes:Boolean, record:KerningRecord):void
		{
			if(fontFlagsWideCodes)
			{
				context.bytes.writeUI16(record.fontKerningCode1);
				context.bytes.writeUI16(record.fontKerningCode2);
			}
			else
			{
				context.bytes.writeUI8(record.fontKerningCode1);
				context.bytes.writeUI8(record.fontKerningCode2);
			}
			context.bytes.writeSI16(record.fontKerningAdjustment);
		}
		
		protected function writeFocalGradientRecord(context:SWFWriterContext, record:FocalGradientRecord):void
		{
			context.bytes.alignBytes();
			context.bytes.writeUB(2, record.spreadMode);
			context.bytes.writeUB(2, record.interpolationMode);
			context.bytes.writeUB(4, record.numGradients);
			for(var iter:uint = 0; iter < record.numGradients; iter++)
			{
				writeGradientControlPointRecord2(context, record.gradientRecords[iter]);
			}
			context.bytes.writeFixed8_8(record.focalPoint);
		}
		
		protected function writeFillStyleArrayRecord4(context:SWFWriterContext, record:FillStyleArrayRecord3):void
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
				writeFillStyleRecord3(context, record.fillStyles[iter]);
			}
		}
		
		protected function writeLineStyle2ArrayRecord(context:SWFWriterContext, record:LineStyle2ArrayRecord):void
		{
			context.bytes.writeUI8(record.count);
			if(record.count == 0xFF)
			{
				context.bytes.writeUI16(record.countExtended);
			}
			for(var iter:uint = 0; iter < record.count; iter++)
			{
				writeLineStyle2Record(context, record.lineStyles[iter]);
			}
		}
		
		protected function writeShapeRecord4(context:SWFWriterContext, numFillBits:uint, numLineBits:uint, record:IShapeRecord):void
		{
			if(record is StyleChangeRecord4)
			{
				context.bytes.writeFlag(false);
				var styleChangeRecord:StyleChangeRecord4 = StyleChangeRecord4(record);
				context.bytes.writeFlag(styleChangeRecord.stateNewStyles);
				context.bytes.writeFlag(styleChangeRecord.stateLineStyle);
				context.bytes.writeFlag(styleChangeRecord.stateFillStyle1);
				context.bytes.writeFlag(styleChangeRecord.stateFillStyle0);
				context.bytes.writeFlag(styleChangeRecord.stateMoveTo);
				writeStyleChangeRecord4(context,
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
		
		protected function writeFillStyleRecord3(context:SWFWriterContext, record:FillStyleRecord2):void
		{
			//TODO: calculate type
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
			if(type == 0x13)
			{
				writeMatrixRecord(context, record.gradientMatrix);
				writeFocalGradientRecord(context, FocalGradientRecord(record.gradient));
			}
			if(type == 0x40 || type == 0x41 || type == 0x42 || type == 0x43)
			{
				context.bytes.writeUI16(record.bitmapId);
				writeMatrixRecord(context, record.bitmapMatrix);
			}
		}
		
		protected function writeLineStyle2Record(context:SWFWriterContext, record:LineStyle2Record):void
		{
			context.bytes.writeUI16(record.width);
			
			context.bytes.writeUB(2, record.startCapStyle);
			context.bytes.writeUB(2, record.joinStyle);
			context.bytes.writeFlag(record.hasFillFlag);
			context.bytes.writeFlag(record.noHScaleFlag);
			context.bytes.writeFlag(record.noVScaleFlag);
			context.bytes.writeFlag(record.pixelHintingFlag);
			context.bytes.writeUB(5, record.reserved);
			context.bytes.writeFlag(record.noClose);
			context.bytes.writeUB(2, record.endCapStyle);
			if(record.joinStyle == 2)
			{
				context.bytes.writeFixed8_8(record.miterLimitFactor);
			}
			if(record.hasFillFlag)
			{
				writeFillStyleRecord3(context, record.fillType);
			}
			else
			{
				writeRGBARecord(context, record.color);
			}
		}
		
		protected function writeStyleChangeRecord4(context:SWFWriterContext, stateNewStyles:Boolean,
												   stateLineStyle:Boolean, stateFillStyle1:Boolean,
												   stateFillStyle0:Boolean, stateMoveTo:Boolean, 
												   numFillBits:uint, numLineBits:uint, record:StyleChangeRecord4):void
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
				writeFillStyleArrayRecord4(context, record.fillStyles);
				writeLineStyle2ArrayRecord(context, record.lineStyles);
				
				context.bytes.alignBytes();
				
				context.bytes.writeUB(4, record.numFillBits);
				context.bytes.writeUB(4, record.numLineBits);
			}
		}
	}
}