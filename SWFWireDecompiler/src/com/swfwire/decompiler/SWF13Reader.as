package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.SWFHeader;
	
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;

	public class SWF13Reader extends SWF10Reader
	{
		private static var FILE_VERSION:uint = 13;
		
		public function SWF13Reader()
		{
			version = FILE_VERSION;
		}
		
		override protected function decompress(header:SWFHeader, bytes:SWFByteArray):void
		{
			if(header.signature == SWFHeader.LZMA_COMPRESSED_SIGNATURE)
			{
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
			}
			else
			{
				super.decompress(header, bytes);
			}
		}
	}
}