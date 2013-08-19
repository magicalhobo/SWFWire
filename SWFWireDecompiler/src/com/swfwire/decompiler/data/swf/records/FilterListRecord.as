package com.swfwire.decompiler.data.swf.records
{
	public class FilterListRecord
	{
		public var filters:Vector.<IFilterRecord>;

		public function FilterListRecord(filters:Vector.<IFilterRecord> = null)
		{
			if(filters == null)
			{
				filters = new Vector.<IFilterRecord>();
			}

			this.filters = filters;
		}
	}
}