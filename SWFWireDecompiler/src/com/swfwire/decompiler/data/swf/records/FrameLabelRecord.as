package com.swfwire.decompiler.data.swf.records
{
	public class FrameLabelRecord
	{
		public var frameNum:uint;
		public var frameLabel:String;
		
		public function FrameLabelRecord(frameNum:uint = 0, frameLabel:String = '')
		{
			this.frameNum = frameNum;
			this.frameLabel = frameLabel;
		}
	}
}