package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.*;
	import com.swfwire.decompiler.events.AsyncSWFReaderEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	[Event(type="com.swfwire.decompiler.events.AsyncSWFReaderEvent", name="tagRead")]
	[Event(type="com.swfwire.decompiler.events.AsyncSWFReaderEvent", name="readComplete")]
	
	/**
	 * Reads SWF tags asynchronously, so a progress bar can be displayed.
	 */
	public class AsyncSWFReader extends SWF10Reader
	{
		public function get active():Boolean
		{
			return _active;
		}
		public function get currentContext():SWFReaderContext
		{
			return _currentContext;
		}
		public function get currentReadResult():SWFReadResult
		{
			return _currentReadResult;
		}
		
		protected var _currentContext:SWFReaderContext;
		protected var _currentReadResult:SWFReadResult;
		
		protected var readTimer:Timer;
		
		private var _active:Boolean;
		private var lastRead:uint;
		
		public function AsyncSWFReader()
		{
			readTimer = new Timer(1, 1);
			readTimer.addEventListener(TimerEvent.TIMER, readTimerHandler);
		}
		
		override public function read(bytes:SWFByteArray):SWFReadResult 
		{
			if(_active)
			{
				return null;
			}
			
			_currentReadResult = new SWFReadResult();
			
			var swf:SWF = new SWF();
			swf.header = new SWFHeader();
			swf.tags = new Vector.<SWFTag>();
			
			_currentContext = new SWFReaderContext(bytes, 0, _currentReadResult);
			
			readSWFHeader(_currentContext, swf.header);
			
			_currentContext.fileVersion = swf.header.fileVersion;
			
			if(swf.header.fileVersion > version)
			{
				_currentReadResult.warnings.push('Invalid file version ('+swf.header.fileVersion+') in header.');
			}
			
			_currentReadResult.swf = swf;
			
			_active = true;
			
			readTimer.start();
			
			return _currentReadResult;
		}
		
		protected function readTimerHandler(ev:Event):void
		{
			lastRead = getTimer();
			do
			{
				readTagAsync();
			}
			while((getTimer() - lastRead < 200) && _active)
			if(_active)
			{
				readTimer.reset();
				readTimer.start();
			}
		}
		
		protected function readTagAsync():void
		{
			var context:SWFReaderContext = _currentContext;
			var bytes:SWFByteArray = context.bytes;
			var result:SWFReadResult = _currentReadResult;
			var swf:SWF = result.swf;
			
			if(bytes.getBytesAvailable() > 0)
			{
				var tagId:uint = swf.tags.length;
				var preHeaderStart:uint = bytes.getBytePosition();
				
				var header:TagHeaderRecord = readTagHeaderRecord(context);
				
				var startPosition:uint = context.bytes.getBytePosition();
				var expectedEndPosition:uint = startPosition + header.length;
				
				var tag:SWFTag;
				
				context.tagId = tagId;
				
				if(catchErrors)
				{
					try
					{
						tag = readTag(context, header);
					}
					catch(e:Error)
					{
						result.warnings.push('Error parsing Tag #'+tagId+': '+e);
						bytes.setBytePosition(startPosition);
						tag = readUnknownTag(context, header);
					}
				}
				else
				{
					tag = readTag(context, header);
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
				
				dispatchEvent(new AsyncSWFReaderEvent(AsyncSWFReaderEvent.TAG_READ, _currentContext, _currentReadResult));
				
				if(tag is EndTag)
				{
					finishAsync();
				}
			}
			else
			{
				result.warnings.push('Expected end tag.');
				finishAsync();
			}
		}
		
		protected function finishAsync():void
		{
			_active = false;
			dispatchEvent(new AsyncSWFReaderEvent(AsyncSWFReaderEvent.READ_COMPLETE, _currentContext, _currentReadResult));
		}
	}
}