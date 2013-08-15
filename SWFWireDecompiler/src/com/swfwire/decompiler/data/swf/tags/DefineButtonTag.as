package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.ButtonRecord;
	
	public class DefineButtonTag extends SWFTag
	{
		public var buttonId:uint;
		public var characters:Vector.<ButtonRecord>;
	}
}