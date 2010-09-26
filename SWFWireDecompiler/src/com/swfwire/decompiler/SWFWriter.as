package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.SWFHeader;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.*;
	import com.swfwire.decompiler.data.swf3.tags.PlaceObject2Tag;
	import com.swfwire.decompiler.data.swf8.tags.FileAttributesTag;
	
	import flash.utils.ByteArray;

	public class SWFWriter
	{
		private static var FILE_VERSION:uint = 1;
		
		public var version:uint = FILE_VERSION;

		public function write(swf:SWF):SWFWriteResult
		{
			var result:SWFWriteResult = new SWFWriteResult();
			
			var context:SWFWriterContext = new SWFWriterContext(new SWFByteArray(new ByteArray()), null, swf.header.fileVersion);
			
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
					break;
				case ShowFrameTag:
					break;
				case FileAttributesTag:
					writeFileAttributesTag(context, FileAttributesTag(tag));
					break;
				case PlaceObject2Tag:
					writePlaceObject2Tag(context, PlaceObject2Tag(tag));
					break;
				default:
					writeUnknownTag(context, UnknownTag(tag));
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
				//writeMatrixRecord(context, tag.matrix);
			}
			
			if(tag.colorTransform)
			{
				//tag.colorTransform = readCXFormWithAlphaRecord(context);
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
				//tag.clipActions = readClipActionsRecord(context);
			}
		}
		
		protected function writeRectangleRecord(context:SWFWriterContext, record:RectangleRecord):void
		{
			context.bytes.alignBytes();
			var nBits:uint = record.nBits;
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
				var nScaleBits:uint = SWFByteArray.calculateUBBits(Math.max(record.scale.x, record.scale.y));
				context.bytes.writeUB(5, nScaleBits);
				context.bytes.writeFB(nScaleBits, record.scale.x);
				context.bytes.writeFB(nScaleBits, record.scale.y);
			}
			
			var hasRotate:Boolean = record.rotate != null;
			context.bytes.writeFlag(hasRotate);
			if(hasRotate)
			{
				var nRotateBits:uint = SWFByteArray.calculateUBBits(Math.max(record.rotate.skew0, record.rotate.skew1));
				context.bytes.writeUB(5, nRotateBits);
				context.bytes.writeFB(nRotateBits, record.rotate.skew0);
				context.bytes.writeFB(nRotateBits, record.rotate.skew1);
			}
			
			var nTranslateBits:uint = SWFByteArray.calculateUBBits(Math.max(record.translate.x, record.translate.y));
			context.bytes.writeUB(5, nTranslateBits);
			context.bytes.writeSB(nTranslateBits, record.translate.x);
			context.bytes.writeSB(nTranslateBits, record.translate.y);
		}
		
	}
}
