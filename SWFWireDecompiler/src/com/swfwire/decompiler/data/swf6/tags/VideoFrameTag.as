package com.swfwire.decompiler.data.swf6.tags
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf6.records.IVideoPacketRecord;
	
	public class VideoFrameTag extends SWFTag
	{
		public var streamId:uint;
		public var frameNum:uint;
		public var videoData:IVideoPacketRecord;
		
		public function VideoFrameTag(streamId:uint = 0, frameNum:uint = 0, videoData:IVideoPacketRecord = null)
		{
			this.streamId = streamId;
			this.frameNum = frameNum;
			this.videoData = videoData;
		}
	}
}