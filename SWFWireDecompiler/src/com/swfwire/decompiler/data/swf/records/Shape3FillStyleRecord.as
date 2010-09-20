package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class Shape3FillStyleRecord extends FillStyleRecord
	{
		override public function read(swf:SWFByteArray):void
		{
			super.read(swf);

			switch(type)
			{
				default:
					super.read(swf);
					break;
			}
		}
	}
}