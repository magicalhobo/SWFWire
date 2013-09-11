package com.swfwire.decompiler.data.swf.records
{
	public class SoundEnvelopeRecord
	{
		public var pos44:uint;
		public var leftLevel:uint;
		public var rightLevel:uint;
		
		public function SoundEnvelopeRecord(pos44:uint = 0, leftLevel:uint = 0, rightLevel:uint = 0)
		{
			this.pos44 = pos44;
			this.leftLevel = leftLevel;
			this.rightLevel = rightLevel;
		}
	}
}