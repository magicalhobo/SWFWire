package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.*;
	import com.swfwire.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import com.swfwire.utils.ByteArrayUtil;
	
	public class SWFByteArray
	{
		private static const filter7:uint = (1 << 7) - 1;
		private static const filter8:uint = (1 << 8) - 1;
		
		private var bytes:ByteArray;
		private var bitPosition:uint = 0;
		
		public function SWFByteArray(bytes:ByteArray)
		{
			this.bytes = bytes;
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 0;
		}
		
		/**
		 * Integers must be aligned to bytes
		 */
		public function alignBytes():void
		{
			if(bitPosition != 0)
			{
				bytes.position++;
				bitPosition = 0;
			}
		}
		
		public function getBytePosition():uint
		{
			return bytes.position;
		}
		
		public function setBytePosition(newPosition:uint):void
		{
			bitPosition = 0;
			bytes.position = newPosition;
		}
		
		public function getBitPosition():uint
		{
			return bitPosition;
		}
		
		public function setBitPosition(newPosition:uint):void
		{
			bitPosition = newPosition;
		}
		
		public function getBytesAvailable():uint
		{
			return bytes.bytesAvailable;
		}
		
		public function getLength():uint
		{
			return bytes.length;
		}
		
		public function clear():void
		{
			bitPosition = 0;
			bytes.clear();
		}
		
		public function decompress():void
		{
			bytes.uncompress();
		}
		
		public function dump():void
		{
			var offset:uint = bytes.position;
			ByteArrayUtil.dumpHex(bytes);
			bytes.position = offset;
		}
		
		/**
		 * Not in the spec, but needed to read ABCData from the DoABC tag, and image data from the JPEG tag
		 */
		public function readBytes(byteArray:ByteArray, offset:uint = 0, length:uint = 0):void
		{
			alignBytes();
			bytes.readBytes(byteArray, offset, length);
		}
		public function writeBytes(byteArray:ByteArray, offset:uint = 0, length:uint = 0):void
		{
			alignBytes();
			bytes.writeBytes(byteArray, offset, length);
		}
		
		/**
		 * Not in the spec, but easier than repeating every time there's a UB[1]
		 */
		public function readFlag():Boolean
		{
			return readUB(1) == 1;
		}
		public function writeFlag(value:Boolean):void
		{
			writeUB(1, value ? 1 : 0);
		}
		
		/**
		 * Signed int values
		 */
		public function readSI8():int
		{
			alignBytes();
			return bytes.readByte();
		}
		public function readSI16():int
		{
			alignBytes();
			return bytes.readShort();
		}
		public function readSI32():int
		{
			alignBytes();
			return bytes.readInt();
		}
		public function writeSI32(value:int):void
		{
			alignBytes();
			return bytes.writeInt(value);
		}
		public function readSI8Array(length:uint):Vector.<int>
		{
			var result:Vector.<int> = new Vector.<int>(length, true);
			for(var iter:uint = 0; iter < length; iter++)
			{
				result[iter] = readSI8();
			}
			return result;
		}
		public function readSI16Array(length:uint):Vector.<int>
		{
			var result:Vector.<int> = new Vector.<int>(length, true);
			for(var iter:uint = 0; iter < length; iter++)
			{
				result[iter] = readSI16();
			}
			return result;
		}
		
		/**
		 * Unsigned int values
		 */
		public function readUI8():uint
		{
			alignBytes();
			return bytes.readUnsignedByte();
		}
		public function writeUI8(value:uint):void
		{
			alignBytes();
			bytes.writeByte(int(value));
		}
		
		public function readUI16():uint
		{
			alignBytes();
			return bytes.readUnsignedShort();
		}
		public function writeUI16(value:uint):void
		{
			alignBytes();
			return bytes.writeShort(int(value));
		}
		
		public function readUI32():uint
		{
			alignBytes();
			return bytes.readUnsignedInt();
		}
		public function writeUI32(value:uint):void
		{
			alignBytes();
			return bytes.writeUnsignedInt(value);
		}
		
		public function readUI8Array(length:uint):Vector.<uint>
		{
			var result:Vector.<uint> = new Vector.<uint>(length, true);
			for(var iter:uint = 0; iter < length; iter++)
			{
				result[iter] = readUI8();
			}
			return result;
		}
		public function readUI16Array(length:uint):Vector.<uint>
		{
			var result:Vector.<uint> = new Vector.<uint>(length, true);
			for(var iter:uint = 0; iter < length; iter++)
			{
				result[iter] = readUI16();
			}
			return result;
		}
		public function readUI24Array(length:uint):Vector.<uint>
		{
			alignBytes();
			var result:Vector.<uint> = new Vector.<uint>(length, true);
			for(var iter:uint = 0; iter < length; iter++)
			{
				result[iter] = bytes.readUnsignedShort() << 8 | bytes.readUnsignedByte();
			}
			return result;
		}
		public function readUI32Array(length:uint):Vector.<uint>
		{
			var result:Vector.<uint> = new Vector.<uint>(length, true);
			for(var iter:uint = 0; iter < length; iter++)
			{
				result[iter] = readUI32();
			}
			return result;
		}
		
		/**
		 * Fixed point numbers
		 */
		public function readFixed8_8():Number
		{
			alignBytes();
			var decimal:uint = bytes.readUnsignedByte();
			var result:Number = bytes.readByte();
			
			result += decimal / 0xFF;
			
			return result;
		}
		public function writeFixed8_8(value:Number):void
		{
			alignBytes();
			
			var integer:uint = int(value);
			var decimal:uint = uint((value - integer) * 0xFF);
			
			bytes.writeByte(int(decimal));
			bytes.writeByte(int(integer));
		}
		public function readFixed16_16():Number
		{
			alignBytes();
			var decimal:uint = bytes.readUnsignedShort();
			var result:Number = bytes.readShort();
			
			result += decimal / 0xFFFF;
			
			return result;
		}
		
		/**
		 * Floating point numbers
		 * TODO: implement this
		 */
		public function readFloat16():Number
		{
			alignBytes();
			var sign:uint = readUB(1);
			var exponent:uint = readUB(5);
			var mantissa:uint = readUB(10);
			return 0;
		}
		public function readFloat():Number
		{
			return bytes.readFloat();
		}
		public function readDouble():Number
		{
			return bytes.readDouble();
		}
		
		/**
		 * Encoded integers
		 */
		public function readEncodedUI32():uint
		{
			alignBytes();
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
		
		/**
		 * Bit values
		 */
		public function readSB(length:uint):int
		{
			return int(readUB(length));
		}
		public function writeSB(length:uint, value:int):void
		{
			writeUB(length, uint(value));
		}
		public function readUB(length:uint):uint
		{
			var totalBytes:uint = Math.ceil((bitPosition + length) / 8);
			
			var iter:uint = 0;
			var currentByte:uint = 0;
			var result:uint = 0;
			
			while(iter < totalBytes)
			{
				currentByte = bytes.readUnsignedByte();
				result = (result << 8) | currentByte;
				iter++;
			}
			
			var newBitPosition:uint = ((bitPosition + length) % 8);
			
			var excessBits:uint = (totalBytes * 8 - (bitPosition + length));
			result = result >> excessBits;
			result = result & ((1 << length) - 1);
			
			bitPosition = newBitPosition;
			if(bitPosition > 0)
			{
				bytes.position--;
			}
			return result;
		}
		public function writeUB(length:uint, value:uint):void
		{
			var totalBytes:uint = Math.ceil((bitPosition + length) / 8);
			var iter:int = 0;
			var currentByte:uint = 0;
			var existing:uint = 0;
			var startPosition:uint = bytes.position;
			
			while(iter < totalBytes)
			{
				currentByte = bytes.bytesAvailable >= 1 ? bytes.readUnsignedByte() : 0;
				existing = (existing << 8) | currentByte;
				iter++;
			}
			
			var newBitPosition:uint = ((bitPosition + length) % 8);
			
			var result:uint;
			result = existing >> (totalBytes * 8 - bitPosition);
			result = result << length;
			result = result | (value & ((1 << length) - 1));
			var excessBits:uint = (totalBytes * 8 - (bitPosition + length));
			result = result << excessBits;
			result = result | (existing & ((1 << excessBits) - 1));
			
			bytes.position = startPosition;
			
			iter = totalBytes - 1;
			while(iter >= 0)
			{
				bytes.position = startPosition + iter;
				currentByte = result & filter8;
				result = result >> 8;
				bytes.writeByte(int(currentByte));
				iter--;
			}
			
			bytes.position = startPosition + totalBytes;
			bitPosition = newBitPosition;
			if(bitPosition > 0)
			{
				bytes.position--;
			}
		}
		public function readFB(length:uint):Number
		{
			//TODO: do some magic
			return readUB(length);
		}
		public function writeFB(length:uint, value:Number):void
		{
			writeSB(length, int(value));
		}
		
		/**
		 * String values
		 */
		public function readString():String
		{
			alignBytes();
			var result:String = '';
			while(true)
			{
				var character:String = bytes.readUTFBytes(1);
				if(character)
				{
					result += character;
				}
				else
				{
					break;
				}
			}
			return result;
		}
		public function readStringWithLength(length:uint):String
		{
			alignBytes();
			return bytes.readUTFBytes(length);
		}
		public function writeString(value:String):void
		{
			alignBytes();
			bytes.writeUTFBytes(value);
			bytes.writeByte(0);
		}
		public function writeStringWithLength(value:String, length:uint):void
		{
			alignBytes();
			value = value.substr(0, length);
			bytes.writeUTFBytes(value);
		}
	}
}
