package com.swfwire.decompiler.data.swf.tags
{
	import flash.utils.ByteArray;
	
	public class DefineSoundTag extends SWFTag
	{
		public var soundId:uint;
		public var soundFormat:uint;
		public var soundRate:uint;
		public var soundSize:uint;
		public var soundType:uint;
		public var soundSampleCount:uint;
		public var soundData:ByteArray;
		
		public function DefineSoundTag(soundId:uint = 0, soundFormat:uint = 0, soundRate:uint = 0, soundSize:uint = 0, soundType:uint = 0, soundSampleCount:uint = 0, soundData:ByteArray = null)
		{
			if(soundData == null)
			{
				soundData = new ByteArray();
			}
			
			this.soundId = soundId;
			this.soundFormat = soundFormat;
			this.soundRate = soundRate;
			this.soundSize = soundSize;
			this.soundType = soundType;
			this.soundSampleCount = soundSampleCount;
			this.soundData = soundData;
		}
	}
}