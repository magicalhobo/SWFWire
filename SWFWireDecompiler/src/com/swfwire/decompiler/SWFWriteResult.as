package com.swfwire.decompiler
{
	import com.swfwire.decompiler.abc.ABCWriterMetadata;
	
	import flash.utils.ByteArray;

	public class SWFWriteResult
	{
		public var warnings:Vector.<String> = new Vector.<String>;
		public var errors:Vector.<String> = new Vector.<String>;
		public var bytes:ByteArray;
		public var tagMetadata:Array = [];
		public var abcMetadata:Vector.<ABCWriterMetadata> = new Vector.<ABCWriterMetadata>;
	}
}