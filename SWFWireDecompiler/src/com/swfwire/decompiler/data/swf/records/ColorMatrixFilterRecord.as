package com.swfwire.decompiler.data.swf.records
{
	public class ColorMatrixFilterRecord implements IFilterRecord
	{
		public var matrix:Vector.<Number>;
		
		public function get filterId():uint
		{
			return 6;
		}

		public function ColorMatrixFilterRecord(matrix:Vector.<Number> = null)
		{
			if(matrix == null)
			{
				matrix = new Vector.<Number>();
			}

			this.matrix = matrix;
		}
	}
}