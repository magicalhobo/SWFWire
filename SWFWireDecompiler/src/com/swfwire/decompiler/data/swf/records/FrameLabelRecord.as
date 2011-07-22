package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;

	public class FrameLabelRecord implements IRecord
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