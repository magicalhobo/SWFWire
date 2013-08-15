package com.swfwire.decompiler
{
	import com.swfwire.decompiler.SWF2Reader;
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.EndTag;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf2.records.FillStyleArrayRecord2;
	import com.swfwire.decompiler.data.swf3.actions.ButtonCondAction;
	import com.swfwire.decompiler.data.swf3.records.*;
	import com.swfwire.decompiler.data.swf3.tags.*;
	
	import flash.utils.ByteArray;
	
	public class SWF3Reader extends SWF2Reader
	{
		private static var FILE_VERSION:uint = 3;
		
		public function SWF3Reader()
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
					case 28: tag = readRemoveObject2Tag(context, header);
					case 33: tag = readDefineText2Tag(context, header);
					case 45: tag = readSoundStreamHead2Tag(context, header);
					case 46: tag = readDefineMorphShapeTag(context, header);
					case 48: tag = readDefineFont2Tag(context, header);
					*/
					case 12: 
						tag = readDoActionTag(context, header);
						break;
					case 26:
						tag = readPlaceObject2Tag(context, header);
						break;
					case 32:
						tag = readDefineShape3Tag(context, header);
						break;
					case 34:
						tag = readDefineButton2Tag(context, header);
						break;
					case 35:
						tag = readDefineBitsJPEG3Tag(context, header);
						break;
					case 36: 
						tag = readDefineBitsLossless2Tag(context, header);
						break;
					case 39:
						tag = readDefineSpriteTag(context, header);
						break;
					case 43:
						tag = readFrameLabelTag(context, header);
						break;
					default:
						tag = super.readTag(context, header);
						break;
				}
			}
			return tag;
		}
		
		protected function readDoActionTag(context:SWFReaderContext, header:TagHeaderRecord):DoActionTag
		{
			var tag:DoActionTag = new DoActionTag();
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
		
		protected function readPlaceObject2Tag(context:SWFReaderContext, header:TagHeaderRecord):PlaceObject2Tag
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
		
		protected function readDefineShape3Tag(context:SWFReaderContext, header:TagHeaderRecord):DefineShape3Tag
		{
			var tag:DefineShape3Tag = new DefineShape3Tag();
			tag.shapeId = context.bytes.readUI16();
			tag.shapeBounds = readRectangleRecord(context);
			tag.shapes = readShapeWithStyleRecord3(context);
			return tag;
		}
		
		protected function readDefineBitsJPEG3Tag(context:SWFReaderContext, header:TagHeaderRecord):DefineBitsJPEG3Tag
		{
			var tag:DefineBitsJPEG3Tag = new DefineBitsJPEG3Tag();
			var startPosition:uint = context.bytes.getBytePosition();
			tag.characterID = context.bytes.readUI16();
			tag.alphaDataOffset = context.bytes.readUI32();
			tag.imageData = new ByteArray();
			if(tag.alphaDataOffset > 0)
			{
				context.bytes.readBytes(tag.imageData, 0, tag.alphaDataOffset);
			}
			tag.bitmapAlphaData = new ByteArray();
			var bytesRemaining:uint = header.length - (context.bytes.getBytePosition() - startPosition);
			if(bytesRemaining > 0)
			{
				context.bytes.readBytes(tag.bitmapAlphaData, 0, bytesRemaining);
			}
			return tag;
		}
		
		protected function readDefineBitsLossless2Tag(context:SWFReaderContext, header:TagHeaderRecord):DefineBitsLossless2Tag
		{
			var tag:DefineBitsLossless2Tag = new DefineBitsLossless2Tag();
			var startPosition:uint = context.bytes.getBytePosition();
			tag.characterId = context.bytes.readUI16();
			tag.bitmapFormat = context.bytes.readUI8();
			tag.bitmapWidth = context.bytes.readUI16();
			tag.bitmapHeight = context.bytes.readUI16();
			
			const COLOR_MAPPED_IMAGE:uint = 3;
			const ARGB_IMAGE:uint = 5;
			
			if(tag.bitmapFormat == COLOR_MAPPED_IMAGE)
			{
				tag.bitmapColorTableSize = context.bytes.readUI8();
			}
			
			if(tag.bitmapFormat == COLOR_MAPPED_IMAGE || tag.bitmapFormat == 4 || tag.bitmapFormat == ARGB_IMAGE)
			{
				var unzippedData:ByteArray = new ByteArray();
				
				var bytesRead:uint = context.bytes.getBytePosition() - startPosition;
				var remainingBytes:uint = header.length - bytesRead;
				
				if(remainingBytes > 0)
				{
					context.bytes.readBytes(unzippedData, 0, remainingBytes);
				}
				
				unzippedData.uncompress();
				
				var unzippedDataContext:SWFReaderContext = new SWFReaderContext(new SWFByteArray(unzippedData), context.fileVersion, context.result);
				
				if(tag.bitmapFormat == COLOR_MAPPED_IMAGE)
				{
					var paddedWidth:uint = Math.ceil(tag.bitmapWidth / 4) * 4;
					var imageDataSize:uint = paddedWidth * tag.bitmapHeight;
					tag.zlibBitmapData = readAlphaColorMapDataRecord(unzippedDataContext, tag.bitmapColorTableSize + 1, imageDataSize);
				}
				else if(tag.bitmapFormat == 4 || tag.bitmapFormat == ARGB_IMAGE)
				{
					var imageDataSize2:uint = tag.bitmapWidth * tag.bitmapHeight;
					tag.zlibBitmapData = readAlphaBitmapDataRecord(unzippedDataContext, imageDataSize2);
				}
			}
			return tag;
		}
		
		protected function readAlphaColorMapDataRecord(context:SWFReaderContext, colorTableSize:uint, imageDataSize:uint):AlphaColorMapDataRecord
		{
			var record:AlphaColorMapDataRecord = new AlphaColorMapDataRecord();
			record.colorTableRGB = new Vector.<RGBARecord>(colorTableSize);
			for(var iter:uint = 0; iter < colorTableSize; iter++)
			{
				record.colorTableRGB[iter] = readRGBARecord(context);
			}
			record.colormapPixelData = new Vector.<uint>(imageDataSize);
			for(iter = 0; iter < imageDataSize; iter++)
			{
				record.colormapPixelData[iter] = context.bytes.readUI8();
			}
			return record;
		}
		
		protected function readARGBRecord(context:SWFReaderContext):ARGBRecord
		{			
			var record:ARGBRecord = new ARGBRecord();
			record.alpha = context.bytes.readUI8();
			record.red = context.bytes.readUI8();
			record.green = context.bytes.readUI8();
			record.blue = context.bytes.readUI8();
			return record;
		}
		
		protected function readAlphaBitmapDataRecord(context:SWFReaderContext, imageDataSize:uint):AlphaBitmapDataRecord
		{
			var record:AlphaBitmapDataRecord = new AlphaBitmapDataRecord();
			record.bitmapPixelData = new Vector.<ARGBRecord>(imageDataSize);
			for(var iter:uint = 0; iter < imageDataSize; iter++)
			{
				record.bitmapPixelData[iter] = readARGBRecord(context);
			}
			return record;
		}
		
		protected function readShapeWithStyleRecord3(context:SWFReaderContext):ShapeWithStyleRecord3
		{
			var record:ShapeWithStyleRecord3 = new ShapeWithStyleRecord3();
			
			record.fillStyles = readFillStyleArrayRecord3(context);
			record.lineStyles = readLineStyleArrayRecord2(context);
			var numFillBits:uint = context.bytes.readUB(4);
			var numLineBits:uint = context.bytes.readUB(4);
			record.numFillBits = numFillBits;
			record.numLineBits = numLineBits;
			record.shapeRecords = new Vector.<IShapeRecord>();
			
			while(true)
			{
				var shapeRecord:IShapeRecord = readShapeRecord3(context, numFillBits, numLineBits);
				record.shapeRecords.push(shapeRecord);
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
			
			return record;
		}
		
		protected function readShapeRecord3(context:SWFReaderContext, numFillBits:uint, numLineBits:uint):IShapeRecord
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
					record = readStyleChangeRecord3(context,
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
		
		protected function readDefineButton2Tag(context:SWFReaderContext, header:TagHeaderRecord):DefineButton2Tag
		{
			var tag:DefineButton2Tag = new DefineButton2Tag();
			tag.buttonId = context.bytes.readUI16();
			tag.reserved = context.bytes.readUB(7);
			tag.trackAsMenu = context.bytes.readFlag();
			var actionOffsetPosition:uint = context.bytes.getBytePosition();
			tag.actionOffset = context.bytes.readUI16();
			tag.characters = new Vector.<ButtonRecord2>();
			do
			{
				tag.characters.push(readButtonRecord2(context));
				// Test if next byte is CharacterEndFlag
				if (!context.bytes.readUI8())
				{
					break;
				}
				context.bytes.unreadBytes(1);
			}
			while(true);
			tag.actions = new Vector.<ButtonCondAction>();
			if (tag.actionOffset == 0)
			{
				return tag;
			}
			if ((actionOffsetPosition + tag.actionOffset) != context.bytes.getBytePosition())
			{
				throw new Error("Wrong ActionOffset value: " + tag.actionOffset + " instead of " + (context.bytes.getBytePosition() - actionOffsetPosition));
			}
			do
			{
				var actionPosition:uint = context.bytes.getBytePosition();
				var action:ButtonCondAction = readButtonCondAction(context);
				tag.actions.push(action);
				if (action.condActionSize && ((actionPosition + action.condActionSize) != context.bytes.getBytePosition()))
				{
					throw new Error("Wrong CondActionSize value: " + action.condActionSize + " instead of " + (context.bytes.getBytePosition() - actionPosition));
				}
			}
			while(action.condActionSize)
			return tag;
		}
		
		protected function readButtonRecord2(context:SWFReaderContext):ButtonRecord2
		{
			var record:ButtonRecord2 = new ButtonRecord2(readButtonRecord(context));
			record.colorTransform = readCXFormWithAlphaRecord(context);
			record.filterList = readFilterListRecord(context);
			record.blendMode = context.bytes.readUI8();
			return record;
		}
		
		protected function readFilterListRecord(context:SWFReaderContext):FilterListRecord
		{
			var record:FilterListRecord = new FilterListRecord();
			record.numberOfFilters = context.bytes.readUI8();
			record.filters = new Vector.<FilterRecord>(record.numberOfFilters);
			for(var iter:uint = 0; iter < record.numberOfFilters; iter++)
			{
				record.filters[iter] = readFilterRecord(context);
			}
			return record;
		}
		
		protected function readFilterRecord(context:SWFReaderContext):FilterRecord
		{
			var record:FilterRecord = new FilterRecord();
			record.filterId = context.bytes.readUI8();
			switch(record.filterId)
			{
				case 0:
					record.dropShadowFilter = readDropShadowFilterRecord(context);
					break;
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
		
		protected function readRGBARecord(context:SWFReaderContext):RGBARecord
		{
			var record:RGBARecord = new RGBARecord();
			record.red = context.bytes.readUI8();
			record.green = context.bytes.readUI8();
			record.blue = context.bytes.readUI8();
			record.alpha = context.bytes.readUI8();
			return record;
		}
		
		protected function readButtonCondAction(context:SWFReaderContext):ButtonCondAction
		{
			var action:ButtonCondAction = new ButtonCondAction();
			action.condActionSize =  context.bytes.readUI16();
			var size:uint = action.condActionSize - 2;
			if (size > 0)
			{
				action.condIdleToOverDown = context.bytes.readFlag();
				action.condOutDownToldle = context.bytes.readFlag();
				action.condOutDownToOverDown = context.bytes.readFlag();
				action.condOverDownToOutDown = context.bytes.readFlag();
				action.condOverDownToOverUp = context.bytes.readFlag();
				action.condOverUpToOverDown = context.bytes.readFlag();
				action.condOverUpToIdle = context.bytes.readFlag();
				action.condIdleToOverUp = context.bytes.readFlag();
				size--;
			}
			if (size > 0)
			{
				action.condKeyPress = context.bytes.readUB(7);
				action.condOverDownToIdle = context.bytes.readFlag();
				size--;
			}
			while(size > 0)
			{
				var startPosition:uint = context.bytes.getBytePosition();
				if (!context.bytes.readUI8())
				{
					size--;
					break;
				}
				context.bytes.unreadBytes(1);
				action.actions.push(readActionRecord(context));
				size -= (context.bytes.getBytePosition() - startPosition);
			}
			return action;
		}
		
		protected function readDefineSpriteTag(context:SWFReaderContext, header:TagHeaderRecord):DefineSpriteTag
		{
			var tag:DefineSpriteTag = new DefineSpriteTag();
			tag.spriteId = context.bytes.readUI16();
			tag.frameCount = context.bytes.readUI16();
			tag.controlTags = readControlTags(context);
			return tag;
		}
		
		protected function readControlTags(context:SWFReaderContext):Vector.<SWFTag>
		{
			var tags:Vector.<SWFTag> = new Vector.<SWFTag>();
			while(true)
			{
				var header:TagHeaderRecord = readTagHeaderRecord(context);
				var tag:SWFTag = readTag(context, header);
				tag.header = header;
				tags.push(tag);
				if(tag is EndTag)
				{
					break;
				}
			}
			return tags;
		}
		
		protected function readFrameLabelTag(context:SWFReaderContext, header:TagHeaderRecord):FrameLabelTag
		{
			var tag:FrameLabelTag = new FrameLabelTag();
			tag.name = context.bytes.readString();
			return tag;
		}
		
		protected function readCXFormWithAlphaRecord(context:SWFReaderContext):CXFormWithAlphaRecord
		{
			context.bytes.alignBytes();
			
			var record:CXFormWithAlphaRecord = new CXFormWithAlphaRecord();
			
			record.hasAddTerms = context.bytes.readFlag();
			record.hasMultTerms = context.bytes.readFlag();
			record.nBits = context.bytes.readUB(4);
			
			if(record.hasMultTerms)
			{
				record.redMultTerm = context.bytes.readSB(record.nBits);
				record.greenMultTerm = context.bytes.readSB(record.nBits);
				record.blueMultTerm = context.bytes.readSB(record.nBits);
				record.alphaMultTerm = context.bytes.readSB(record.nBits);
			}
			
			if(record.hasAddTerms)
			{
				record.redAddTerm = context.bytes.readSB(record.nBits);
				record.greenAddTerm = context.bytes.readSB(record.nBits);
				record.blueAddTerm = context.bytes.readSB(record.nBits);
				record.alphaAddTerm = context.bytes.readSB(record.nBits);
			}
			
			return record;
		}
		
		protected function readClipActionsRecord(context:SWFReaderContext):ClipActionsRecord
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
		
		protected function readActionRecord(context:SWFReaderContext):ActionRecord
		{
			var record:ActionRecord = new ActionRecord();
			record.actionCode = context.bytes.readUI8();
			if(record.actionCode >= 0x80)
			{
				record.length = context.bytes.readUI16();
			}
			if(record.length > 0)
			{
				record.action = new ByteArray();
				if(record.length > 0)
				{
					context.bytes.readBytes(record.action, 0, record.length);
				}
			}
			return record;
		}
		
		protected function readGradientRecord2(context:SWFReaderContext):GradientRecord2
		{
			context.bytes.alignBytes();
			var record:GradientRecord2 = new GradientRecord2();
			record.spreadMode = context.bytes.readUB(2);
			record.interpolationMode = context.bytes.readUB(2);
			record.numGradients = context.bytes.readUB(4);
			record.gradientRecords = new Vector.<GradientControlPointRecord2>(record.numGradients);
			for(var iter:uint = 0; iter < record.numGradients; iter++)
			{
				record.gradientRecords[iter] = readGradientControlPointRecord2(context);
			}
			return record;
		}
		
		protected function readGradientControlPointRecord2(context:SWFReaderContext):GradientControlPointRecord2
		{
			var record:GradientControlPointRecord2 = new GradientControlPointRecord2();
			record.ratio = context.bytes.readUI8();
			record.color = readRGBARecord(context);
			return record;
		}
		
		protected function readFillStyleRecord2(context:SWFReaderContext):FillStyleRecord2
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
			if(type == 0x40 || type == 0x41 || type == 0x42 || type == 0x43)
			{
				record.bitmapId = context.bytes.readUI16();
				record.bitmapMatrix = readMatrixRecord(context);
			}
			
			return record;
		}
		
		protected function readFillStyleArrayRecord3(context:SWFReaderContext):FillStyleArrayRecord3
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
				record.fillStyles[iter] = readFillStyleRecord2(context);
			}
			
			return record;
		}
		
		protected function readLineStyleRecord2(context:SWFReaderContext):LineStyleRecord2
		{
			var record:LineStyleRecord2 = new LineStyleRecord2();
			record.width = context.bytes.readUI16();
			record.color = readRGBARecord(context);
			return record;
		}
		
		protected function readLineStyleArrayRecord2(context:SWFReaderContext):LineStyleArrayRecord2
		{
			var record:LineStyleArrayRecord2 = new LineStyleArrayRecord2();
			
			record.count = context.bytes.readUI8();
			if(record.count == 0xFF)
			{
				record.countExtended = context.bytes.readUI16();
			}
			record.lineStyles = new Vector.<LineStyleRecord2>(record.count);
			for(var iter:uint = 0; iter < record.count; iter++)
			{
				record.lineStyles[iter] = readLineStyleRecord2(context);
			}
			
			return record;
		}
		
		protected function readStyleChangeRecord3(context:SWFReaderContext, stateNewStyles:Boolean,
			stateLineStyle:Boolean, stateFillStyle1:Boolean,
			stateFillStyle0:Boolean, stateMoveTo:Boolean, 
			numFillBits:uint, numLineBits:uint):StyleChangeRecord3
		{
			var record:StyleChangeRecord3 = new StyleChangeRecord3();
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
				record.fillStyles = readFillStyleArrayRecord3(context);
				record.lineStyles = readLineStyleArrayRecord2(context);
				record.numFillBits = context.bytes.readUB(4);
				record.numLineBits = context.bytes.readUB(4);
			}
			return record;
		}
	}
}