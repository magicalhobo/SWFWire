package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.IRGBRecord;

	public class ARGBRecord implements IRGBRecord
	{
		public var alpha:uint;
		public var red:uint;
		public var green:uint;
		public var blue:uint;
	}
}