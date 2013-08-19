package com.swfwire.decompiler.data.swf3.records
{
	import flash.utils.ByteArray;

	public class ActionRecord
	{
		public var actionCode:uint;
		public var length:uint;
		//TODO: IActionRecord
		public var action:ByteArray;
	}
}