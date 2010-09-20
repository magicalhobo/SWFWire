package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf3.records.ActionRecord;
	
	public class ClipActionRecord implements IRecord
	{
		public var eventFlags:ClipEventFlagsRecord;
		public var actionRecordSize:uint;
		public var keyCode:uint;
		public var actions:Vector.<ActionRecord>;
		
		public function read(swf:SWFByteArray):void
		{
			eventFlags = new ClipEventFlagsRecord();
			eventFlags.read(swf);
			actionRecordSize = swf.readUI32();
			if(eventFlags.keyPress)
			{
				keyCode = swf.readUI8();
			}
			actions = new Vector.<ActionRecord>();
			var originalPosition:uint;
			while(true)
			{
				originalPosition = swf.getBytePosition();
				if(swf.readUI8() == 0)
				{
					break;
				}
				swf.setBytePosition(originalPosition);
				var actionRecord:ActionRecord = new ActionRecord();
				actionRecord.read(swf);
				actions.push(actionRecord);
			}
		}
		
		public function write(swf:SWFByteArray):void
		{
			throw new Error('Not implemented');
		}
	}
}