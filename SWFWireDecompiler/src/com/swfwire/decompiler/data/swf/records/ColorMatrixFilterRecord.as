package com.swfwire.decompiler.data.swf.records
{
	public class ColorMatrixFilterRecord
	{
		public var matrix:Vector.<Number>;

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