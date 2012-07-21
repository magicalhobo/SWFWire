package com.swfwire.decompiler
{
	public class SWFReaderTagMetadata
	{
		public var name:String;
		public var start:int;
		public var length:int;
		public var contentStart:int;
		public var contentLength:int;
		
		public function SWFReaderTagMetadata(name:String = '', start:int = -1, length:int = -1, contentStart:int = -1, contentLength:int = -1)
		{
			this.name = name;
			this.start = start;
			this.length = length;
			this.contentStart = contentStart;
			this.contentLength = contentLength;
		}
	}
}