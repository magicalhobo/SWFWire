package com.swfwire.decompiler.data.swf.records
{
	public class ClipActionsRecord
	{
		public var reserved:uint;
		public var allEventFlags:ClipEventFlagsRecord;
		public var clipActionRecords:Vector.<ClipActionRecord>;

		public function ClipActionsRecord(reserved:uint = 0, allEventFlags:ClipEventFlagsRecord = null, clipActionRecords:Vector.<ClipActionRecord> = null)
		{
			if(allEventFlags == null)
			{
				allEventFlags = new ClipEventFlagsRecord();
			}
			if(clipActionRecords == null)
			{
				clipActionRecords = new Vector.<ClipActionRecord>();
			}

			this.reserved = reserved;
			this.allEventFlags = allEventFlags;
			this.clipActionRecords = clipActionRecords;
		}
	}
}