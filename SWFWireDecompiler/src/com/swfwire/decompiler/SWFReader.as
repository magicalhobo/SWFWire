package com.swfwire.decompiler
{
	import com.swfwire.decompiler.SWF10Reader;
	import com.swfwire.decompiler.SWF9Reader;
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.SWFHeader;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.records.FillStyleRecord;
	import com.swfwire.decompiler.data.swf.structures.MatrixRotateStructure;
	import com.swfwire.decompiler.data.swf.structures.MatrixScaleStructure;
	import com.swfwire.decompiler.data.swf.structures.MatrixTranslateStructure;
	import com.swfwire.decompiler.data.swf.tags.*;
	import com.swfwire.utils.ByteArrayUtil;
	
	import flash.display.Scene;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.sampler.NewObjectSample;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.getQualifiedClassName;
	
	public class SWFReader extends EventDispatcher
	{
		private static var FILE_VERSION:uint = 1;
		
		public var version:uint = FILE_VERSION;
		
		public function read(bytes:SWFByteArray):SWFReadResult 
		{
			var result:SWFReadResult = new SWFReadResult();
			
			var swf:SWF = new SWF();
			swf.header = new SWFHeader();
			swf.tags = new Vector.<SWFTag>();
			
			var context:SWFReaderContext = new SWFReaderContext(bytes, 0, result);
			
			readSWFHeader(context, swf.header);
			
			context.fileVersion = swf.header.fileVersion;
			
			if(swf.header.fileVersion > version)
			{
				result.warnings.push('Invalid file version ('+swf.header.fileVersion+') in header.');
			}
			
			while(bytes.getBytesAvailable() > 0)
			{
				var tagId:uint = swf.tags.length;
				var preHeaderStart:uint = bytes.getBytePosition();
				
				var header:TagHeaderRecord = readTagHeaderRecord(context);
				
				var startPosition:uint = context.bytes.getBytePosition();
				var expectedEndPosition:uint = startPosition + header.length;
				
				context.tagId = tagId;
				
				var tag:SWFTag;
				try
				{
					tag = readTag(context, header);
				}
				catch(e:Error)
				{
					result.errors.push('Error parsing Tag #'+tagId+' (type: '+header.type+').  Error: '+e);
					bytes.setBytePosition(startPosition);
					tag = readUnknownTag(context, header);
				}
				
				tag.header = header;
				
				swf.tags.push(tag);
				context.bytes.alignBytes();
				var newPosition:uint = context.bytes.getBytePosition();
				if(newPosition > expectedEndPosition)
				{
					result.warnings.push('Read overflow for Tag #'+tagId+' (type: '+tag.header.type+').' +
						' Read '+(newPosition - startPosition)+' bytes, expected '+(tag.header.length)+' bytes.');
				}
				if(newPosition < expectedEndPosition)
				{
					result.warnings.push('Read underflow for Tag #'+tagId+' (type: '+tag.header.type+').' +
						' Read '+(newPosition - startPosition)+' bytes, expected '+(tag.header.length)+' bytes.');
				}
				bytes.setBytePosition(expectedEndPosition);

				result.tagMetadata[tagId] = {name: getQualifiedClassName(tag), start: preHeaderStart, contentStart: startPosition, contentLength: tag.header.length, length: (expectedEndPosition - preHeaderStart)};
				
				if(tag is UnknownTag)
				{
					result.warnings.push('Unknown tag type: '+header.type+' (id: '+tagId+')');
				}
				if(tag is EndTag)
				{
					break;
				}
			}
			
			result.swf = swf;
			bytes.setBytePosition(0);
			
			return result;
		}
		
		protected function readSWFHeader(context:SWFReaderContext, header:SWFHeader):void
		{
			var bytes:SWFByteArray = context.bytes;
			header.signature = bytes.readStringWithLength(3);
			header.fileVersion = bytes.readUI8();
			header.uncompressedSize = bytes.readUI32();
			if(header.signature == SWFHeader.COMPRESSED_SIGNATURE)
			{
				decompress(bytes);
			}
			header.frameSize = readRectangleRecord(context);
			header.frameRate = bytes.readFixed8_8();
			header.frameCount = bytes.readUI16();
		}
		
		protected function readTag(context:SWFReaderContext, header:TagHeaderRecord):SWFTag
		{
			var tag:SWFTag;
			
			switch(header.type)
			{
				/*
				case 5: 
					tag = readRemoveObjectTag(context, header);
					break;
				case 7: 
					tag = readDefineButtonTag(context, header);
					break;
				case 10: 
					tag = readDefineFontTag(context, header);
					break;
				case 13: 
					tag = readDefineFontInfoTag(context, header);
					break;
				case 14: 
					tag = readDefineSoundTag(context, header);
					break;
				case 15: 
					tag = readStartSoundTag(context, header);
					break;
				case 18: 
					tag = readSoundStreamHeadTag(context, header);
					break;
				case 19: 
					tag = readSoundStreamBlockTag(context, header);
					break;
				*/
				case 0:
					tag = readEndTag(context, header);
					break;
				case 1:
					tag = readShowFrameTag(context, header);
					break;
				case 2: 
					tag = readDefineShapeTag(context, header);
					break;
				case 4: 
					tag = readPlaceObjectTag(context, header);
					break;
				case 6: 
					tag = readDefineBitsTag(context, header);
					break;
				case 8: 
					tag = readJPEGTablesTag(context, header);
					break;
				case 9:
					tag = readSetBackgroundColorTag(context, header);
					break;
				case 11: 
					tag = readDefineTextTag(context, header);
					break;
				case 77: 
					tag = readMetadataTag(context, header);
					break;
				case 86: 
					tag = readDefineSceneAndFrameLabelDataTag(context, header);
					break;
				default:
					tag = readUnknownTag(context, header);
					//throw new Error('Unknown Tag!');
					break;
			}
			
			return tag;
		}
		
		protected function readTagHeaderRecord(context:SWFReaderContext):TagHeaderRecord
		{
			var record:TagHeaderRecord = new TagHeaderRecord();
			var tagInfo:uint = context.bytes.readUI16();
			record.type = tagInfo >> 6;
			var length:uint = tagInfo & ((1 << 6) - 1);
			if(length == 0x3F)
			{
				length = context.bytes.readSI32();
				record.forceLong = true;
			}
			record.length = length;
			return record;
		}
		
		protected function readUnknownTag(context:SWFReaderContext, header:TagHeaderRecord):UnknownTag
		{
			var tag:UnknownTag = new UnknownTag();
			if(header.length > 0)
			{
				context.bytes.readBytes(tag.content, 0, header.length);
			}
			return tag;
		}
		
		protected function readDefineShapeTag(context:SWFReaderContext, header:TagHeaderRecord):DefineShapeTag
		{
			var tag:DefineShapeTag = new DefineShapeTag();
			tag.shapeId = context.bytes.readUI16();
			tag.shapeBounds = readRectangleRecord(context);
			tag.shapes = readShapeWithStyleRecord(context);
			return tag;
		}
		
		protected function readPlaceObjectTag(context:SWFReaderContext, header:TagHeaderRecord):PlaceObjectTag
		{
			var tag:PlaceObjectTag = new PlaceObjectTag();
			
			var originalPosition:uint = context.bytes.getBytePosition();
			tag.characterId = context.bytes.readUI16();
			tag.depth = context.bytes.readUI16();
			tag.matrix = readMatrixRecord(context);
			if(header.length > (context.bytes.getBytePosition() - originalPosition))
			{
				tag.colorTransform = readCXFormRecord(context);
			}
			
			return tag;
		}
		
		protected function readRemoveObjectTag(context:SWFReaderContext, header:TagHeaderRecord):RemoveObjectTag
		{
			var tag:RemoveObjectTag = new RemoveObjectTag();
			return tag;
		}
		
		protected function readDefineBitsTag(context:SWFReaderContext, header:TagHeaderRecord):DefineBitsTag
		{
			var tag:DefineBitsTag = new DefineBitsTag();
			tag.characterId = context.bytes.readUI16();
			tag.jpegData = new ByteArray();
			var length:int = header.length - 2;
			if(length > 0)
			{
				context.bytes.readBytes(tag.jpegData, 0, length);
			}
			return tag;
		}
		
		protected function readDefineButtonTag(context:SWFReaderContext, header:TagHeaderRecord):DefineButtonTag
		{
			var tag:DefineButtonTag = new DefineButtonTag();
			return tag;
		}
		
		protected function readJPEGTablesTag(context:SWFReaderContext, header:TagHeaderRecord):JPEGTablesTag
		{
			var tag:JPEGTablesTag = new JPEGTablesTag();
			tag.jpegData = new ByteArray();
			if(header.length > 0)
			{
				context.bytes.readBytes(tag.jpegData, 0, header.length);
			}
			return tag;
		}
		
		protected function readDefineFontTag(context:SWFReaderContext, header:TagHeaderRecord):DefineFontTag
		{
			var tag:DefineFontTag = new DefineFontTag();
			return tag;
		}
		
		protected function readGlyphEntryRecord(context:SWFReaderContext, glyphBits:uint, advanceBits:uint):GlyphEntryRecord
		{
			var record:GlyphEntryRecord = new GlyphEntryRecord();
			record.glyphIndex = context.bytes.readUB(glyphBits);
			record.glyphAdvance = context.bytes.readSB(advanceBits);
			return record;
		}
		
		protected function readTextRecord(context:SWFReaderContext, glyphBits:uint, advanceBits:uint):TextRecord
		{
			var record:TextRecord = new TextRecord();
			record.styleFlagsReserved = context.bytes.readUB(3);
			record.styleFlagsHasFont = context.bytes.readFlag();
			record.styleFlagsHasColor = context.bytes.readFlag();
			record.styleFlagsHasYOffset = context.bytes.readFlag();
			record.styleFlagsHasXOffset = context.bytes.readFlag();
			if(record.styleFlagsHasFont)
			{
				record.fontId = context.bytes.readUI16();
			}
			if(record.styleFlagsHasColor)
			{
				record.textColor = readRGBRecord(context);
			}
			if(record.styleFlagsHasXOffset)
			{
				record.xOffset = context.bytes.readSI16();
			}
			if(record.styleFlagsHasYOffset)
			{
				record.yOffset = context.bytes.readSI16();
			}
			if(record.styleFlagsHasFont)
			{
				record.textHeight = context.bytes.readUI16();
			}
			record.glyphCount = context.bytes.readUI8();
			record.glyphEntries = new Vector.<GlyphEntryRecord>(record.glyphCount);
			for(var iter:uint = 0; iter < record.glyphCount; iter++)
			{
				record.glyphEntries[iter] = readGlyphEntryRecord(context, glyphBits, advanceBits);
			}
			return record;
		}
		
		protected function readDefineTextTag(context:SWFReaderContext, header:TagHeaderRecord):DefineTextTag
		{
			var tag:DefineTextTag = new DefineTextTag();
			tag.characterId = context.bytes.readUI16();
			tag.textBounds = readRectangleRecord(context);
			tag.textMatrix = readMatrixRecord(context);
			var glyphBits:uint = context.bytes.readUI8();
			var advanceBits:uint = context.bytes.readUI8();
			tag.glyphBits = glyphBits;
			tag.advanceBits = advanceBits;
			tag.textRecords = new Vector.<TextRecord>();
			while(true)
			{
				var typeFlag:uint = context.bytes.readUB(1);
				if(typeFlag == 0)
				{
					context.bytes.readUB(7);
					break;
				}
				tag.textRecords.push(readTextRecord(context, glyphBits, advanceBits));
			}
			return tag;
		}

		protected function readDefineFontInfoTag(context:SWFReaderContext, header:TagHeaderRecord):DefineFontInfoTag
		{
			var tag:DefineFontInfoTag = new DefineFontInfoTag();
			return tag;
		}

		protected function readDefineSoundTag(context:SWFReaderContext, header:TagHeaderRecord):DefineSoundTag
		{
			var tag:DefineSoundTag = new DefineSoundTag();
			return tag;
		}

		protected function readStartSoundTag(context:SWFReaderContext, header:TagHeaderRecord):StartSoundTag
		{
			var tag:StartSoundTag = new StartSoundTag();
			return tag;
		}

		protected function readSoundStreamHeadTag(context:SWFReaderContext, header:TagHeaderRecord):SoundStreamHeadTag
		{
			var tag:SoundStreamHeadTag = new SoundStreamHeadTag();
			return tag;
		}

		protected function readSoundStreamBlockTag(context:SWFReaderContext, header:TagHeaderRecord):SoundStreamBlockTag
		{
			var tag:SoundStreamBlockTag = new SoundStreamBlockTag();
			return tag;
		}

		protected function readDefineSceneAndFrameLabelDataTag(context:SWFReaderContext, header:TagHeaderRecord):DefineSceneAndFrameLabelDataTag
		{
			var tag:DefineSceneAndFrameLabelDataTag = new DefineSceneAndFrameLabelDataTag();
			var iter:uint;
			
			var sceneCount:uint = context.bytes.readEncodedUI32();
			tag.scenes.length = sceneCount;
			for(iter = 0; iter < sceneCount; iter++)
			{
				var scene:SceneRecord = readSceneRecord(context);
				tag.scenes[iter] = scene;
			}
			var frameLabelCount:uint = context.bytes.readEncodedUI32();
			tag.frameLabels.length = frameLabelCount;
			for(iter = 0; iter < frameLabelCount; iter++)
			{
				var frameLabel:FrameLabelRecord = readFrameLabelRecord(context);
				tag.frameLabels[iter] = frameLabel;
			}
			return tag;
		}
		
		protected function readEndTag(context:SWFReaderContext, header:TagHeaderRecord):EndTag
		{
			return new EndTag();
		}
		
		protected function readShowFrameTag(context:SWFReaderContext, header:TagHeaderRecord):ShowFrameTag
		{
			return new ShowFrameTag();
		}
		
		protected function readSetBackgroundColorTag(context:SWFReaderContext, header:TagHeaderRecord):SetBackgroundColorTag
		{
			var tag:SetBackgroundColorTag = new SetBackgroundColorTag();
			tag.backgroundColor = readRGBRecord(context);
			return tag;
		}
		
		protected function readMetadataTag(context:SWFReaderContext, header:TagHeaderRecord):MetadataTag
		{
			var tag:MetadataTag = new MetadataTag();
			tag.metadata = context.bytes.readString();
			return tag;
		}
		
		protected function readLanguageCodeRecord(context:SWFReaderContext):LanguageCodeRecord
		{
			var record:LanguageCodeRecord = new LanguageCodeRecord();
			record.languageCode = context.bytes.readUI8();
			return record;
		}
		
		protected function readShapeWithStyleRecord(context:SWFReaderContext):ShapeWithStyleRecord
		{
			var record:ShapeWithStyleRecord = new ShapeWithStyleRecord();
			
			record.fillStyles = readFillStyleArrayRecord(context);
			record.lineStyles = readLineStyleArrayRecord(context);
			record.numFillBits = context.bytes.readUB(4);
			record.numLineBits = context.bytes.readUB(4);
			record.shapeRecords = new Vector.<IShapeRecord>();
			while(true)
			{
				var shapeRecord:IShapeRecord = readShapeRecord(context, record.numFillBits, record.numLineBits);
				record.shapeRecords.push(shapeRecord);
				if(shapeRecord is EndShapeRecord)
				{
					break;
				}
			}
			
			return record;
		}
		
		protected function readShapeRecord(context:SWFReaderContext, numFillBits:uint, numLineBits:uint):IShapeRecord
		{
			var record:IShapeRecord;
			var typeFlag:Boolean = context.bytes.readFlag();
			if(!typeFlag)
			{
				var reserved:int = context.bytes.readUB(1);
				var stateLineStyle:Boolean = context.bytes.readFlag();
				var stateFillStyle1:Boolean = context.bytes.readFlag();
				var stateFillStyle0:Boolean = context.bytes.readFlag();
				var stateMoveTo:Boolean = context.bytes.readFlag();
				if(reserved == 0 &&
					!stateLineStyle &&
					!stateFillStyle1 &&
					!stateFillStyle0 &&
					!stateMoveTo)
				{
					record = new EndShapeRecord();
				}
				else
				{
					record = readStyleChangeRecord(context,
						reserved,
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
		
		protected function readStyleChangeRecord(context:SWFReaderContext, reserved:uint,
			stateLineStyle:Boolean, stateFillStyle1:Boolean,
			stateFillStyle0:Boolean, stateMoveTo:Boolean, 
			numFillBits:uint, numLineBits:uint):StyleChangeRecord
		{
			var record:StyleChangeRecord = new StyleChangeRecord();
			
			record.reserved = reserved;
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
			return record;
		}
		
		protected function readStraightEdgeRecord(context:SWFReaderContext):StraightEdgeRecord
		{
			var record:StraightEdgeRecord = new StraightEdgeRecord();
			var numBits:uint = context.bytes.readUB(4) + 2;
			record.generalLineFlag = context.bytes.readFlag();
			if(record.generalLineFlag)
			{
				record.deltaX = context.bytes.readSB(numBits);
				record.deltaY = context.bytes.readSB(numBits);
			}
			else
			{
				record.vertLineFlag = context.bytes.readFlag();
				if(!record.vertLineFlag)
				{
					record.deltaX = context.bytes.readSB(numBits);
				}
				else
				{
					record.deltaY = context.bytes.readSB(numBits);
				}
			}
			return record;
		}
		
		protected function readCurvedEdgeRecord(context:SWFReaderContext):CurvedEdgeRecord
		{
			var record:CurvedEdgeRecord = new CurvedEdgeRecord();
			record.numBits = context.bytes.readUB(4);
			record.controlDeltaX = context.bytes.readSB(record.numBits + 2);
			record.controlDeltaY = context.bytes.readSB(record.numBits + 2);
			record.anchorDeltaX = context.bytes.readSB(record.numBits + 2);
			record.anchorDeltaY = context.bytes.readSB(record.numBits + 2);
			return record;
		}
		
		protected function readFillStyleArrayRecord(context:SWFReaderContext):FillStyleArrayRecord
		{
			var record:FillStyleArrayRecord = new FillStyleArrayRecord();
			
			record.count = context.bytes.readUI8();
			record.fillStyles = new Vector.<FillStyleRecord>(record.count);
			for(var iter:uint = 0; iter < record.count; iter++)
			{
				record.fillStyles[iter] = readFillStyleRecord(context);
			}

			return record;
		}
		
		protected function readLineStyleArrayRecord(context:SWFReaderContext):LineStyleArrayRecord
		{
			var record:LineStyleArrayRecord = new LineStyleArrayRecord();
			
			record.count = context.bytes.readUI8();
			if(record.count == 0xFF)
			{
				record.countExtended = context.bytes.readUI16();
			}
			record.lineStyles = new Vector.<LineStyleRecord>(record.count);
			for(var iter:uint = 0; iter < record.count; iter++)
			{
				record.lineStyles[iter] = readLineStyleRecord(context);
			}

			return record;
		}
		
		protected function readFillStyleRecord(context:SWFReaderContext):FillStyleRecord
		{
			var record:FillStyleRecord = new FillStyleRecord();
			
			var type:uint = context.bytes.readUI8();
			record.type = type;
			if(type == 0x00)
			{
				record.color = readRGBRecord(context);
			}
			if(type == 0x10 || type == 0x12)
			{
				record.gradientMatrix = readMatrixRecord(context);
				record.gradient = readGradientRecord(context);
			}
			if(type == 0x40 || type == 0x41 || type == 0x42 || type == 0x43)
			{
				record.bitmapId = context.bytes.readUI16();
				record.bitmapMatrix = readMatrixRecord(context);
			}
			
			return record;
		}
		
		protected function readLineStyleRecord(context:SWFReaderContext):LineStyleRecord
		{
			var record:LineStyleRecord = new LineStyleRecord();
			record.width = context.bytes.readUI16();
			record.color = readRGBRecord(context);
			return record;
		}
		
		protected function readGradientRecord(context:SWFReaderContext):GradientRecord
		{
			context.bytes.alignBytes();
			var record:GradientRecord = new GradientRecord();
			record.reserved = context.bytes.readUB(4);
			record.numGradients = context.bytes.readUB(4);
			record.gradientRecords = new Vector.<GradientControlPointRecord>(record.numGradients);
			for(var iter:uint = 0; iter < record.numGradients; iter++)
			{
				record.gradientRecords[iter] = readGradientControlPointRecord(context);
			}
			return record;
		}
		
		protected function readGradientControlPointRecord(context:SWFReaderContext):GradientControlPointRecord
		{
			var record:GradientControlPointRecord = new GradientControlPointRecord();
			record.ratio = context.bytes.readUI8();
			record.color = readRGBRecord(context);
			return record;
		}
		
		protected function readRectangleRecord(context:SWFReaderContext):RectangleRecord
		{
			context.bytes.alignBytes();
			var record:RectangleRecord = new RectangleRecord();
			var nBits:uint = context.bytes.readUB(5);
			record.xMin = context.bytes.readSB(nBits);
			record.xMax = context.bytes.readSB(nBits);
			record.yMin = context.bytes.readSB(nBits);
			record.yMax = context.bytes.readSB(nBits);
			return record;
		}
		
		protected function readMatrixRecord(context:SWFReaderContext):MatrixRecord
		{
			context.bytes.alignBytes();
			var record:MatrixRecord = new MatrixRecord();
			var hasScale:Boolean = context.bytes.readFlag();
			if(hasScale)
			{
				var nScaleBits:uint = context.bytes.readUB(5);
				
				record.scale = new MatrixScaleStructure();
				record.scale.x = context.bytes.readFB(nScaleBits);
				record.scale.y = context.bytes.readFB(nScaleBits);
			}
			
			var hasRotate:Boolean = context.bytes.readFlag();
			if(hasRotate)
			{
				var nRotateBits:uint = context.bytes.readUB(5);
				
				record.rotate = new MatrixRotateStructure();
				record.rotate.skew0 = context.bytes.readFB(nRotateBits);
				record.rotate.skew1 = context.bytes.readFB(nRotateBits);
			}
			
			var nTranslateBits:uint = context.bytes.readUB(5);
			record.translate = new MatrixTranslateStructure();
			record.translate.x = context.bytes.readSB(nTranslateBits);
			record.translate.y = context.bytes.readSB(nTranslateBits);
			return record;
		}
		
		protected function readCXFormRecord(context:SWFReaderContext):CXFormRecord
		{
			context.bytes.alignBytes();
			var record:CXFormRecord = new CXFormRecord();
			record.hasAddTerms = context.bytes.readFlag();
			record.hasMultTerms = context.bytes.readFlag();
			record.nBits = context.bytes.readUB(4);
			
			if(record.hasMultTerms)
			{
				record.redMultTerm = context.bytes.readSB(record.nBits);
				record.greenMultTerm = context.bytes.readSB(record.nBits);
				record.blueMultTerm = context.bytes.readSB(record.nBits);
			}
			
			if(record.hasAddTerms)
			{
				record.redAddTerm = context.bytes.readSB(record.nBits);
				record.greenAddTerm = context.bytes.readSB(record.nBits);
				record.blueAddTerm = context.bytes.readSB(record.nBits);
			}
			return record;
		}
		
		protected function readSceneRecord(context:SWFReaderContext):SceneRecord
		{
			var record:SceneRecord = new SceneRecord();
			record.offset = context.bytes.readEncodedUI32();
			record.name = context.bytes.readString();
			return record;
		}
		
		protected function readFrameLabelRecord(context:SWFReaderContext):FrameLabelRecord
		{
			var record:FrameLabelRecord = new FrameLabelRecord();
			record.frameNum = context.bytes.readEncodedUI32();
			record.frameLabel = context.bytes.readString();
			return record;
		}
		
		protected function readRGBRecord(context:SWFReaderContext):RGBRecord
		{
			var record:RGBRecord = new RGBRecord();
			record.red = context.bytes.readUI8();
			record.green = context.bytes.readUI8();
			record.blue = context.bytes.readUI8();
			return record;
		}
		
		private function decompress(bytes:SWFByteArray):void
		{
			var startPosition:uint = bytes.getBytePosition();
			var uncompressedBytes:ByteArray = new ByteArray();
			bytes.readBytes(uncompressedBytes);
			uncompressedBytes.uncompress();
			bytes.setBytePosition(startPosition);
			bytes.writeBytes(uncompressedBytes);
			bytes.setBytePosition(startPosition);
		}
	}
}
