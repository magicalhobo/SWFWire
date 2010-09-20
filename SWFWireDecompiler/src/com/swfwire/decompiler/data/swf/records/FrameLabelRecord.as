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
		public function read(swf:SWFByteArray):void
		{
			frameNum = swf.readEncodedUI32();
			frameLabel = swf.readString();
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUI32(frameNum);
			swf.writeString(frameLabel);
		}
	}
}