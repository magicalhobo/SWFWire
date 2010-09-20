package com.swfwire.decompiler
{
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.data.swf.SWF;
	
	import flash.utils.ByteArray;

	public class SWFReadResult
	{
		public var warnings:Vector.<String> = new Vector.<String>;
		public var errors:Vector.<String> = new Vector.<String>;
		public var swf:SWF;
		public var tagMetadata:Array = [];
		public var abcMetadata:Vector.<ABCReaderMetadata> = new Vector.<ABCReaderMetadata>;
	}
}