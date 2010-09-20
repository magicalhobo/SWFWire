package com.swfwire.decompiler.data.swf
{
	import com.swfwire.decompiler.data.swf.records.RectangleRecord;

	public class SWFHeader
	{
		public static const UNCOMPRESSED_SIGNATURE:String = 'FWS';
		public static const COMPRESSED_SIGNATURE:String = 'CWS';
		
		public var signature:String;
		public var fileVersion:uint;
		public var uncompressedSize:uint;
		
		public var frameSize:RectangleRecord;
		public var frameRate:Number;
		public var frameCount:uint;
	}
}