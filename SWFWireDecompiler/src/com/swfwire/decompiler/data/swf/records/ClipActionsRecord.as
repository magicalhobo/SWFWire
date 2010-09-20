package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;

	public class ClipActionsRecord implements IRecord
	{
		public var reserved:uint;
		public var allEventFlags:ClipEventFlagsRecord;
		public var clipActionRecords:Vector.<ClipActionRecord>;
		
		public function read(swf:SWFByteArray):void
		{
			//reserved
			swf.readUI16();
			allEventFlags = new ClipEventFlagsRecord();
			allEventFlags.read(swf);
			
			clipActionRecords = new Vector.<ClipActionRecord>();
			var originalPosition:uint;
			while(true)
			{
				originalPosition = swf.getBytePosition();
				if(swf.readUI32() == 0)
				{
					break;
				}
				var clipActionRecord:ClipActionRecord = new ClipActionRecord();
				clipActionRecord.read(swf);
				clipActionRecords.push(clipActionRecord);
			}
		}
		public function write(swf:SWFByteArray):void
		{
			throw new Error('Not implemented');
		}
	}
}