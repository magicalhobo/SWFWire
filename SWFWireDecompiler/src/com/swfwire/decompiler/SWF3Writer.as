package com.swfwire.decompiler
{
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
				case DefineBitsJPEG3Tag:
					writeDefineBitsJPEG3Tag(context, DefineBitsJPEG3Tag(tag));
					break;
				/*
				case DefineBitsLossless2Tag:
					writeDefineBitsLossless2Tag(context);
					break;
				*/
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