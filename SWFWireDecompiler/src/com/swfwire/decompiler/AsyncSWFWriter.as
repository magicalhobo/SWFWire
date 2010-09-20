package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	public class AsyncSWFWriter extends SWF9Writer
	{
		public var eventDispatcher:EventDispatcher;
		
		protected var currentContext:SWFWriterContext;
		protected var currentWriteResult:SWFFileWriteResult;
		protected var currentBytes:ByteArray;
		
		protected var readTimer:Timer;
		
		private var active:Boolean;
		private var lastRead:uint;
		
		public function AsyncSWFWriter()
		{
			eventDispatcher = new EventDispatcher();
			readTimer = new Timer(1, 1);
			//readTimer.addEventListener(TimerEvent.TIMER, readTimerHandler);
		}
		/*
		override public function write(swf:SWF):SWFFileWriteResult 
		{
			currentWriteResult = new SWFFileWriteResult();
			
			currentWriteResult.bytes = new SWFByteArray(new ByteArray());
			
			currentContext = new SWFReaderContext(bytes, 0);
			
			readSWFHeader(currentContext, currentSWF.header);
			
			currentContext.fileVersion = currentSWF.header.fileVersion;
			
			if(currentSWF.header.fileVersion > version)
			{
				currentWriteResult.warnings.push('Invalid file version ('+currentSWF.header.fileVersion+') in header.');
			}
			
			currentWriteResult.swf = currentSWF;
			
			active = true;
			
			readTimer.start();
			
			return currentWriteResult;
		}
		
		protected function readTimerHandler(ev:Event):void
		{
			lastRead = getTimer();
			do
			{
				readTagAsync();
			}
			while((getTimer() - lastRead < 200) && active)
			if(active)
			{
				readTimer.reset();
				readTimer.start();
			}
		}
		
		protected function readTagAsync():void
		{
			var context:SWFReaderContext = currentContext;
			var bytes:SWFByteArray = context.bytes;
			var swf:SWF = currentSWF;
			var result:SWFReadResult = currentWriteResult;
			
			if(bytes.getBytesAvailable() == 0)
			{
				finishAsync();
			}
			else
			{
				var tagId:uint = swf.tags.length;
				var preHeaderStart:uint = bytes.getBytePosition();
				
				var header:TagHeaderRecord = readTagHeaderRecord(context);
				
				var startPosition:uint = context.bytes.getBytePosition();
				var expectedEndPosition:uint = startPosition + header.length;
				
				var tag:SWFTag;
				try
				{
					tag = readTag(context, header);
				}
				catch(e:Error)
				{
					bytes.setBytePosition(startPosition);
					tag = readUnknownTag(context, header);
				}
				
				tag.header = header;
				
				swf.tags.push(tag);
				context.bytes.alignBytes();
				var newPosition:uint = context.bytes.getBytePosition();
				if(newPosition > expectedEndPosition)
				{
					result.warnings.push('Read overflow for Tag #'+tagId+' (type: '+tag.header.type+').' +
						' Read '+(newPosition - startPosition)+' bytes, expected '+(tag.header.length)+' bytes.');
				}
				if(newPosition < expectedEndPosition)
				{
					result.warnings.push('Read underflow for Tag #'+tagId+' (type: '+tag.header.type+').' +
						' Read '+(newPosition - startPosition)+' bytes, expected '+(tag.header.length)+' bytes.');
				}
				bytes.setBytePosition(expectedEndPosition);
				
				result.tagMetadata[tagId] = {name: getQualifiedClassName(tag), start: preHeaderStart, length: (expectedEndPosition - preHeaderStart), contentStart: startPosition, contentLength: tag.header.length};
				
				if(tag is UnknownTag)
				{
					result.warnings.push('Unknown tag type: '+header.type+' (id: '+tagId+')');
				}
				
				eventDispatcher.dispatchEvent(new Event('tagRead'));
				
				if(tag is EndTag)
				{
					finishAsync();
				}
			}
		}
		*/
		protected function finishAsync():void
		{
			active = false;
			eventDispatcher.dispatchEvent(new Event('done'));
		}
	}
}