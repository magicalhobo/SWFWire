package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.data.swf.records.IRecord;
	import com.swfwire.decompiler.data.swf3.records.FillStyleRecord2;

	public class FillStyleArrayRecord3 implements IRecord
	{
		public var count:uint;
		public var countExtended:uint;
		public var fillStyles:Vector.<FillStyleRecord2>;
	}
}