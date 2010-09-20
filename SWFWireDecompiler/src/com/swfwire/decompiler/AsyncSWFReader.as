package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	public class AsyncSWFReader extends SWF10Reader
	{
		public var eventDispatcher:EventDispatcher;
		
		protected var currentContext:SWFReaderContext;
		protected var currentReadResult:SWFReadResult;
		
		protected var readTimer:Timer;
		
		private var active:Boolean;
		private var lastRead:uint;
		
		public function AsyncSWFReader()
		{
			eventDispatcher = new EventDispatcher();
			readTimer = new Timer(1, 1);
			readTimer.addEventListener(TimerEvent.TIMER, readTimerHandler);
		}
		
		override public function readFile(bytes:SWFByteArray):SWFReadResult 
		{
			currentReadResult = new SWFReadResult();
			
			var swf:SWF = new SWF();
			swf.header = new SWFHeader();
			swf.tags = new Vector.<SWFTag>();
			
			currentContext = new SWFReaderContext(bytes, 0, currentReadResult);
			
			readSWFHeader(currentContext, swf.header);
			
			currentContext.fileVersion = swf.header.fileVersion;
			
			if(swf.header.fileVersion > version)
			{
				currentReadResult.warnings.push('Invalid file version ('+swf.header.fileVersion+') in header.');
			}
			
			currentReadResult.swf = swf;
			
			active = true;
			
			readTimer.start();
			
			return currentReadResult;
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
			var result:SWFReadResult = currentReadResult;
			var swf:SWF = currentReadResult.swf;
			
			if(bytes.getBytesAvailable() == 0)
			{
				result.warnings.push('Expected end tag.');
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
				
				context.tagId = tagId;
				
				tag = readTag(context, header);
				/*
				try
				{
					tag = readTag(context, header);
				}
				catch(e:Error)
				{
					bytes.setBytePosition(startPosition);
					tag = readUnknownTag(context, header);
				}
				*/
				
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
		
		protected function finishAsync():void
		{
			active = false;
			eventDispatcher.dispatchEvent(new Event('done'));
		}
	}
}