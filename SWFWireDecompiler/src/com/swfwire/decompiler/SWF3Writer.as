package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.records.CurvedEdgeRecord;
	import com.swfwire.decompiler.data.swf.records.DropShadowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.EndShapeRecord;
	import com.swfwire.decompiler.data.swf.records.IShapeRecord;
	import com.swfwire.decompiler.data.swf.records.StraightEdgeRecord;
	import com.swfwire.decompiler.data.swf.tags.DefineButtonTag;
	import com.swfwire.decompiler.data.swf.tags.EndTag;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.actions.ButtonCondAction;
	import com.swfwire.decompiler.data.swf3.records.ARGBRecord;
	import com.swfwire.decompiler.data.swf3.records.ActionRecord;
	import com.swfwire.decompiler.data.swf3.records.AlphaBitmapDataRecord;
	import com.swfwire.decompiler.data.swf3.records.AlphaColorMapDataRecord;
	import com.swfwire.decompiler.data.swf3.records.ButtonRecord2;
	import com.swfwire.decompiler.data.swf3.records.CXFormWithAlphaRecord;
	import com.swfwire.decompiler.data.swf3.records.FillStyleArrayRecord3;
	import com.swfwire.decompiler.data.swf3.records.FillStyleRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientControlPointRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientRecord2;
	import com.swfwire.decompiler.data.swf3.records.LineStyleArrayRecord2;
	import com.swfwire.decompiler.data.swf3.records.LineStyleRecord2;
	import com.swfwire.decompiler.data.swf3.records.ShapeWithStyleRecord3;
	import com.swfwire.decompiler.data.swf3.records.StyleChangeRecord3;
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
				case DefineButton2Tag:
					writeDefineButton2Tag(context, DefineButton2Tag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writePlaceObject2Tag(context:SWFWriterContext, tag:PlaceObject2Tag):void
		{
			context.bytes.writeUB(1, 0);
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
		
		protected override function writeDefineButtonTag(context:SWFWriterContext, tag:DefineButtonTag):void
		{
			super.writeDefineButtonTag(context, tag);
			var actionCount:uint = tag.actions.length;
			for(var iter:uint = 0; iter < actionCount; iter++)
			{
				writeActionRecord(context, tag.actions[iter]);
			}
			context.bytes.writeUI8(0);
		}
		
		protected function writeDefineButton2Tag(context:SWFWriterContext, tag:DefineButton2Tag):void
		{
			context.bytes.writeUI16(tag.buttonId);
			context.bytes.writeUB(7, 0);
			context.bytes.writeFlag(tag.trackAsMenu);
			context.bytes.writeUI16(tag.actionOffset); // todo : set the right value
			var characterCount:uint = tag.characters.length;
			if(characterCount == 0)
			{
				context.result.warnings.push('DefineButton2 character count was 0.');
			}
			for(var iter:uint = 0; iter < characterCount; iter++)
			{
				writeButtonRecord2(context, tag.characters[iter]);
			}
			context.bytes.writeUI8(0);
			var actionsLength:uint = tag.actions.length;
			for(var actionIndex:uint = 0; actionIndex < actionsLength; actionIndex++)
			{
				writeButtonCondAction(context, tag.actions[actionIndex], (actionIndex == (actionsLength - 1)));
			}
		}
		
		protected function writeButtonRecord2(context:SWFWriterContext, record:ButtonRecord2):void
		{
			context.bytes.writeUB(4, record.reserved);
			context.bytes.writeFlag(record.stateHitTest);
			context.bytes.writeFlag(record.stateDown);
			context.bytes.writeFlag(record.stateOver);
			context.bytes.writeFlag(record.stateUp);
			context.bytes.writeUI16(record.characterId);
			context.bytes.writeUI16(record.placeDepth);
			writeMatrixRecord(context, record.placeMatrix);
			writeCXFormWithAlphaRecord(context, record.colorTransform);
		}
		
		protected function writeButtonCondAction(context:SWFWriterContext, action:ButtonCondAction, isLastRecord:Boolean):void
		{
			context.bytes.writeUI16(isLastRecord ? 0 : action.condActionSize);
			var size:uint = action.condActionSize - 2;
			if(size > 0)
			{
				context.bytes.writeFlag(action.condIdleToOverDown);
				context.bytes.writeFlag(action.condOutDownToldle);
				context.bytes.writeFlag(action.condOutDownToOverDown);
				context.bytes.writeFlag(action.condOverDownToOutDown);
				context.bytes.writeFlag(action.condOverDownToOverUp);
				context.bytes.writeFlag(action.condOverUpToOverDown);
				context.bytes.writeFlag(action.condOverUpToIdle);
				context.bytes.writeFlag(action.condIdleToOverUp);
				size--;
			}
			if(size > 0)
			{
				context.bytes.writeUB(7, action.condKeyPress);
				context.bytes.writeFlag(action.condOverDownToIdle);
				size--;
			}
			if(size > 0)
			{
				for(var iter:uint = 0; iter < action.actions.length; iter++)
				{
					var startPosition:uint = context.bytes.getBytePosition();
					action.actions.push(writeActionRecord(context, action.actions[iter]));
					size -= (context.bytes.getBytePosition() - startPosition);
					if(size == 0)
					{
						break;
					}
					if(size < 0)
					{
						throw new Error("Wrong CondActionSize value");
					}
				}
			}
			context.bytes.writeUI8(0);
		}
		
		protected function writeActionRecord(context:SWFWriterContext, record:ActionRecord):void
		{
			throw new Error("Writing ActionRecord not implemented");
		}
	}
}