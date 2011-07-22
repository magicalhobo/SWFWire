package com.swfwire.decompiler.data.swf.records
{
	public class LineStyleArrayRecord implements IRecord
	{
		public var count:uint;
		public var countExtended:uint;
		public var lineStyles:Vector.<LineStyleRecord>;

		public function LineStyleArrayRecord(count:uint = 0, countExtended:uint = 0, lineStyles:Vector.<LineStyleRecord> = null)
		{
			if(lineStyles == null)
			{
				lineStyles = new Vector.<LineStyleRecord>();
			}

			this.count = count;
			this.countExtended = countExtended;
			this.lineStyles = lineStyles;
		}
	}
}