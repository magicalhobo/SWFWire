package com.swfwire.decompiler.data.swf8.tags
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class FileAttributesTag extends SWFTag
	{
		public var useDirectBlit:Boolean;
		public var useGPU:Boolean;
		public var hasMetadata:Boolean;
		public var actionScript3:Boolean;
		public var useNetwork:Boolean;

		public function FileAttributesTag(useDirectBlit:Boolean = false, useGPU:Boolean = false, hasMetadata:Boolean = false, actionScript3:Boolean = false, useNetwork:Boolean = false)
		{
			this.useDirectBlit = useDirectBlit;
			this.useGPU = useGPU;
			this.hasMetadata = hasMetadata;
			this.actionScript3 = actionScript3;
			this.useNetwork = useNetwork;
		}
	}
}