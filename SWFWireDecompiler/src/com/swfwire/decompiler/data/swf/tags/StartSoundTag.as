package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.records.SoundInfoRecord;

	public class StartSoundTag extends SWFTag
	{
		public var soundId:uint;
		public var soundInfo:SoundInfoRecord;
		
		public function StartSoundTag(soundId:uint = 0, soundInfo:SoundInfoRecord = null)
		{
			this.soundId = soundId;
			this.soundInfo = soundInfo;
		}
	}
}