package com.swfwire.decompiler.data.swf.tags
{
	import flash.utils.ByteArray;
	
	public class SoundStreamBlockTag extends SWFTag
	{
		public var data:ByteArray;
		
		public function SoundStreamBlockTag(data:ByteArray = null)
		{
			if(!data)
			{
				data = new ByteArray();
			}
			
			this.data = data;
		}
	}
}