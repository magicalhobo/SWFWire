package com.swfwire.decompiler.data.swf
{
	import com.swfwire.decompiler.data.swf.tags.*;

	public class SWF
	{
		public var header:SWFHeader;
		public var tags:Vector.<SWFTag>;
		
		public function SWF(header:SWFHeader = null, tags:Vector.<SWFTag> = null)
		{
			this.header = header;
			this.tags = tags;
		}
	}
}