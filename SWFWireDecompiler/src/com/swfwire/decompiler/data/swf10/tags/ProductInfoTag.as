package com.swfwire.decompiler.data.swf10.tags
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class ProductInfoTag extends SWFTag
	{
		public var product:uint;
		public var edition:uint;
		public var majorVersion:uint;
		public var minorVersion:uint;
		public var buildLow:uint;
		public var buildHigh:uint;
		public var compileDateLow:uint;
		public var compileDateHigh:uint;
	}
}