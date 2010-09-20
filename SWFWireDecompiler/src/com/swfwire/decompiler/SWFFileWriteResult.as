package com.swfwire.decompiler
{
	import flash.utils.ByteArray;

	public class SWFFileWriteResult
	{
		public var warnings:Vector.<String> = new Vector.<String>;
		public var errors:Vector.<String> = new Vector.<String>;
		public var bytes:ByteArray;
		public var tagMetadata:Array = [];
		public var abcMetadata:Array = [];
	}
}