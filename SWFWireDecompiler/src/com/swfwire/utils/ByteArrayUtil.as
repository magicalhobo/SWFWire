package com.swfwire.utils
{
	import flash.utils.ByteArray;
	import com.swfwire.utils.StringUtil;

	public class ByteArrayUtil
	{
		public static function getUTF8Length(value:String):uint
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(value);
			return bytes.length;
		}
		public static function getNullTerminatedUTF8Length(value:String):uint
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(value);
			return bytes.length + 1;
		}
		
		public static function toBitString(value:uint, length:uint = 8):String
		{
			return '0b'+String('00000000000000000000000000000000'+value.toString(2)).substr(-length);
		}
		
		public static function toHexString(value:uint, length:uint = 32):String
		{
			return '0x'+String('00000000'+value.toString(16).toUpperCase()).substr(-length/4);
		}
		
		public static function bytesToString(bytes:ByteArray, offset:uint = 0, length:uint = 0):String
		{
			var byte:uint;
			var iter:uint = offset % 16;
			var line:String = StringUtil.repeat('∙∙ ', iter);
			var readable:String = StringUtil.repeat('∙', iter);
			var binary:String = StringUtil.repeat('∙∙∙∙∙∙∙∙ ', iter);
			
			bytes.position = offset;
			
			var startLine:uint = offset - iter;
			var maxPosition:uint = length ? offset + length : bytes.length;
			
			var result:String = '';
			
			while(bytes.position < maxPosition)
			{
				byte = bytes.readUnsignedByte();
				line += String('00'+byte.toString(16)).substr(-2).toUpperCase() + ' ';
				binary += String('00000000'+byte.toString(2)).substr(-8) + ' ';
				var char:String = byte >= 33 && byte <= 125 ? String.fromCharCode(byte) : '.';
				readable += char;
				if(iter % 16 == 15)
				{
					result += (toHexString(startLine + iter - 15)+' '+line+' '+readable+' '+binary) + '\n';
					line = readable = binary = '';
				}
				iter++;
			}
			if(iter % 16 != 0)
			{
				line = StringUtil.padEnd(line, StringUtil.repeat('∙∙ ', 16));
				readable = StringUtil.padEnd(readable, StringUtil.repeat('∙', 16));
				binary = StringUtil.padEnd(binary, StringUtil.repeat('∙∙∙∙∙∙∙∙ ', 16));
				result += toHexString(startLine + iter - (iter % 16))+' '+line+' '+readable + ' ' + binary
			}
			return result;
		}
		
		public static function dumpHex(bytes:ByteArray, offset:uint = 0, length:uint = 0):void
		{
			trace(bytesToString(bytes, offset, length));
		}
	}
}