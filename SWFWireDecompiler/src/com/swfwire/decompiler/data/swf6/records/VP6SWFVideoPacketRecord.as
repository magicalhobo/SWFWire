package com.swfwire.decompiler.data.swf6.records
{
	import flash.utils.ByteArray;

	public class VP6SWFVideoPacketRecord implements IVideoPacketRecord
	{
		public var data:ByteArray;
		
		public function VP6SWFVideoPacketRecord(data:ByteArray = null)
		{
			if(!data)
			{
				data = new ByteArray();
			}
			
			this.data = data;
		}
	}
}