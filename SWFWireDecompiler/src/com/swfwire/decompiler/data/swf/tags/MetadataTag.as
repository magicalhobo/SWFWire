package com.swfwire.decompiler.data.swf.tags
{
	public class MetadataTag extends SWFTag
	{
		public var metadata:String;

		public function MetadataTag(metadata:String = '')
		{
			this.metadata = metadata;
		}
	}
}