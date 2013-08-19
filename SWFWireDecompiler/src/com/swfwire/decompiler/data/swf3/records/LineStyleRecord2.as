package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.data.swf.records.RGBARecord;

	public class LineStyleRecord2
	{
		public var width:uint;
		public var color:RGBARecord;
		
		public function LineStyleRecord2(width:uint = 0, color:RGBARecord = null)
		{
			if(color == null)
			{
				color = new RGBARecord();
			}
			
			this.width = width;
			this.color = color;
		}
	}
}