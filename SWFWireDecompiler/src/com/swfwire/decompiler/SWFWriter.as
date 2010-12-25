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
			var tagBytes:Vector.<ByteArray> = new Vector.<ByteArray>();
			
			var iter:uint;
			
			for(iter = 0; iter < tagCount; iter++)
			{
				var tag:SWFTag = swf.tags[iter];
				tagBytes[iter] = new ByteArray();
				try
				{
					context.tagId = iter;
					context.bytes = new SWFByteArray(tagBytes[iter]);
					writeTag(context, tag);
					tag.header.length = tagBytes[iter].length;
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
				bytes.alignBytes();
				var header:TagHeaderRecord = swf.tags[iter].header;
				header.type = registeredTags[Object(swf.tags[iter]).constructor];
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
			//var uncompressedBytes:SWFByteArray = context.uncompressedBytes;
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
				case SetBackgroundColorTag:
					writeSetBackgroundColorTag(context, SetBackgroundColorTag(tag));
					break;
				case UnknownTag:
					writeUnknownTag(context, UnknownTag(tag));
					break;
				default:
					throw new Error('Unsupported tag encountered.');
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
		
		protected function writeSetBackgroundColorTag(context:SWFWriterContext, tag:SetBackgroundColorTag):void
		{
			writeRGBRecord(context, tag.backgroundColor);
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
		
		protected function writeRectangleRecord(context:SWFWriterContext, record:RectangleRecord):void
		{
			context.bytes.alignBytes();
			var nBits:uint = Math.max(
				SWFByteArray.calculateSBBits(record.xMin),
				SWFByteArray.calculateSBBits(record.xMax),
				SWFByteArray.calculateSBBits(record.yMin),
				SWFByteArray.calculateSBBits(record.yMax));
				
				//record.nBits;
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
			context.bytes.writeUB(4, record.numBits);
			context.bytes.writeSB(record.numBits + 2, record.controlDeltaX);
			context.bytes.writeSB(record.numBits + 2, record.controlDeltaY);
			context.bytes.writeSB(record.numBits + 2, record.anchorDeltaX);
			context.bytes.writeSB(record.numBits + 2, record.anchorDeltaY);
		}
	}
}
