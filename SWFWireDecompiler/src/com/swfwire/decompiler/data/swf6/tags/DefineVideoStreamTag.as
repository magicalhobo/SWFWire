package com.swfwire.decompiler.data.swf6.tags
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	public class DefineVideoStreamTag extends SWFTag
	{
		public var characterId:uint;
		public var numFrames:uint;
		public var width:uint;
		public var height:uint;
		public var videoFlagsDeblocking:uint;
		public var videoFlagsSmoothing:Boolean;
		public var codecId:uint;
	}
}