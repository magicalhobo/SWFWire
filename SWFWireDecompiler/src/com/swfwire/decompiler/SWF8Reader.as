package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.BevelFilterRecord;
	import com.swfwire.decompiler.data.swf.records.BlurFilterRecord;
	import com.swfwire.decompiler.data.swf.records.ColorMatrixFilterRecord;
	import com.swfwire.decompiler.data.swf.records.ConvolutionFilterRecord;
	import com.swfwire.decompiler.data.swf.records.DropShadowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.EndShapeRecord;
	import com.swfwire.decompiler.data.swf.records.FilterListRecord;
	import com.swfwire.decompiler.data.swf.records.GlowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.GradientBevelFilterRecord;
	import com.swfwire.decompiler.data.swf.records.GradientGlowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.IFilterRecord;
	import com.swfwire.decompiler.data.swf.records.IShapeRecord;
	import com.swfwire.decompiler.data.swf.records.RectangleRecord;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.ButtonRecord2;
	import com.swfwire.decompiler.data.swf3.records.FillStyleArrayRecord3;
	import com.swfwire.decompiler.data.swf3.records.FillStyleRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientControlPointRecord2;
	import com.swfwire.decompiler.data.swf3.tags.PlaceObject2Tag;
	import com.swfwire.decompiler.data.swf6.records.IVideoPacketRecord;
	import com.swfwire.decompiler.data.swf6.records.VP6SWFVideoPacketRecord;
	import com.swfwire.decompiler.data.swf8.records.FocalGradientRecord;
	import com.swfwire.decompiler.data.swf8.records.FontShapeRecord;
	import com.swfwire.decompiler.data.swf8.records.KerningRecord;
	import com.swfwire.decompiler.data.swf8.records.LineStyle2ArrayRecord;
	import com.swfwire.decompiler.data.swf8.records.LineStyle2Record;
	import com.swfwire.decompiler.data.swf8.records.ShapeWithStyleRecord4;
	import com.swfwire.decompiler.data.swf8.records.StyleChangeRecord4;
	import com.swfwire.decompiler.data.swf8.records.VP6SWFAlphaVideoPacketRecord;
	import com.swfwire.decompiler.data.swf8.records.ZoneDataRecord;
	import com.swfwire.decompiler.data.swf8.records.ZoneRecord;
	import com.swfwire.decompiler.data.swf8.tags.CSMTextSettingsTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineFont3Tag;
	import com.swfwire.decompiler.data.swf8.tags.DefineFontAlignZonesTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineScalingGridTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineShape4Tag;
	import com.swfwire.decompiler.data.swf8.tags.FileAttributesTag;
	import com.swfwire.decompiler.data.swf8.tags.PlaceObject3Tag;

	public class SWF8Reader extends SWF7Reader
	{
		private static var FILE_VERSION:uint = 8;
		
		public function SWF8Reader()
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
					case 71: tag = readImportAssets2Tag(context, header);
					case 84: tag = readDefineMorphShape2Tag(context, header);
					*/
					case 69:
						tag = readFileAttributesTag(context, header);
						break;
					case 70:
						tag = readPlaceObject3Tag(context, header);
						break;
					case 73: 
						tag = readDefineFontAlignZonesTag(context, header);
						break;
					case 74:
						tag = readCSMTextSettingsTag(context, header);
						break;
					case 75:
						tag = readDefineFont3Tag(context, header);
						break;
					case 78:
						tag = readDefineScalingGridTag(context, header);
						break;
					case 83:
						tag = readDefineShape4Tag(context, header);
						break;
					default:
						tag = super.readTag(context, header);
						break;
				}
			}
			return tag;
		}
		
		protected function readFileAttributesTag(context:SWFReaderContext, header:TagHeaderRecord):FileAttributesTag
		{
			var tag:FileAttributesTag = new FileAttributesTag();
			context.bytes.readUB(1);
			tag.useDirectBlit = context.bytes.readFlag();
			tag.useGPU = context.bytes.readFlag();
			tag.hasMetadata = context.bytes.readFlag();
			tag.actionScript3 = context.bytes.readFlag();
			context.bytes.readUB(2);
			tag.useNetwork = context.bytes.readFlag();
			context.bytes.readUB(24);
			return tag;
		}

		protected function readPlaceObject3Tag(context:SWFReaderContext, header:TagHeaderRecord):PlaceObject3Tag
		{
			var tag:PlaceObject3Tag = new PlaceObject3Tag();
			var hasClipActions:Boolean = context.bytes.readFlag();
			var hasClipDepth:Boolean = context.bytes.readFlag();
			var hasName:Boolean = context.bytes.readFlag();
			var hasRatio:Boolean = context.bytes.readFlag();
			var hasColorTransform:Boolean = context.bytes.readFlag();
			var hasMatrix:Boolean = context.bytes.readFlag();
			var hasCharacter:Boolean = context.bytes.readFlag();
			
			tag.move = context.bytes.readFlag();
			tag.reserved = context.bytes.readUB(3);
			
			var hasImage:Boolean = context.bytes.readFlag();
			var hasClassName:Boolean = context.bytes.readFlag();
			var hasCacheAsBitmap:Boolean = context.bytes.readFlag();
			var hasBlendMode:Boolean = context.bytes.readFlag();
			var hasFilterList:Boolean = context.bytes.readFlag();
			
			tag.depth = context.bytes.readUI16();
			
			if(hasClassName || (hasImage && hasCharacter))
			{
				tag.className = context.bytes.readString();
			}
			
			if(hasCharacter)
			{
				tag.characterId = context.bytes.readUI16();
			}
			
			if(hasMatrix)
			{
				tag.matrix = readMatrixRecord(context);
			}
			
			if(hasColorTransform)
			{
				tag.colorTransform = readCXFormWithAlphaRecord(context);
			}
			
			if(hasRatio)
			{
				tag.ratio = context.bytes.readUI16();
			}
			
			if(hasName)
			{
				tag.name = context.bytes.readString();
			}
			
			if(hasClipDepth)
			{
				tag.clipDepth = context.bytes.readUI16();
			}
			
			if(hasFilterList)
			{
				tag.surfaceFilterList = readFilterListRecord(context);
			}
			
			if(hasBlendMode)
			{
				tag.blendMode = context.bytes.readUI8();
			}
			
			if(hasCacheAsBitmap)
			{
				tag.bitmapCache = context.bytes.readUI8();
			}
			
			if(hasClipActions)
			{
				tag.clipActions = readClipActionsRecord(context);
			}
			return tag;
		}
		
		protected function readDefineFont3Tag(context:SWFReaderContext, header:TagHeaderRecord):DefineFont3Tag
		{
			var tag:DefineFont3Tag = new DefineFont3Tag();
			
			var iter:uint;
			
			tag.fontId = context.bytes.readUI16();
			tag.fontFlagsHasLayout = context.bytes.readFlag();
			tag.fontFlagsShiftJIS = context.bytes.readFlag();
			tag.fontFlagsSmallText = context.bytes.readFlag();
			tag.fontFlagsANSI = context.bytes.readFlag();
			tag.fontFlagsWideOffsets = context.bytes.readFlag();
			tag.fontFlagsWideCodes = context.bytes.readFlag();
			tag.fontFlagsItalic = context.bytes.readFlag();
			tag.fontFlagsBold = context.bytes.readFlag();
			tag.languageCode = readLanguageCodeRecord(context);
			tag.fontNameLen = context.bytes.readUI8();
			tag.fontName = new Vector.<uint>();
			for(iter = 0; iter < tag.fontNameLen; iter++)
			{
				tag.fontName[iter] = context.bytes.readUI8();
			}
			tag.numGlyphs = context.bytes.readUI16();
			
			context.fontGlyphCounts[tag.fontId] = tag.numGlyphs;
			
			tag.offsetTable = new Vector.<uint>();
			if(tag.fontFlagsWideOffsets)
			{
				for(iter = 0; iter < tag.numGlyphs; iter++)
				{
					tag.offsetTable[iter] = context.bytes.readUI32();
				}
			}
			else
			{
				for(iter = 0; iter < tag.numGlyphs; iter++)
				{
					tag.offsetTable[iter] = context.bytes.readUI16();
				}
			}
			if(tag.fontFlagsWideOffsets)
			{
				tag.codeTableOffset = context.bytes.readUI32();
			}
			else
			{
				tag.codeTableOffset = context.bytes.readUI16();
			}
			tag.glyphShapeTable = new Vector.<FontShapeRecord>();
			for(iter = 0; iter < tag.numGlyphs; iter++)
			{
				tag.glyphShapeTable[iter] = readFontShapeRecord(context);
			}
			tag.codeTable = new Vector.<uint>();
			for(iter = 0; iter < tag.numGlyphs; iter++)
			{
				tag.codeTable[iter] = context.bytes.readUI16();
			}
			if(tag.fontFlagsHasLayout)
			{
				tag.fontAscent = context.bytes.readSI16();
				tag.fontDescent = context.bytes.readSI16();
				tag.fontLeading = context.bytes.readSI16();
				tag.fontAdvanceTable = new Vector.<int>();
				for(iter = 0; iter < tag.numGlyphs; iter++)
				{
					tag.fontAdvanceTable[iter] = context.bytes.readSI16();
				}
				tag.fontBoundsTable = new Vector.<RectangleRecord>();
				for(iter = 0; iter < tag.numGlyphs; iter++)
				{
					tag.fontBoundsTable[iter] = readRectangleRecord(context);
				}
				tag.kerningCount = context.bytes.readUI16();
				tag.fontKerningTable = new Vector.<KerningRecord>();
				for(iter = 0; iter < tag.kerningCount; iter++)
				{
					tag.fontKerningTable[iter] = readKerningRecord(context, tag.fontFlagsWideCodes);
				}
			}
			
			return tag;
		}
		
		protected function readDefineScalingGridTag(context:SWFReaderContext, header:TagHeaderRecord):DefineScalingGridTag
		{
			var tag:DefineScalingGridTag = new DefineScalingGridTag();
			tag.characterId = context.bytes.readUI16();
			tag.splitter = readRectangleRecord(context);
			return tag;
		}
		
		protected function readDefineShape4Tag(context:SWFReaderContext, header:TagHeaderRecord):DefineShape4Tag
		{
			var tag:DefineShape4Tag = new DefineShape4Tag();
			tag.shapeId = context.bytes.readUI16();
			tag.shapeBounds = readRectangleRecord(context);
			tag.edgeBounds = readRectangleRecord(context);
			tag.reserved = context.bytes.readUB(5);
			tag.usesFillWindingRule = context.bytes.readFlag();
			tag.usesNonScalingStrokes = context.bytes.readFlag();
			tag.usesScalingStrokes = context.bytes.readFlag();
			tag.shapes = readShapeWithStyleRecord4(context);
			return tag;
		}
		
		protected function readDefineFontAlignZonesTag(context:SWFReaderContext, header:TagHeaderRecord):DefineFontAlignZonesTag
		{
			var tag:DefineFontAlignZonesTag = new DefineFontAlignZonesTag();
			tag.fontId = context.bytes.readUI16();
			tag.csmTableHint = context.bytes.readUB(2);
			tag.reserved = context.bytes.readUB(6);
			tag.zoneTable = new Vector.<ZoneRecord>();
			
			var numGlyphs:uint = context.fontGlyphCounts[tag.fontId];
			
			for(var iter:uint = 0; iter < numGlyphs; iter++)
			{
				tag.zoneTable[iter] = readZoneRecord(context);
			}
			return tag;
		}
		
		protected function readCSMTextSettingsTag(context:SWFReaderContext, header:TagHeaderRecord):CSMTextSettingsTag
		{
			var tag:CSMTextSettingsTag = new CSMTextSettingsTag();
			tag.textId = context.bytes.readUI16();
			tag.useFlashType = context.bytes.readUB(2);
			tag.gridFit = context.bytes.readUB(3);
			tag.reserved = context.bytes.readUB(3);
			tag.thickness = context.bytes.readFloat();
			tag.sharpness = context.bytes.readFloat();
			tag.reserved2 = context.bytes.readUI8();
			return tag;
		}
		
		protected function readZoneDataRecord(context:SWFReaderContext):ZoneDataRecord
		{
			var record:ZoneDataRecord = new ZoneDataRecord();
			record.alignmentCoordinate = context.bytes.readFloat16();
			record.range = context.bytes.readFloat16();
			return record;
		}
		
		protected function readZoneRecord(context:SWFReaderContext):ZoneRecord
		{
			var record:ZoneRecord = new ZoneRecord();
			record.numZoneData = context.bytes.readUI8();
			record.zoneData = new Vector.<ZoneDataRecord>();
			for(var iter:uint = 0; iter < record.numZoneData; iter++)
			{
				record.zoneData[iter] = readZoneDataRecord(context);
			}
			record.reserved = context.bytes.readUB(6);
			record.zoneMaskY = context.bytes.readUB(1);
			record.zoneMaskX = context.bytes.readUB(1);
			return record;
		}
		
		protected function readFontShapeRecord(context:SWFReaderContext):FontShapeRecord
		{
			context.bytes.alignBytes();
			
			var record:FontShapeRecord = new FontShapeRecord();
			var numFillBits:uint = context.bytes.readUB(4);
			var numLineBits:uint = context.bytes.readUB(4);
			record.numFillBits = numFillBits;
			record.numLineBits = numLineBits;
			record.shapeRecords = new Vector.<IShapeRecord>();
			while(true)
			{
				var shapeRecord:IShapeRecord = readShapeRecord4(context, numFillBits, numLineBits);
				record.shapeRecords.push(shapeRecord);
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
			return record;
		}
		
		protected function readKerningRecord(context:SWFReaderContext, fontFlagsWideCodes:Boolean):KerningRecord
		{
			var record:KerningRecord = new KerningRecord();
			if(fontFlagsWideCodes)
			{
				record.fontKerningCode1 = context.bytes.readUI16();
				record.fontKerningCode2 = context.bytes.readUI16();
			}
			else
			{
				record.fontKerningCode1 = context.bytes.readUI8();
				record.fontKerningCode2 = context.bytes.readUI8();
			}
			record.fontKerningAdjustment = context.bytes.readSI16();
			return record;
		}
		
		protected function readLineStyle2ArrayRecord(context:SWFReaderContext):LineStyle2ArrayRecord
		{
			var record:LineStyle2ArrayRecord = new LineStyle2ArrayRecord();
			
			record.count = context.bytes.readUI8();
			if(record.count == 0xFF)
			{
				record.countExtended = context.bytes.readUI16();
			}
			record.lineStyles = new Vector.<LineStyle2Record>(record.count);
			for(var iter:uint = 0; iter < record.count; iter++)
			{
				record.lineStyles[iter] = readLineStyle2Record(context);
			}
			
			return record;
		}
		
		protected function readShapeWithStyleRecord4(context:SWFReaderContext):ShapeWithStyleRecord4
		{
			var record:ShapeWithStyleRecord4 = new ShapeWithStyleRecord4();
			
			record.fillStyles = readFillStyleArrayRecord4(context);
			record.lineStyles = readLineStyle2ArrayRecord(context);
			
			context.bytes.alignBytes();
			
			var numFillBits:uint = context.bytes.readUB(4);
			var numLineBits:uint = context.bytes.readUB(4);
			record.numFillBits = numFillBits;
			record.numLineBits = numLineBits;
			record.shapeRecords = new Vector.<IShapeRecord>();
			
			while(true)
			{
				var shapeRecord:IShapeRecord = readShapeRecord4(context, numFillBits, numLineBits);
				record.shapeRecords.push(shapeRecord);
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
			
			return record;
		}
		
		protected function readFillStyleRecord3(context:SWFReaderContext):FillStyleRecord2
		{
			var record:FillStyleRecord2 = new FillStyleRecord2();
			
			var type:uint = context.bytes.readUI8();
			record.type = type;
			if(type == 0x00)
			{
				record.color = readRGBARecord(context);
			}
			if(type == 0x10 || type == 0x12)
			{
				record.gradientMatrix = readMatrixRecord(context);
				record.gradient = readGradientRecord2(context);
			}
			if(type == 0x13)
			{
				record.gradientMatrix = readMatrixRecord(context);
				record.gradient = readFocalGradientRecord(context);
			}
			if(type == 0x40 || type == 0x41 || type == 0x42 || type == 0x43)
			{
				record.bitmapId = context.bytes.readUI16();
				record.bitmapMatrix = readMatrixRecord(context);
			}
			
			return record;
		}
		
		protected function readFocalGradientRecord(context:SWFReaderContext):FocalGradientRecord
		{
			context.bytes.alignBytes();
			var record:FocalGradientRecord = new FocalGradientRecord();
			record.spreadMode = context.bytes.readUB(2);
			record.interpolationMode = context.bytes.readUB(2);
			record.numGradients = context.bytes.readUB(4);
			record.gradientRecords = new Vector.<GradientControlPointRecord2>(record.numGradients);
			for(var iter:uint = 0; iter < record.numGradients; iter++)
			{
				record.gradientRecords[iter] = readGradientControlPointRecord2(context);
			}
			record.focalPoint = context.bytes.readFixed8_8();
			return record;
		}
		
		protected function readFillStyleArrayRecord4(context:SWFReaderContext):FillStyleArrayRecord3
		{
			var record:FillStyleArrayRecord3 = new FillStyleArrayRecord3();
			
			var count:uint = context.bytes.readUI8();
			if(count == 0xFF)
			{
				count = context.bytes.readUI16();
			}
			record.fillStyles = new Vector.<FillStyleRecord2>(count);
			for(var iter:uint = 0; iter < count; iter++)
			{
				record.fillStyles[iter] = readFillStyleRecord3(context);
			}
			
			return record;
		}
		
		protected function readShapeRecord4(context:SWFReaderContext, numFillBits:uint, numLineBits:uint):IShapeRecord
		{
			var record:IShapeRecord;
			var typeFlag:Boolean = context.bytes.readFlag();
			if(!typeFlag)
			{
				var stateNewStyles:Boolean = context.bytes.readFlag();
				var stateLineStyle:Boolean = context.bytes.readFlag();
				var stateFillStyle1:Boolean = context.bytes.readFlag();
				var stateFillStyle0:Boolean = context.bytes.readFlag();
				var stateMoveTo:Boolean = context.bytes.readFlag();
				if(!stateNewStyles &&
					!stateLineStyle &&
					!stateFillStyle1 &&
					!stateFillStyle0 &&
					!stateMoveTo)
				{
					record = new EndShapeRecord();
				}
				else
				{
					record = readStyleChangeRecord4(context,
						stateNewStyles,
						stateLineStyle,
						stateFillStyle1, 
						stateFillStyle0, 
						stateMoveTo,
						numFillBits,
						numLineBits);
				}
			}
			else
			{
				var straightFlag:Boolean = context.bytes.readFlag();
				if(straightFlag)
				{
					record = readStraightEdgeRecord(context);
				}
				else
				{
					record = readCurvedEdgeRecord(context);
				}
			}
			return record;
		}
		
		protected function readStyleChangeRecord4(context:SWFReaderContext, stateNewStyles:Boolean,
			stateLineStyle:Boolean, stateFillStyle1:Boolean,
			stateFillStyle0:Boolean, stateMoveTo:Boolean, 
			numFillBits:uint, numLineBits:uint):StyleChangeRecord4
		{
			var record:StyleChangeRecord4 = new StyleChangeRecord4();
			record.stateNewStyles = stateNewStyles;
			record.stateLineStyle = stateLineStyle;
			record.stateFillStyle1 = stateFillStyle1;
			record.stateFillStyle0 = stateFillStyle0;
			record.stateMoveTo = stateMoveTo;
			
			if(stateMoveTo)
			{
				record.moveBits = context.bytes.readUB(5);
				record.moveDeltaX = context.bytes.readSB(record.moveBits);
				record.moveDeltaY = context.bytes.readSB(record.moveBits);
			}
			if(stateFillStyle0)
			{
				record.fillStyle0 = context.bytes.readUB(numFillBits);
			}
			if(stateFillStyle1)
			{
				record.fillStyle1 = context.bytes.readUB(numFillBits);
			}
			if(stateLineStyle)
			{
				record.lineStyle = context.bytes.readUB(numLineBits);
			}
			if(stateNewStyles)
			{
				record.fillStyles = readFillStyleArrayRecord4(context);
				record.lineStyles = readLineStyle2ArrayRecord(context);
				
				context.bytes.alignBytes();
				
				record.numFillBits = context.bytes.readUB(4);
				record.numLineBits = context.bytes.readUB(4);
			}
			return record;
		}

		protected function readLineStyle2Record(context:SWFReaderContext):LineStyle2Record
		{
			var record:LineStyle2Record = new LineStyle2Record();
			record.width = context.bytes.readUI16();
			
			record.startCapStyle = context.bytes.readUB(2);
			record.joinStyle = context.bytes.readUB(2);
			record.hasFillFlag = context.bytes.readFlag();
			record.noHScaleFlag = context.bytes.readFlag();
			record.noVScaleFlag = context.bytes.readFlag();
			record.pixelHintingFlag = context.bytes.readFlag();
			record.reserved = context.bytes.readUB(5);
			record.noClose = context.bytes.readFlag();
			record.endCapStyle = context.bytes.readUB(2);
			if(record.joinStyle == 2)
			{
				record.miterLimitFactor = context.bytes.readFixed8_8();
			}
			if(record.hasFillFlag)
			{
				record.fillType = readFillStyleRecord3(context);
			}
			else
			{
				record.color = readRGBARecord(context);
			}
			return record;
		}
		
		protected function readFilterListRecord(context:SWFReaderContext):FilterListRecord
		{
			var record:FilterListRecord = new FilterListRecord();
			var filterCount:uint = context.bytes.readUI8();
			record.filters = new Vector.<IFilterRecord>(filterCount);
			for(var iter:uint = 0; iter < filterCount; iter++)
			{
				record.filters[iter] = readFilterRecord(context);
			}
			return record;
		}
		
		protected function readDropShadowFilterRecord(context:SWFReaderContext):DropShadowFilterRecord
		{
			var record:DropShadowFilterRecord = new DropShadowFilterRecord();
			record.color = readRGBARecord(context);
			record.blurX = context.bytes.readFixed16_16();
			record.blurY = context.bytes.readFixed16_16();
			record.angle = context.bytes.readFixed16_16();
			record.distance = context.bytes.readFixed16_16();
			record.strength = context.bytes.readFixed8_8();
			record.innerShadow = context.bytes.readFlag();
			record.knockout = context.bytes.readFlag();
			record.compositeSource = context.bytes.readFlag();
			record.passes = context.bytes.readUB(5);
			return record;
		}
		
		protected function readBlurFilterRecord(context:SWFReaderContext):BlurFilterRecord
		{
			var record:BlurFilterRecord = new BlurFilterRecord();
			record.blurX = context.bytes.readFixed16_16();
			record.blurY = context.bytes.readFixed16_16();
			record.passes = context.bytes.readUB(5);
			record.reserved = context.bytes.readUB(3);
			return record;
		}
		
		protected function readGlowFilterRecord(context:SWFReaderContext):GlowFilterRecord
		{
			var record:GlowFilterRecord = new GlowFilterRecord();
			record.color = readRGBARecord(context);
			record.blurX = context.bytes.readFixed16_16();
			record.blurY = context.bytes.readFixed16_16();
			record.strength = context.bytes.readFixed8_8();
			record.innerGlow = context.bytes.readFlag();
			record.knockout = context.bytes.readFlag();
			record.compositeSource = context.bytes.readFlag();
			record.passes = context.bytes.readUB(5);
			return record;
		}
		
		protected function readBevelFilterRecord(context:SWFReaderContext):BevelFilterRecord
		{
			var record:BevelFilterRecord = new BevelFilterRecord();
			record.shadowColor = readRGBARecord(context);
			record.highlightColor = readRGBARecord(context);
			record.blurX = context.bytes.readFixed16_16();
			record.blurY = context.bytes.readFixed16_16();
			record.angle = context.bytes.readFixed16_16();
			record.distance = context.bytes.readFixed16_16();
			record.strength = context.bytes.readFixed8_8();
			record.innerShadow = context.bytes.readFlag();
			record.knockout = context.bytes.readFlag();
			record.compositeSource = context.bytes.readFlag();
			record.onTop = context.bytes.readFlag();
			record.passes = context.bytes.readUB(4);
			return record;
		}
		
		protected function readGradientGlowFilterRecord(context:SWFReaderContext):GradientGlowFilterRecord
		{
			var record:GradientGlowFilterRecord = new GradientGlowFilterRecord();
			var numColors:uint = context.bytes.readUI8();
			for(var iter:uint = 0; iter < numColors; iter++)
			{
				record.gradientColors.push(readRGBARecord(context));
			}
			for(iter = 0; iter < numColors; iter++)
			{
				record.gradientRatios.push(context.bytes.readUI8());
			}
			record.blurX = context.bytes.readFixed16_16();
			record.blurY = context.bytes.readFixed16_16();
			record.angle = context.bytes.readFixed16_16();
			record.distance = context.bytes.readFixed16_16();
			record.strength = context.bytes.readFixed8_8();
			record.innerShadow = context.bytes.readFlag();
			record.knockout = context.bytes.readFlag();
			record.compositeSource = context.bytes.readFlag();
			record.onTop = context.bytes.readFlag();
			record.passes = context.bytes.readUB(4);
			return record;
		}
		
		protected function readConvolutionFilterRecord(context:SWFReaderContext):ConvolutionFilterRecord
		{
			var record:ConvolutionFilterRecord = new ConvolutionFilterRecord();
			record.matrixX = context.bytes.readUI8();
			record.matrixY = context.bytes.readUI8();
			record.divisor = context.bytes.readFloat();
			record.bias = context.bytes.readFloat();
			var matrixElements:uint = record.matrixX * record.matrixY;
			for(var iter:uint = 0; iter < matrixElements; iter++)
			{
				record.matrix.push(context.bytes.readFloat());
			}
			record.defaultColor = readRGBARecord(context);
			record.reserved = context.bytes.readUB(6);
			record.clamp = context.bytes.readFlag();
			record.preserveAlpha = context.bytes.readFlag();
			return record;
		}

		protected function readColorMatrixFilterRecord(context:SWFReaderContext):ColorMatrixFilterRecord
		{
			var record:ColorMatrixFilterRecord = new ColorMatrixFilterRecord();
			for(var iter:uint = 0; iter < 20; iter++)
			{
				record.matrix.push(context.bytes.readFloat());
			}
			return record;
		}
		
		protected function readGradientBevelFilterRecord(context:SWFReaderContext):GradientBevelFilterRecord
		{
			var record:GradientBevelFilterRecord = new GradientBevelFilterRecord();
			var numColors:uint = context.bytes.readUI8();
			for(var iter:uint = 0; iter < numColors; iter++)
			{
				record.gradientColors.push(readRGBARecord(context));
			}
			for(iter = 0; iter < numColors; iter++)
			{
				record.gradientRatios.push(context.bytes.readUI8());
			}
			record.blurX = context.bytes.readFixed16_16();
			record.blurY = context.bytes.readFixed16_16();
			record.angle = context.bytes.readFixed16_16();
			record.distance = context.bytes.readFixed16_16();
			record.strength = context.bytes.readFixed8_8();
			record.innerShadow = context.bytes.readFlag();
			record.knockout = context.bytes.readFlag();
			record.compositeSource = context.bytes.readFlag();
			record.onTop = context.bytes.readFlag();
			record.passes = context.bytes.readUB(4);
			return record;
		}

		protected function readFilterRecord(context:SWFReaderContext):IFilterRecord
		{
			var record:IFilterRecord;
			var filterId:uint = context.bytes.readUI8();
			switch(filterId)
			{
				case 0:
					record = readDropShadowFilterRecord(context);
					break;
				case 1:
					record = readBlurFilterRecord(context);
					break;
				case 2:
					record = readGlowFilterRecord(context);
					break;
				case 3:
					record = readBevelFilterRecord(context);
					break;
				case 4:
					record = readGradientGlowFilterRecord(context);
					break;
				case 5:
					record = readConvolutionFilterRecord(context);
					break;
				case 6:
					record = readColorMatrixFilterRecord(context);
					break;
				case 7:
					record = readGradientBevelFilterRecord(context);
					break;
				default:
					throw new Error('Invalid filter id');
			}
			return record;
		}
		
		override protected function readButtonRecord2(context:SWFReaderContext):ButtonRecord2
		{
			var record:ButtonRecord2 = new ButtonRecord2();
			record.reserved = context.bytes.readUB(2);
			var hasBlendMode:Boolean = context.bytes.readFlag();
			var hasFilterList:Boolean = context.bytes.readFlag();
			record.stateHitTest = context.bytes.readFlag();
			record.stateDown = context.bytes.readFlag();
			record.stateOver = context.bytes.readFlag();
			record.stateUp = context.bytes.readFlag();
			record.characterId = context.bytes.readUI16();
			record.placeDepth = context.bytes.readUI16();
			record.placeMatrix = readMatrixRecord(context);
			record.colorTransform = readCXFormWithAlphaRecord(context);
			if(hasFilterList)
			{
				record.filterList = readFilterListRecord(context);
			}
			if(hasBlendMode)
			{
				record.blendMode = context.bytes.readUI8();
			}
			return record;
		}
		
		override protected function readVideoPacketRecord(codecId:uint, context:SWFReaderContext):IVideoPacketRecord
		{
			var record:IVideoPacketRecord;
			
			switch(codecId)
			{
				case 5:
					record = readVP6SWFAlphaVideoPacketRecord(context);
					break;
				/*
				case 6:
					record = readScreenV2VideoPacketRecord();
					break;
				*/
				default:
					record = super.readVideoPacketRecord(codecId, context);
					break;
			}
			
			return record;
		}
		
		protected function readVP6SWFAlphaVideoPacketRecord(context:SWFReaderContext):VP6SWFAlphaVideoPacketRecord
		{
			var record:VP6SWFAlphaVideoPacketRecord = new VP6SWFAlphaVideoPacketRecord();
			var offsetToAlpha:uint = context.bytes.readUI24();
			context.bytes.readBytes(record.data, 0, offsetToAlpha);
			var remaining:int = context.currentTagEnd - context.bytes.getBytePosition();
			context.bytes.readBytes(record.alphaData, 0, remaining);
			return record;
		}
	}
}