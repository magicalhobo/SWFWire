package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.SWFHeader;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.*;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class SWFWriter extends EventDispatcher
	{
		public static const TAG_IDS:Object = {
				0: EndTag,
				1: ShowFrameTag,
				2: DefineShapeTag,
				4: PlaceObjectTag,
				5: RemoveObjectTag,
				6: DefineBitsTag,
				7: DefineButtonTag,
				8: JPEGTablesTag,
				9: SetBackgroundColorTag,
				11: DefineTextTag,
				13: DefineFontInfoTag,
				14: DefineSoundTag,
				15: StartSoundTag,
				18: SoundStreamHeadTag,
				19: SoundStreamBlockTag,
				77: MetadataTag,
				86: DefineSceneAndFrameLabelDataTag
			};
		
		private static var FILE_VERSION:uint = 1;
		
		public var version:uint = FILE_VERSION;
		
		protected var registeredTags:Dictionary;
		
		public function SWFWriter()
		{
			registeredTags = new Dictionary();
			registerTags(TAG_IDS);
		}
		
		public function registerTags(map:Object):void
		{
			for(var iter:String in map)
			{
				registeredTags[map[iter]] = iter;
			}
		}

		public function write(swf:SWF):SWFWriteResult
		{
			var result:SWFWriteResult = new SWFWriteResult();
			
			var context:SWFWriterContext = new SWFWriterContext(new SWFByteArray(new ByteArray()), swf.header.fileVersion, result);
			
			if(swf.header.fileVersion > version)
			{
				result.warnings.push('Invalid file version ('+swf.header.fileVersion+') in header.');
			}
			
			var tagCount:uint = swf.tags.length;
			var tagBytes:Vector.<ByteArray> = new Vector.<ByteArray>(tagCount);
			
			var iter:uint;
			
			for(iter = 0; iter < tagCount; iter++)
			{
				var tag:SWFTag = swf.tags[iter];
				var currentTagBytes:ByteArray = new ByteArray();
				try
				{
					context.tagId = iter;
					context.bytes = new SWFByteArray(currentTagBytes);
					writeTag(context, tag);
					tag.header.length = currentTagBytes.length;
					tagBytes[iter] = currentTagBytes;
				}
				catch(e:Error)
				{
					result.errors.push('Could not write Tag #'+iter+': '+e);
				}
			}
			
			var bytes1:ByteArray = new ByteArray();
			var bytes:SWFByteArray = new SWFByteArray(bytes1);
			context.bytes = bytes;
			
			writeSWFHeader(context, swf.header);
			
			for(iter = 0; iter < tagCount; iter++)
			{
				if(!tagBytes[iter])
				{
					continue;
				}
				bytes.alignBytes();
				var header:TagHeaderRecord = swf.tags[iter].header;
				if(registeredTags.hasOwnProperty(Object(swf.tags[iter]).constructor))
				{
					header.type = registeredTags[Object(swf.tags[iter]).constructor];
				}
				writeTagHeaderRecord(context, header);
				bytes.writeBytes(tagBytes[iter]);
			}
			
			bytes.setBytePosition(4);
			var tl:uint = bytes.getLength();
			bytes.writeUI32(tl);
			
			bytes.setBytePosition(0);
			result.bytes = bytes1;
			
			return result;
		}
		
		protected function writeSWFHeader(context:SWFWriterContext, header:SWFHeader):void
		{
			var bytes:SWFByteArray = context.bytes;
			bytes.writeStringWithLength(header.signature, 3);
			bytes.writeUI8(header.fileVersion);
			bytes.writeUI32(bytes.getLength());
			writeRectangleRecord(context, header.frameSize);
			bytes.writeFixed8_8(header.frameRate);
			bytes.writeUI16(header.frameCount);
		}
		
		protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case EndTag:
				case ShowFrameTag:
					break;
				case DefineShapeTag:
					writeDefineShapeTag(context, DefineShapeTag(tag));
					break;
				case DefineBitsTag:
					writeDefineBitsTag(context, DefineBitsTag(tag));
					break;
				case JPEGTablesTag:
					writeJPEGTablesTag(context, JPEGTablesTag(tag));
					break;
				case SetBackgroundColorTag:
					writeSetBackgroundColorTag(context, SetBackgroundColorTag(tag));
					break;
				case DefineTextTag:
					writeDefineTextTag(context, DefineTextTag(tag));
					break;
				case MetadataTag:
					writeMetadataTag(context, MetadataTag(tag));
					break;
				case DefineSceneAndFrameLabelDataTag: 
					writeDefineSceneAndFrameLabelDataTag(context, DefineSceneAndFrameLabelDataTag(tag));
					break;
				case UnknownTag:
					writeUnknownTag(context, UnknownTag(tag));
					break;
				default:
					throw new Error('Unsupported tag ('+Object(tag).constructor+') encountered.');
					break;
			}
		}
		
		protected function writeTagHeaderRecord(context:SWFWriterContext, record:TagHeaderRecord):void
		{
			var length:uint = record.length;
			var longLength:Boolean = false;
			if(length > 0x3F || record.forceLong)
			{
				longLength = true;
				length = 0x3F;
			}
			var tagInfo:uint = ((record.type & ((1 << 10) - 1)) << 6) | length;
			context.bytes.writeUI16(tagInfo);
			if(longLength)
			{
				context.bytes.writeSI32(record.length);
			}
		}
		
		protected function writeUnknownTag(context:SWFWriterContext, tag:UnknownTag):void
		{
			context.bytes.writeBytes(tag.content);
		}
		
		protected function writeDefineShapeTag(context:SWFWriterContext, tag:DefineShapeTag):void
		{
			context.bytes.writeUI16(tag.shapeId);
			writeRectangleRecord(context, tag.shapeBounds);
			writeShapeWithStyleRecord(context, tag.shapes);
		}
		
		protected function writeDefineBitsTag(context:SWFWriterContext, tag:DefineBitsTag):void
		{
			context.bytes.writeUI16(tag.characterId);
			if(tag.jpegData.length > 0)
			{
				context.bytes.writeBytes(tag.jpegData);
			}
		}
		
		protected function writeJPEGTablesTag(context:SWFWriterContext, tag:JPEGTablesTag):void
		{
			if(tag.jpegData.length > 0)
			{
				context.bytes.writeBytes(tag.jpegData);
			}
		}
		
		protected function writeSetBackgroundColorTag(context:SWFWriterContext, tag:SetBackgroundColorTag):void
		{
			writeRGBRecord(context, tag.backgroundColor);
		}
		
		protected function writeDefineTextTag(context:SWFWriterContext, tag:DefineTextTag):void
		{
			context.bytes.writeUI16(tag.characterId);
			writeRectangleRecord(context, tag.textBounds);
			writeMatrixRecord(context, tag.textMatrix);
			
			context.bytes.writeUI8(tag.glyphBits);
			context.bytes.writeUI8(tag.advanceBits);
			
			for(var iter:uint = 0; iter < tag.textRecords.length; iter++)
			{
				context.bytes.writeUB(1, 1);
				writeTextRecord(context, tag.glyphBits, tag.advanceBits, tag.textRecords[iter]);
			}
			
			context.bytes.writeUB(8, 0);
		}
		
		protected function writeMetadataTag(context:SWFWriterContext, tag:MetadataTag):void
		{
			context.bytes.writeString(tag.metadata);
		}
		
		protected function writeDefineSceneAndFrameLabelDataTag(context:SWFWriterContext, tag:DefineSceneAndFrameLabelDataTag):void
		{
			var iter:uint;
			
			var sceneCount:uint = tag.scenes.length;
			context.bytes.writeEncodedUI32(sceneCount);
			for(iter = 0; iter < sceneCount; iter++)
			{
				writeSceneRecord(context, tag.scenes[iter]);
			}
			var frameLabelCount:uint = tag.frameLabels.length;
			context.bytes.writeEncodedUI32(frameLabelCount);
			for(iter = 0; iter < frameLabelCount; iter++)
			{
				writeFrameLabelRecord(context, tag.frameLabels[iter]);
			}
		}
		
		protected function writeSceneRecord(context:SWFWriterContext, record:SceneRecord):void
		{
			context.bytes.writeEncodedUI32(record.offset);
			context.bytes.writeString(record.name);
		}
		
		protected function writeFrameLabelRecord(context:SWFWriterContext, record:FrameLabelRecord):void
		{
			context.bytes.writeEncodedUI32(record.frameNum);
			context.bytes.writeString(record.frameLabel);
		}
		
		protected function writeGlyphEntryRecord(context:SWFWriterContext, glyphBits:uint, advanceBits:uint, record:GlyphEntryRecord):void
		{
			context.bytes.writeUB(glyphBits, record.glyphIndex);
			context.bytes.writeSB(advanceBits, record.glyphAdvance);
		}
		
		protected function writeTextRecord(context:SWFWriterContext, glyphBits:uint, advanceBits:uint, record:TextRecord):void
		{
			context.bytes.writeUB(3, record.styleFlagsReserved);
			context.bytes.writeFlag(record.styleFlagsHasFont);
			context.bytes.writeFlag(record.styleFlagsHasColor);
			context.bytes.writeFlag(record.styleFlagsHasYOffset);
			context.bytes.writeFlag(record.styleFlagsHasXOffset);
			if(record.styleFlagsHasFont)
			{
				context.bytes.writeUI16(record.fontId);
			}
			if(record.styleFlagsHasColor)
			{
				writeRGBRecord(context, record.textColor);
			}
			if(record.styleFlagsHasXOffset)
			{
				context.bytes.writeSI16(record.xOffset);
			}
			if(record.styleFlagsHasYOffset)
			{
				context.bytes.writeSI16(record.yOffset);
			}
			if(record.styleFlagsHasFont)
			{
				context.bytes.writeUI16(record.textHeight);
			}
			context.bytes.writeUI8(record.glyphCount);
			for(var iter:uint = 0; iter < record.glyphCount; iter++)
			{
				writeGlyphEntryRecord(context, glyphBits, advanceBits, record.glyphEntries[iter]);
			}
		}
		
		protected function writeRGBRecord(context:SWFWriterContext, record:RGBRecord):void
		{
			context.bytes.writeUI8(record.red);
			context.bytes.writeUI8(record.green);
			context.bytes.writeUI8(record.blue);
		}
		
		protected function writeRGBARecord(context:SWFWriterContext, record:RGBARecord):void
		{
			context.bytes.writeUI8(record.red);
			context.bytes.writeUI8(record.green);
			context.bytes.writeUI8(record.blue);
			context.bytes.writeUI8(record.alpha);
		}
		
		protected function writeGradientRecord(context:SWFWriterContext, record:GradientRecord):void
		{
			context.bytes.alignBytes();
			context.bytes.writeUB(4, record.reserved);
			context.bytes.writeUB(4, record.numGradients);
			for(var iter:uint = 0; iter < record.numGradients; iter++)
			{
				writeGradientControlPointRecord(context, record.gradientRecords[iter]);
			}
		}
		
		protected function writeGradientControlPointRecord(context:SWFWriterContext, record:GradientControlPointRecord):void
		{
			context.bytes.writeUI8(record.ratio);
			writeRGBRecord(context, record.color);
		}
		
		protected function writeRectangleRecord(context:SWFWriterContext, record:RectangleRecord):void
		{
			context.bytes.alignBytes();
			var nBits:uint = Math.max(
				SWFByteArray.calculateSBBits(record.xMin),
				SWFByteArray.calculateSBBits(record.xMax),
				SWFByteArray.calculateSBBits(record.yMin),
				SWFByteArray.calculateSBBits(record.yMax));
				
			context.bytes.writeUB(5, nBits);
			context.bytes.writeSB(nBits, record.xMin);
			context.bytes.writeSB(nBits, record.xMax);
			context.bytes.writeSB(nBits, record.yMin);
			context.bytes.writeSB(nBits, record.yMax);
		}
		
		protected function writeMatrixRecord(context:SWFWriterContext, record:MatrixRecord):void
		{
			context.bytes.alignBytes();
			
			var hasScale:Boolean = record.scale != null;
			context.bytes.writeFlag(hasScale);
			if(hasScale)
			{
				var nScaleBits:uint = Math.max(
					SWFByteArray.calculateFBBits(record.scale.x),
					SWFByteArray.calculateFBBits(record.scale.y));
				
				context.bytes.writeUB(5, nScaleBits);
				context.bytes.writeFB(nScaleBits, record.scale.x);
				context.bytes.writeFB(nScaleBits, record.scale.y);
			}
			
			var hasRotate:Boolean = record.rotate != null;
			context.bytes.writeFlag(hasRotate);
			if(hasRotate)
			{
				var nRotateBits:uint = Math.max(
					SWFByteArray.calculateFBBits(record.rotate.skew0),
					SWFByteArray.calculateFBBits(record.rotate.skew1));
				
				context.bytes.writeUB(5, nRotateBits);
				context.bytes.writeFB(nRotateBits, record.rotate.skew0);
				context.bytes.writeFB(nRotateBits, record.rotate.skew1);
			}
			
			var nTranslateBits:uint = Math.max(
				SWFByteArray.calculateSBBits(record.translate.x),
				SWFByteArray.calculateSBBits(record.translate.y));
			
			context.bytes.writeUB(5, nTranslateBits);
			context.bytes.writeSB(nTranslateBits, record.translate.x);
			context.bytes.writeSB(nTranslateBits, record.translate.y);
		}
		
		protected function writeStraightEdgeRecord(context:SWFWriterContext, record:StraightEdgeRecord):void
		{
			var numBits:uint = Math.max(
				SWFByteArray.calculateSBBits(record.deltaX),
				SWFByteArray.calculateSBBits(record.deltaY),
				2);
			
			context.bytes.writeUB(4, numBits - 2);
			context.bytes.writeFlag(record.generalLineFlag);
			if(record.generalLineFlag)
			{
				context.bytes.writeSB(numBits, record.deltaX);
				context.bytes.writeSB(numBits, record.deltaY);
			}
			else
			{
				context.bytes.writeFlag(record.vertLineFlag);
				if(!record.vertLineFlag)
				{
					context.bytes.writeSB(numBits, record.deltaX);
				}
				else
				{
					context.bytes.writeSB(numBits, record.deltaY);
				}
			}
		}
		
		protected function writeCurvedEdgeRecord(context:SWFWriterContext, record:CurvedEdgeRecord):void
		{
			var numBits:uint = Math.max(
				SWFByteArray.calculateSBBits(record.controlDeltaX),
				SWFByteArray.calculateSBBits(record.controlDeltaY),
				SWFByteArray.calculateSBBits(record.anchorDeltaX),
				SWFByteArray.calculateSBBits(record.anchorDeltaY),
				2);
			
			context.bytes.writeUB(4, numBits - 2);
			context.bytes.writeSB(numBits, record.controlDeltaX);
			context.bytes.writeSB(numBits, record.controlDeltaY);
			context.bytes.writeSB(numBits, record.anchorDeltaX);
			context.bytes.writeSB(numBits, record.anchorDeltaY);
		}
		
		protected function writeFillStyleRecord(context:SWFWriterContext, record:FillStyleRecord):void
		{
			var type:uint = record.type;
			context.bytes.writeUI8(type);
			if(type == 0x00)
			{
				writeRGBRecord(context, record.color);
			}
			if(type == 0x10 || type == 0x12)
			{
				writeMatrixRecord(context, record.gradientMatrix);
				writeGradientRecord(context, record.gradient);
			}
			if(type == 0x40 || type == 0x41 || type == 0x42 || type == 0x43)
			{
				context.bytes.writeUI16(record.bitmapId);
				writeMatrixRecord(context, record.bitmapMatrix);
			}
		}
		
		protected function writeLineStyleRecord(context:SWFWriterContext, record:LineStyleRecord):void
		{
			context.bytes.writeUI16(record.width);
			writeRGBRecord(context, record.color);
		}
		

		
		protected function writeFillStyleArrayRecord(context:SWFWriterContext, record:FillStyleArrayRecord):void
		{
			context.bytes.writeUI8(record.count);
			for(var iter:uint = 0; iter < record.count; iter++)
			{
				writeFillStyleRecord(context, record.fillStyles[iter]);
			}
		}
		
		protected function writeLineStyleArrayRecord(context:SWFWriterContext, record:LineStyleArrayRecord):void
		{
			context.bytes.writeUI8(record.count);
			if(record.count == 0xFF)
			{
				context.bytes.writeUI16(record.countExtended);
			}
			for(var iter:uint = 0; iter < record.count; iter++)
			{
				writeLineStyleRecord(context, record.lineStyles[iter]);
			}
		}
		
		protected function writeShapeWithStyleRecord(context:SWFWriterContext, record:ShapeWithStyleRecord):void
		{
			writeFillStyleArrayRecord(context, record.fillStyles);
			writeLineStyleArrayRecord(context, record.lineStyles);
			context.bytes.writeUB(4, record.numFillBits);
			context.bytes.writeUB(4, record.numLineBits);
			for(var iter:uint = 0; iter < record.shapeRecords.length; iter++)
			{
				var shapeRecord:IShapeRecord = record.shapeRecords[iter];
				writeShapeRecord(context, record.numFillBits, record.numLineBits, shapeRecord);
				
				if(shapeRecord is EndShapeRecord)
				{
					break;
				}
			}
		}
		
		protected function writeShapeRecord(context:SWFWriterContext, numFillBits:uint, numLineBits:uint, record:IShapeRecord):void
		{
			if(record is StyleChangeRecord)
			{
				context.bytes.writeFlag(false);
				var styleChangeRecord:StyleChangeRecord = StyleChangeRecord(record);

				context.bytes.writeUB(1, styleChangeRecord.reserved);
				context.bytes.writeFlag(styleChangeRecord.stateLineStyle);
				context.bytes.writeFlag(styleChangeRecord.stateFillStyle1);
				context.bytes.writeFlag(styleChangeRecord.stateFillStyle0);
				context.bytes.writeFlag(styleChangeRecord.stateMoveTo);
				
				writeStyleChangeRecord(context,
					styleChangeRecord.reserved,
					styleChangeRecord.stateLineStyle, 
					styleChangeRecord.stateFillStyle1, 
					styleChangeRecord.stateFillStyle0,
					styleChangeRecord.stateMoveTo,
					numFillBits, numLineBits,
					StyleChangeRecord(record));
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
		}
		
		protected function writeStyleChangeRecord(context:SWFWriterContext, reserved:uint,
												 stateLineStyle:Boolean, stateFillStyle1:Boolean,
												 stateFillStyle0:Boolean, stateMoveTo:Boolean, 
												 numFillBits:uint, numLineBits:uint, record:StyleChangeRecord):void
		{
			record.reserved = reserved;
			record.stateLineStyle = stateLineStyle;
			record.stateFillStyle1 = stateFillStyle1;
			record.stateFillStyle0 = stateFillStyle0;
			record.stateMoveTo = stateMoveTo;
			
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
		}
	}
}
