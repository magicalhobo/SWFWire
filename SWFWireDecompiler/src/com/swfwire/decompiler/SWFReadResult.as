package com.swfwire.decompiler
{
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.data.swf.SWF;
	
	public class SWFReadResult
	{
		public var swf:SWF;
		public var tagMetadata:Vector.<SWFReaderTagMetadata> = new Vector.<SWFReaderTagMetadata>();
		public var abcMetadata:Vector.<ABCReaderMetadata> = new Vector.<ABCReaderMetadata>;
		public var warnings:Vector.<String> = new Vector.<String>;
		public var errors:Vector.<String> = new Vector.<String>;
	}
}