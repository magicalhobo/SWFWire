package com.swfwire.decompiler.data.swf.records
{
	public class FilterListRecord
	{
		public var numberOfFilters:uint;
		public var filters:Vector.<FilterRecord>;

		public function FilterListRecord(numberOfFilters:uint = 0, filters:Vector.<FilterRecord> = null)
		{
			if(filters == null)
			{
				filters = new Vector.<FilterRecord>();
			}

			this.numberOfFilters = numberOfFilters;
			this.filters = filters;
		}
	}
}