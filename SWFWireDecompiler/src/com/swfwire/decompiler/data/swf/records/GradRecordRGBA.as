package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class GradRecordRGBA implements IRecord
	{
		public var ratio:uint;
		public var color:RGBARecord;
	}
}