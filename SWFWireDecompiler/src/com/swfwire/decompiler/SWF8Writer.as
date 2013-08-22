package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.BevelFilterRecord;
	import com.swfwire.decompiler.data.swf.records.BlurFilterRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.records.ColorMatrixFilterRecord;
	import com.swfwire.decompiler.data.swf.records.ConvolutionFilterRecord;
	import com.swfwire.decompiler.data.swf.records.CurvedEdgeRecord;
	import com.swfwire.decompiler.data.swf.records.DropShadowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.EndShapeRecord;
	import com.swfwire.decompiler.data.swf.records.FilterListRecord;
	import com.swfwire.decompiler.data.swf.records.GlowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.GradientBevelFilterRecord;
	import com.swfwire.decompiler.data.swf.records.GradientGlowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.IFilterRecord;
	import com.swfwire.decompiler.data.swf.records.IShapeRecord;
	import com.swfwire.decompiler.data.swf.records.StraightEdgeRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.ButtonRecord2;
	import com.swfwire.decompiler.data.swf3.records.FillStyleArrayRecord3;
	import com.swfwire.decompiler.data.swf3.records.FillStyleRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientRecord2;
	import com.swfwire.decompiler.data.swf8.records.FocalGradientRecord;
	import com.swfwire.decompiler.data.swf8.records.FontShapeRecord;
	import com.swfwire.decompiler.data.swf8.records.KerningRecord;
	import com.swfwire.decompiler.data.swf8.records.LineStyle2ArrayRecord;
	import com.swfwire.decompiler.data.swf8.records.LineStyle2Record;
	import com.swfwire.decompiler.data.swf8.records.ShapeWithStyleRecord4;
	import com.swfwire.decompiler.data.swf8.records.StyleChangeRecord4;
	import com.swfwire.decompiler.data.swf8.records.ZoneDataRecord;
	import com.swfwire.decompiler.data.swf8.records.ZoneRecord;
	import com.swfwire.decompiler.data.swf8.tags.CSMTextSettingsTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineBitsJPEG2Tag2;
	import com.swfwire.decompiler.data.swf8.tags.DefineFont3Tag;
	import com.swfwire.decompiler.data.swf8.tags.DefineFontAlignZonesTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineMorphShape2Tag;
	import com.swfwire.decompiler.data.swf8.tags.DefineScalingGridTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineShape4Tag;
	import com.swfwire.decompiler.data.swf8.tags.DefineVideoStreamTag;
	import com.swfwire.decompiler.data.swf8.tags.FileAttributesTag;
	import com.swfwire.decompiler.data.swf8.tags.ImportAssets2Tag;
	import com.swfwire.decompiler.data.swf8.tags.PlaceObject3Tag;

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
				case PlaceObject3Tag:
					writePlaceObject3Tag(context, PlaceObject3Tag(tag));
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
		
		protected function writePlaceObject3Tag(context:SWFWriterContext, tag:PlaceObject3Tag):void
		{
			var hasClipActions:Boolean = tag.clipActions != null;
			var hasClipDepth:Boolean = tag.clipDepth > 0;
			var hasName:Boolean = tag.name != null;
			var hasRatio:Boolean = tag.ratio > 0;
			var hasColorTransform:Boolean = tag.colorTransform != null;
			var hasMatrix:Boolean = tag.matrix != null;
			var hasCharacter:Boolean = tag.characterId > 0;
			
			context.bytes.writeFlag(hasClipActions);
			context.bytes.writeFlag(hasClipDepth);
			context.bytes.writeFlag(hasName);
			context.bytes.writeFlag(hasRatio);
			context.bytes.writeFlag(hasColorTransform);
			context.bytes.writeFlag(hasMatrix);
			context.bytes.writeFlag(hasCharacter);
			
			context.bytes.writeFlag(tag.move);
			context.bytes.writeUB(3, tag.reserved);
			
			var hasImage:Boolean = hasCharacter || hasClassName;
			var hasClassName:Boolean = tag.className != null;
			var hasCacheAsBitmap:Boolean = tag.bitmapCache > 0;
			var hasBlendMode:Boolean = tag.blendMode > 0;
			var hasFilterList:Boolean = tag.surfaceFilterList != null;
			
			context.bytes.writeFlag(hasImage);
			context.bytes.writeFlag(hasClassName);
			context.bytes.writeFlag(hasCacheAsBitmap);
			context.bytes.writeFlag(hasBlendMode);
			context.bytes.writeFlag(hasFilterList);
			
			context.bytes.writeUI16(tag.depth);
			
			if(hasClassName)
			{
				context.bytes.writeString(tag.className);
			}
			
			if(hasCharacter)
			{
				context.bytes.writeUI16(tag.characterId);
			}
			
			if(hasMatrix)
			{
				writeMatrixRecord(context, tag.matrix);
			}
			
			if(hasColorTransform)
			{
				writeCXFormWithAlphaRecord(context, tag.colorTransform);
			}
			
			if(hasRatio)
			{
				context.bytes.writeUI16(tag.ratio);
			}
			
			if(hasName)
			{
				context.bytes.writeString(tag.name);
			}
			
			if(hasClipDepth)
			{
				context.bytes.writeUI16(tag.clipDepth);
			}
			
			if(hasFilterList)
			{
				writeFilterListRecord(context, tag.surfaceFilterList);
			}
			
			if(hasBlendMode)
			{
				context.bytes.writeUI8(tag.blendMode);
			}
			
			if(hasCacheAsBitmap)
			{
				context.bytes.writeUI8(tag.bitmapCache);
			}
			
			if(hasClipActions)
			{
				writeClipActionsRecord(context, tag.clipActions);
			}
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
		
		protected function writeFilterListRecord(context:SWFWriterContext, record:FilterListRecord):void
		{
			var filterCount:uint = record.filters.length;
			context.bytes.writeUI8(filterCount);
			for(var iter:uint = 0; iter < filterCount; iter++)
			{
				writeFilterRecord(context, record.filters[iter]);
			}
		}
		
		protected function writeDropShadowFilterRecord(context:SWFWriterContext, record:DropShadowFilterRecord):void
		{
			writeRGBARecord(context, record.color);
			context.bytes.writeFixed16_16(record.blurX);
			context.bytes.writeFixed16_16(record.blurY);
			context.bytes.writeFixed16_16(record.angle);
			context.bytes.writeFixed16_16(record.distance);
			context.bytes.writeFixed8_8(record.strength);
			context.bytes.writeFlag(record.innerShadow);
			context.bytes.writeFlag(record.knockout);
			context.bytes.writeFlag(record.compositeSource);
			context.bytes.writeUB(5, record.passes);
		}
		
		protected function writeBlurFilterRecord(context:SWFWriterContext, record:BlurFilterRecord):void
		{
			context.bytes.writeFixed16_16(record.blurX);
			context.bytes.writeFixed16_16(record.blurY);
			context.bytes.writeUB(5, record.passes);
			context.bytes.writeUB(3, record.reserved);
		}
		
		protected function writeGlowFilterRecord(context:SWFWriterContext, record:GlowFilterRecord):void
		{
			writeRGBARecord(context, record.color);
			context.bytes.writeFixed16_16(record.blurX);
			context.bytes.writeFixed16_16(record.blurY);
			context.bytes.writeFixed8_8(record.strength);
			context.bytes.writeFlag(record.innerGlow);
			context.bytes.writeFlag(record.knockout);
			context.bytes.writeFlag(record.compositeSource);
			context.bytes.writeUB(5, record.passes);
		}
		
		protected function writeBevelFilterRecord(context:SWFWriterContext, record:BevelFilterRecord):void
		{
			writeRGBARecord(context, record.shadowColor);
			writeRGBARecord(context, record.highlightColor);
			context.bytes.writeFixed16_16(record.blurX);
			context.bytes.writeFixed16_16(record.blurY);
			context.bytes.writeFixed16_16(record.angle);
			context.bytes.writeFixed16_16(record.distance);
			context.bytes.writeFixed8_8(record.strength);
			context.bytes.writeFlag(record.innerShadow);
			context.bytes.writeFlag(record.knockout);
			context.bytes.writeFlag(record.compositeSource);
			context.bytes.writeFlag(record.onTop);
			context.bytes.writeUB(4, record.passes);
		}
		
		protected function writeGradientGlowFilterRecord(context:SWFWriterContext, record:GradientGlowFilterRecord):void
		{
			var numColors:uint = record.gradientColors.length;
			context.bytes.writeUI8(numColors);
			for(var iter:uint = 0; iter < numColors; iter++)
			{
				writeRGBARecord(context, record.gradientColors[iter]);
			}
			for(iter = 0; iter < numColors; iter++)
			{
				context.bytes.writeUI8(record.gradientRatios[iter]);
			}
			context.bytes.writeFixed16_16(record.blurX);
			context.bytes.writeFixed16_16(record.blurY);
			context.bytes.writeFixed16_16(record.angle);
			context.bytes.writeFixed16_16(record.distance);
			context.bytes.writeFixed8_8(record.strength);
			context.bytes.writeFlag(record.innerShadow);
			context.bytes.writeFlag(record.knockout);
			context.bytes.writeFlag(record.compositeSource);
			context.bytes.writeFlag(record.onTop);
			context.bytes.writeUB(4, record.passes);
		}
		
		protected function writeConvolutionFilterRecord(context:SWFWriterContext, record:ConvolutionFilterRecord):void
		{
			context.bytes.writeUI8(record.matrixX);
			context.bytes.writeUI8(record.matrixY);
			context.bytes.writeFloat(record.divisor);
			context.bytes.writeFloat(record.bias);
			var matrixElements:uint = record.matrixX * record.matrixY;
			for(var iter:uint = 0; iter < matrixElements; iter++)
			{
				context.bytes.writeFloat(record.matrix[iter]);
			}
			writeRGBARecord(context, record.defaultColor);
			context.bytes.writeUB(6, record.reserved);
			context.bytes.writeFlag(record.clamp);
			context.bytes.writeFlag(record.preserveAlpha);
		}
		
		protected function writeColorMatrixFilterRecord(context:SWFWriterContext, record:ColorMatrixFilterRecord):void
		{
			for(var iter:uint = 0; iter < 20; iter++)
			{
				context.bytes.writeFloat(record.matrix[iter]);
			}
		}
		
		protected function writeGradientBevelFilterRecord(context:SWFWriterContext, record:GradientBevelFilterRecord):void
		{
			var numColors:uint = record.gradientColors.length;
			context.bytes.writeUI8(numColors);
			for(var iter:uint = 0; iter < numColors; iter++)
			{
				writeRGBARecord(context, record.gradientColors[iter]);
			}
			for(iter = 0; iter < numColors; iter++)
			{
				context.bytes.writeUI8(record.gradientRatios[iter]);
			}
			context.bytes.writeFixed16_16(record.blurX);
			context.bytes.writeFixed16_16(record.blurY);
			context.bytes.writeFixed16_16(record.angle);
			context.bytes.writeFixed16_16(record.distance);
			context.bytes.writeFixed8_8(record.strength);
			context.bytes.writeFlag(record.innerShadow);
			context.bytes.writeFlag(record.knockout);
			context.bytes.writeFlag(record.compositeSource);
			context.bytes.writeFlag(record.onTop);
			context.bytes.writeUB(4, record.passes);
		}

		protected function writeFilterRecord(context:SWFWriterContext, record:IFilterRecord):void
		{
			context.bytes.writeUI8(record.filterId);
			switch(record.filterId)
			{
				case 0:
					writeDropShadowFilterRecord(context, record as DropShadowFilterRecord);
					break;
				case 1:
					writeBlurFilterRecord(context, record as BlurFilterRecord);
					break;
				case 2:
					writeGlowFilterRecord(context, record as GlowFilterRecord);
					break;
				case 3:
					writeBevelFilterRecord(context, record as BevelFilterRecord);
					break;
				case 4:
					writeGradientGlowFilterRecord(context, record as GradientGlowFilterRecord);
					break;
				case 5:
					writeConvolutionFilterRecord(context, record as ConvolutionFilterRecord);
					break;
				case 6:
					writeColorMatrixFilterRecord(context, record as ColorMatrixFilterRecord);
					break;
				case 7:
					writeGradientBevelFilterRecord(context, record as GradientBevelFilterRecord);
					break;
				default:
					throw new Error('Invalid filter id');
			}
		}
		
		override protected function writeButtonRecord2(context:SWFWriterContext, record:ButtonRecord2):void
		{
			var hasBlendMode:Boolean = record.blendMode != 0;
			var hasFilterList:Boolean = record.filterList != null;
			context.bytes.writeUB(2, record.reserved);
			context.bytes.writeFlag(hasBlendMode);
			context.bytes.writeFlag(hasFilterList);
			context.bytes.writeFlag(record.stateHitTest);
			context.bytes.writeFlag(record.stateDown);
			context.bytes.writeFlag(record.stateOver);
			context.bytes.writeFlag(record.stateUp);
			context.bytes.writeUI16(record.characterId);
			context.bytes.writeUI16(record.placeDepth);
			writeMatrixRecord(context, record.placeMatrix);
			writeCXFormWithAlphaRecord(context, record.colorTransform);
			if(hasFilterList)
			{
				writeFilterListRecord(context, record.filterList);
			}
			if(hasBlendMode)
			{
				context.bytes.writeUI8(record.blendMode);
			}
		}
	}
}