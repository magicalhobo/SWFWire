package com.swfwire.decompiler.data.swf6.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.ActionRecord;
	
	public class DoInitActionTag extends SWFTag
	{
		public var spriteId:uint;
		public var actions:Vector.<ActionRecord>;
	}
}