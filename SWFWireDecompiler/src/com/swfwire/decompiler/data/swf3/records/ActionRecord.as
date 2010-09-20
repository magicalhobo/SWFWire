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
		
		public function read(swf:SWFByteArray):void
		{
			actionCode = swf.readUI8();
			if(actionCode >= 0x80)
			{
				length = swf.readUI16();
			}
			else
			{
				length = 0;
			}
			action = new ByteArray();
			if(length > 0)
			{
				swf.readBytes(action, 0, length);
			}
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI8(actionCode);
			if(actionCode >= 0x80)
			{
				swf.writeUI16(length);
			}
			if(length > 0)
			{
				swf.writeBytes(action, 0, length);
			}
		}
	}
}