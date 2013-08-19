package com.swfwire.decompiler.data.swf.records
{
	public class FilterListRecord
	{
		public var filters:Vector.<FilterRecord>;

		public function FilterListRecord(filters:Vector.<FilterRecord> = null)
		{
			if(filters == null)
			{
				filters = new Vector.<FilterRecord>();
			}

			this.filters = filters;
		}
	}
}