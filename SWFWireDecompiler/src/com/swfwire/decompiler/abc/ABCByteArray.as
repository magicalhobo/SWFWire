package com.swfwire.decompiler.abc
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class ABCByteArray
	{
		private static const filter7:uint = ~0 >>> -7;
		private static const filter30:uint = ~0 >>> -30;
		
		private var bytes:ByteArray;
		
		public function ABCByteArray(bytes:ByteArray)
		{
			this.bytes = bytes;
			bytes.endian = Endian.LITTLE_ENDIAN;
		}
		
		public function getBytePosition():uint
		{
			return bytes.position;
		}
		
		public function setBytePosition(value:uint):void
		{
			bytes.position = value;
		}
		
		/**
		 * Signed int values
		 */
		public function readS24():int
		{
			var value:int = bytes.readUnsignedByte() | bytes.readUnsignedShort() << 8;
			if(value >> 23 == 1)
			{
				value = 0xFF000000 | value; 
			}
			return int(value);
		}
		public function writeS24(value:int):void
		{
			bytes.writeByte(value & 0xFF);
			bytes.writeShort((value >> 8) & 0xFFFF);
		}
		
		public function readS32():int
		{
			return int(readEncodedU32());
		}
		public function writeS32(value:int):void
		{
			writeEncodedU32(uint(value));
		}
		
		/**
		 * Unsigned int values
		 */
		public function readU8():uint
		{
			return bytes.readUnsignedByte();
		}
		public function writeU8(value:uint):void
		{
			bytes.writeByte(value);
		}
		
		public function readU16():uint
		{
			return bytes.readUnsignedShort();
		}
		public function writeU16(value:uint):void
		{
			return bytes.writeShort(value);
		}
		
		public function readU30():uint
		{
			return readEncodedU32() & filter30;
		}
		public function writeU30(value:uint):void
		{
			writeEncodedU32(value & filter30);
		}
		
		public function readU32():uint
		{
			return readEncodedU32();
		}
		public function writeU32(value:uint):void
		{
			writeEncodedU32(value);
		}
		
		private function readEncodedU32():uint
		{
			var result:uint;
			var bytesRead:uint;
			var currentByte:uint;
			var shouldContinue:Boolean = true;
			while(shouldContinue && bytesRead < 5)
			{
				currentByte = bytes.readUnsignedByte();
				result = ((currentByte & filter7) << (7 * bytesRead)) | result;
				shouldContinue = ((currentByte >> 7) == 1);
				bytesRead++;
			}
			return result;
		}
		private function writeEncodedU32(value:uint):void
		{
			var remaining:uint = value;
			var bytesWritten:uint;
			var currentByte:uint;
			var shouldContinue:Boolean = true;
			while(shouldContinue && bytesWritten < 5)
			{
				currentByte = remaining & filter7;
				remaining = remaining >> 7;
				if(remaining > 0)
				{
					currentByte = currentByte | (1 << 7);
				}
				bytes.writeByte(currentByte);
				shouldContinue = remaining > 0;
				bytesWritten++;
			}
		}
		
		/**
		 * Floating point values
		 */
		public function readD64():Number
		{
			return bytes.readDouble();
		}
		public function writeD64(value:Number):void
		{
			bytes.writeDouble(value);
		}
		
		public function readString(length:uint):String
		{
			return bytes.readUTFBytes(length);
		}
		public function writeString(value:String):void
		{
			bytes.writeUTFBytes(value);
		}
		
		public function readBytes(byteArray:ByteArray, offset:uint, length:uint):void
		{
			bytes.readBytes(byteArray, offset, length);
		}
		public function writeBytes(byteArray:ByteArray, offset:uint, length:uint):void
		{
			bytes.writeBytes(byteArray, offset, length);
		}
	}
}