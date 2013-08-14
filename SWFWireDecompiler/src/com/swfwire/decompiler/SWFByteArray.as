package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.*;
	import com.swfwire.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Adds the ability to read and write core SWF data types to standard ByteArray.
	 * Abbreviations from the SWF spec:
	 * 	SI = Signed Integer
	 * 	UI = Unsigned Integer
	 * 	SB = Snsigned Bits
	 * 	UB = Unsigned Bits
	 */
	public class SWFByteArray
	{
		private static const filter5:uint = ~0 >>> -5;
		private static const filter7:uint = ~0 >>> -7;
		private static const filter8:uint = ~0 >>> -8;
		private static const filter10:uint = ~0 >>> -10;
		private static const filter13:uint = ~0 >>> -13;
		private static const filter16:uint = ~0 >>> -16;
		private static const filter23:uint = ~0 >>> -23;
		
		private static const tempByteArray:ByteArray = new ByteArray();
		
		/**
		 * Returns the number of bits required to hold <code>number</code> in a UB
		 */
		public static function calculateUBBits(number:uint):uint
		{
			if(number == 0) return 0;
			var bits:uint = 0;
			while(number >>>= 1) bits++;
			return bits + 1;
		}
		
		/**
		 * Returns the number of bits required to hold <code>number</code> in an SB
		 */
		public static function calculateSBBits(number:int):uint
		{
			return number == 0 ? 1 : calculateUBBits(number < 0 ? ~number : number) + 1;
		}
		
		/**
		 * Returns the number of bits required to hold <code>number</code> in an FB
		 */
		public static function calculateFBBits(number:Number):uint
		{
			var integer:int = Math.floor(number);
			var decimal:uint = (Math.round(Math.abs(number - integer) * 0xFFFF)) & filter16;

			var sbVersion:int = ((integer & filter16) << 16) | (decimal);
			
			return number == 0 ? 1 : calculateSBBits(sbVersion);
		}
		
		private static function float32AsUnsignedInt(value:Number):uint
		{
			tempByteArray.position = 0;
			tempByteArray.writeFloat(value);
			tempByteArray.position = 0;
			return tempByteArray.readUnsignedInt();
		}
		
		private static function unsignedIntAsFloat32(value:uint):Number
		{
			tempByteArray.position = 0;
			tempByteArray.writeUnsignedInt(value);
			tempByteArray.position = 0;
			return tempByteArray.readFloat();
		}
		
		public function SWFByteArray(bytes:ByteArray)
		{
			this.bytes = bytes;
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 0;
		}
		
		private var bytes:ByteArray;
		private var bitPosition:uint = 0;
		
		/**
		 * Move forward to the next byte boundary
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
		
		public function setLength(newLength:uint):void
		{
			bytes.length = newLength;
		}
		
		public function compress():void
		{
			bytes.compress();
		}
		
		public function decompress():void
		{
			bytes.uncompress();
		}
		
		public function clear():void
		{
			bitPosition = 0;
			bytes.clear();
		}
		
		public function dump():void
		{
			var offset:uint = bytes.position;
			ByteArrayUtil.dumpHex(bytes);
			bytes.position = offset;
		}
		
		/**
		 * Reads a UI8[] into a ByteArray
		 */
		public function readBytes(byteArray:ByteArray, offset:uint = 0, length:uint = 0):void
		{
			alignBytes();
			bytes.readBytes(byteArray, offset, length);
		}
		/**
		 * Writes a UI8[] into a ByteArray
		 */
		public function writeBytes(byteArray:ByteArray, offset:uint = 0, length:uint = 0):void
		{
			alignBytes();
			bytes.writeBytes(byteArray, offset, length);
		}
		
		/**
		 * Shortcut for reading UB[1]
		 */
		public function readFlag():Boolean
		{
			return readUB(1) == 1;
		}
		/**
		 * Shortcut for writing UB[1]
		 */
		public function writeFlag(value:Boolean):void
		{
			writeUB(1, value ? 1 : 0);
		}
		
		/*
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
		public function writeSI16(value:int):void
		{
			alignBytes();
			bytes.writeShort(value);
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
		
		/*
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
		
		/*
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
		
		/*
		 * Floating point numbers
		 */
		public function readFloat16():Number
		{
			var raw:uint = readUI16();
			
			var sign:uint = raw >> 15;
			var exp:int = (raw >> 10) & filter5;
			var sig:int = raw & filter10;
			
			//Handle infinity/NaN
			if(exp == 31)
			{
				exp = 255;
			}
			//Handle normalized values
			else if(exp == 0)
			{
				exp = 0;
				sig = 0;
			}
			else
			{
				exp += 111;
			}
			
			var temp:uint = sign << 31 | exp << 23 | sig << 13;
			
			return unsignedIntAsFloat32(temp);
		}
		public function writeFloat16(value:Number):void
		{
			var raw:uint = float32AsUnsignedInt(value);

			var sign:uint = raw >> 31;
			var exp:int = (raw >> 23) & filter8;
			var sig:uint = (raw >> 13) & filter10;
			
			//Handle NaN
			if(exp == 255)
			{
				exp = 31;
			}
			//Handle underflow
			else if(exp < 111)
			{
				exp = 0;
				sig = 0;
			}
			//Handle overflow
			else if(exp > 141)
			{
				exp = 31;
				sig = 0;
			}
			else
			{
				exp -= 111;
			}
			
			writeUI16(sign << 15 | exp << 10 | sig);
		}
		public function readFloat():Number
		{
			return bytes.readFloat();
		}
		public function writeFloat(value:Number):void
		{
			bytes.writeFloat(value);
		}
		public function readDouble():Number
		{
			return bytes.readDouble();
		}
		public function writeDouble(value:Number):void
		{
			bytes.writeDouble(value);
		}
		
		/*
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
		public function writeEncodedUI32(value:uint):void
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

		/*
		 * Bit values
		 */
		public function readUB(length:uint):uint
		{
			if(!length) return 0;
			
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
			result = result & (~0 >>> -length);
			
			bitPosition = newBitPosition;
			if(bitPosition > 0)
			{
				bytes.position--;
			}
			return result;
		}
		public function writeUB(length:uint, value:uint):void
		{
			if(!length) return;
			
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
			result = result | (value & (~0 >>> -length));
			var excessBits:uint = (totalBytes * 8 - (bitPosition + length));
			
			if(excessBits > 0)
			{
				result = result << excessBits;
				result = result | (existing & (~0 >>> -excessBits));
			}
			
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
		
		public function readSB(length:uint):int
		{
			if(!length) return 0;
			
			var result:int = readUB(length);
			var leadingDigit:uint = result >>> (length - 1);
			if(leadingDigit == 1)
			{
				return -((~result & (~0 >>> -length)) + 1);
			}
			return result;
		}
		public function writeSB(length:uint, value:int):void
		{
			if(!length) return;
			
			if(value < 0)
			{
				writeUB(length, ~Math.abs(value) + 1);
			}
			else
			{
				writeUB(1, 0);
				writeUB(length - 1, value);
			}
		}

		public function readFB(length:uint):Number
		{
			if(!length) return 0;
			
			var raw:int = readSB(length);
			
			var integer:int = raw >> 16;
			var decimal:Number = (raw & filter16)/0xFFFF; 
			
			return integer + decimal;
		}
		public function writeFB(length:uint, value:Number):void
		{
			if(!length) return;
			
			var integer:int = Math.floor(value);
			var decimal:uint = (Math.round(Math.abs(value - integer) * 0xFFFF)) & filter16;
			
			var raw:int = (integer << 16) | decimal;
			
			writeSB(length, raw);
		}
		
		/*
		 * String values
		 */
		public function readString():String
		{
			alignBytes();
			var byteCount:uint = 1;
			while(bytes.readUnsignedByte())
			{
				byteCount++;
			}
			bytes.position -= byteCount;
			var result:String = bytes.readUTFBytes(byteCount);
			return result;
		}
		public function writeString(value:String):void
		{
			alignBytes();
			bytes.writeUTFBytes(value);
			bytes.writeByte(0);
		}
		
		public function readStringWithLength(length:uint):String
		{
			alignBytes();
			return bytes.readUTFBytes(length);
		}
		public function writeStringWithLength(value:String, length:uint):void
		{
			alignBytes();
			value = value.substr(0, length);
			bytes.writeUTFBytes(value);
		}
		public function unreadBytes(length:uint):void
		{
			alignBytes();
			if (length >= bytes.position)
			{
				bytes.position = 0;
				return;
			}
			bytes.position -= length;
		}
	}
}
