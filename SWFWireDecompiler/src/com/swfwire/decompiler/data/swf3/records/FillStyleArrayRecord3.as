package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.data.swf.records.IRecord;
	import com.swfwire.decompiler.data.swf3.records.FillStyleRecord2;

	public class FillStyleArrayRecord3 implements IRecord
	{
		public var fillStyles:Vector.<FillStyleRecord2>;

		public function FillStyleArrayRecord3(count:uint = 0, countExtended:uint = 0, fillStyles:Vector.<FillStyleRecord2> = null)
		{
			this.fillStyles = fillStyles;
		}
	}
}