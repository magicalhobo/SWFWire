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

		public function ClipActionRecord(eventFlags:ClipEventFlagsRecord = null, actionRecordSize:uint = 0, keyCode:uint = 0, actions:Vector.<ActionRecord> = null)
		{
			if(eventFlags == null)
			{
				eventFlags = new ClipEventFlagsRecord();
			}
			if(actions == null)
			{
				actions = new Vector.<ActionRecord>();
			}

			this.eventFlags = eventFlags;
			this.actionRecordSize = actionRecordSize;
			this.keyCode = keyCode;
			this.actions = actions;
		}
	}
}