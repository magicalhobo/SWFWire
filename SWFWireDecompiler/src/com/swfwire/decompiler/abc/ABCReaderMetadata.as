package com.swfwire.decompiler.abc
{
	import flash.utils.Dictionary;

	public class ABCReaderMetadata
	{
		public var offsetFromId:Object;
		public var idFromOffset:Object;
		public var tokens:Dictionary;
		
		public function ABCReaderMetadata()
		{
			offsetFromId = {};
			idFromOffset = {};
			tokens = new Dictionary(true);
		}
	}
}