package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.IRecord;
	
	import flash.utils.ByteArray;

	public class ActionRecord implements IRecord
	{
		public var actionCode:uint;
		public var length:uint;
		//TODO: IActionRecord
		public var action:ByteArray;
	}
}