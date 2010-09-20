package com.swfwire.decompiler.data.swf2.records
{
	import com.swfwire.decompiler.data.swf.records.FillStyleRecord;
	import com.swfwire.decompiler.data.swf.records.IRecord;

	public class FillStyleArrayRecord2 implements IRecord
	{
		public var count:uint;
		public var countExtended:uint;
		public var fillStyles:Vector.<FillStyleRecord>;
	}
}