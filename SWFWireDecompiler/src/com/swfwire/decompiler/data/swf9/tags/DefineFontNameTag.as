package com.swfwire.decompiler.data.swf9.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	public class DefineFontNameTag extends SWFTag
	{
		public var fontId:uint;
		public var fontName:String;
		public var fontCopyright:String;
	}
}