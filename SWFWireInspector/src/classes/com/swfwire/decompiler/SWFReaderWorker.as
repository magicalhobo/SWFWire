package com.swfwire.decompiler
{
	import com.swfwire.inspector.debug;
	import com.swfwire.utils.Debug;
	
	import flash.display.Sprite;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class SWFReaderWorker extends Sprite
	{
		public function SWFReaderWorker()
		{
			Serializable.registerAll();
			
			debug = new Debug(true, 'SWFReaderWorker');
			
			var inChannel:MessageChannel = Worker.current.getSharedProperty('inChannel');
			var outChannel:MessageChannel = Worker.current.getSharedProperty('outChannel');
			
			var bytes:ByteArray = inChannel.receive(true);
			
			debug.log('SWFReaderWorker', '', {bytesReceived: bytes.length});
			
			var swfBytes:SWFByteArray = new SWFByteArray(bytes);
			var swfReader:SWFReader = new SWF10Reader();
			
			var start:int = getTimer();
			
			var result:SWFReadResult = swfReader.read(swfBytes);
	
			debug.log('SWFReaderWorker', 'done reading', {time: getTimer() - start});
			
			outChannel.send({type: 'result', data: {result: result}});
		}
	}
}