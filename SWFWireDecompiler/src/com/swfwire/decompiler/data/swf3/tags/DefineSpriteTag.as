package com.swfwire.decompiler.data.swf3.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	public class DefineSpriteTag extends SWFTag
	{
		public var spriteId:uint;
		public var frameCount:uint;
		public var controlTags:Vector.<SWFTag>;
	}
}