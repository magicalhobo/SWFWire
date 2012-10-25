package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.SWFHeader;
	import com.swfwire.decompiler.data.swf10.tags.*;
	
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;

	public class SWF13Writer extends SWF10Writer
	{
		private static var FILE_VERSION:uint = 13;
		
		public function SWF13Writer()
		{
			version = FILE_VERSION;
		}
		
		override protected function compress(header:SWFHeader, bytes:SWFByteArray):void
		{
			if(header.signature == SWFHeader.LZMA_COMPRESSED_SIGNATURE)
			{
				/*
				Format of SWF when LZMA is used:
				
				| 4 bytes       | 4 bytes    | 4 bytes       | 5 bytes    | n bytes    | 6 bytes         |
				| 'ZWS'+version | scriptLen  | compressedLen | LZMA props | LZMA data  | LZMA end marker |
				
				scriptLen is the uncompressed length of the SWF data. Includes 4 bytes SWF header and
				4 bytes for scriptLen itself.
				
				compressedLen does not include header (4+4+4 bytes) or lzma props (5 bytes)
				compressedLen does include LZMA end marker (6 bytes)
				
				var compressedSize:uint = bytes.readUI32();
				var startPosition:uint = bytes.getBytePosition();
				var properties:ByteArray = new ByteArray();
				bytes.readBytes(properties, 0, 5);
				var uncompressedBytes:ByteArray = new ByteArray();
				uncompressedBytes.endian = Endian.LITTLE_ENDIAN;
				uncompressedBytes.writeBytes(properties);
				uncompressedBytes.writeUnsignedInt(header.uncompressedSize - 8);
				uncompressedBytes.writeUnsignedInt(0);
				bytes.setBytePosition(17);
				bytes.readBytes(uncompressedBytes, 13);
				uncompressedBytes.uncompress(CompressionAlgorithm.LZMA);
				bytes.setBytePosition(startPosition);
				bytes.writeBytes(uncompressedBytes);
				bytes.setBytePosition(startPosition);
				
				*/
				
				var buffer:ByteArray = new ByteArray();
				buffer.endian = Endian.LITTLE_ENDIAN;
				
				bytes.setBytePosition(8);
				bytes.readBytes(buffer);
				
				buffer.compress(CompressionAlgorithm.LZMA);
				
				buffer.writeByte(0);
				buffer.writeByte(0);
				buffer.writeByte(0);
				buffer.writeByte(0);
				buffer.writeByte(0);
				buffer.writeByte(0);

				bytes.setLength(8);
				bytes.setBytePosition(8);
				bytes.writeUI32(buffer.length - 13);
				bytes.writeBytes(buffer, 0, 5);
				//bytes.writeBytes(buffer, 5, 8);
				bytes.writeBytes(buffer, 13);
			}
			else
			{
				super.compress(header, bytes);
			}
		}
		
		override protected function writeSWFHeader(context:SWFWriterContext, header:SWFHeader):void
		{
			var bytes:SWFByteArray = context.bytes;
			bytes.writeStringWithLength(header.signature, 3);
			bytes.writeUI8(header.fileVersion);
			bytes.writeUI32(0);
			writeRectangleRecord(context, header.frameSize);
			bytes.writeFixed8_8(header.frameRate);
			bytes.writeUI16(header.frameCount);
		}
	}
}