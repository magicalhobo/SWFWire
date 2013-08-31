package com.swfwire.decompiler.data.swf8.records
{
	import com.swfwire.decompiler.data.swf6.records.IVideoPacketRecord;
	
	import flash.utils.ByteArray;

	public class VP6SWFAlphaVideoPacketRecord implements IVideoPacketRecord
	{
		public var alphaData:ByteArray;
		public var data:ByteArray;
		
		public function VP6SWFAlphaVideoPacketRecord(alphaData:ByteArray = null, data:ByteArray = null)
		{
			if(!alphaData)
			{
				alphaData = new ByteArray();
			}
			if(!data)
			{
				data = new ByteArray();
			}
			
			this.alphaData = alphaData;
			this.data = data;
		}
	}
}