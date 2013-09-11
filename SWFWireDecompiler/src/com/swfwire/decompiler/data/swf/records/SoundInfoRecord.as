package com.swfwire.decompiler.data.swf.records
{
	public class SoundInfoRecord
	{
		public var reserved:uint;
		public var syncStop:Boolean;
		public var syncNoMultiple:Boolean;
		public var hasEnvelope:Boolean;
		public var hasLoops:Boolean;
		public var hasOutPoint:Boolean;
		public var hasInPoint:Boolean;
		public var inPoint:uint;
		public var outPoint:uint;
		public var loopCount:uint;
		public var envPoints:uint;
		public var envelopeRecords:Vector.<SoundEnvelopeRecord>;
		
		public function SoundInfoRecord(reserved:uint = 0, syncStop:Boolean = false, syncNoMultiple:Boolean = false, hasEnvelope:Boolean = false, hasLoops:Boolean = false, hasOutPoint:Boolean = false, hasInPoint:Boolean = false, inPoint:uint = 0, outPoint:uint = 0, loopCount:uint = 0, envPoints:uint = 0, envelopeRecords:Vector.<SoundEnvelopeRecord> = null)
		{
			if(envelopeRecords == null)
			{
				envelopeRecords = new Vector.<SoundEnvelopeRecord>;
			}
			
			this.reserved = reserved;
			this.syncStop = syncStop;
			this.syncNoMultiple = syncNoMultiple;
			this.hasEnvelope = hasEnvelope;
			this.hasLoops = hasLoops;
			this.hasOutPoint = hasOutPoint;
			this.hasInPoint = hasInPoint;
			this.inPoint = inPoint;
			this.outPoint = outPoint;
			this.loopCount = loopCount;
			this.envPoints = envPoints;
			this.envelopeRecords = envelopeRecords;
		}
	}
}