package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.*;
	import com.swfwire.decompiler.events.AsyncSWFWriterEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	[Event(type="com.swfwire.decompiler.events.AsyncSWFWriterEvent", name="tagWritten")]
	[Event(type="com.swfwire.decompiler.events.AsyncSWFWriterEvent", name="writeComplete")]
	
	public class AsyncSWFWriter extends SWF10Writer
	{
		public function get active():Boolean
		{
			return _active;
		}
		public function get currentContext():SWFWriterContext
		{
			return _currentContext;
		}
		public function get currentWriteResult():SWFWriteResult
		{
			return _currentWriteResult;
		}
		
		protected var _currentContext:SWFWriterContext;
		protected var _currentWriteResult:SWFWriteResult;
		
		protected var writeTimer:Timer;
		
		private var _active:Boolean;
		private var lastWrite:uint;
		
		public function AsyncSWFWriter()
		{
			writeTimer = new Timer(1, 1);
			writeTimer.addEventListener(TimerEvent.TIMER, writeTimerHandler);
		}
		
		override public function write(swf:SWF):SWFWriteResult 
		{
			if(_active)
			{
				return null;
			}
			
			_currentWriteResult = new SWFWriteResult();
			
			_currentContext = new SWFWriterContext(new SWFByteArray(new ByteArray()), swf.header.fileVersion, _currentWriteResult);
			
			if(swf.header.fileVersion > version)
			{
				_currentWriteResult.warnings.push('Invalid file version ('+swf.header.fileVersion+') in header.');
			}
			
			var tagCount:uint = swf.tags.length;
			var tagBytes:Vector.<ByteArray> = new Vector.<ByteArray>();
			
			_active = true;
			
			writeTimer.start();
			
			return _currentWriteResult;
		}
		
		protected function writeTimerHandler(ev:Event):void
		{
			lastWrite = getTimer();
			do
			{
				writeTagAsync();
			}
			while((getTimer() - lastWrite < 200) && _active)
			if(_active)
			{
				writeTimer.reset();
				writeTimer.start();
			}
		}
		
		protected function writeTagAsync():void
		{
			/*
			var iter:uint;
			for(iter = 0; iter < tagCount; iter++)
			{
			bytes.alignBytes();
			var header:TagHeaderRecord = swf.tags[iter].header;
			writeTagHeaderRecord(_currentContext, header);
			bytes.writeBytes(tagBytes[iter]);
			}
			

			var tag:SWFTag = swf.tags[iter];
			tagBytes[iter] = new ByteArray();
			try
			{
				currentContext.tagId = iter;
				currentContext.bytes = new SWFByteArray(tagBytes[iter]);
				writeTag(currentContext, tag);
				tag.header.length = tagBytes[iter].length;
			}
			catch(e:Error)
			{
				currentWriteResult.errors.push('Could not write Tag #'+iter+': '+e);
			}

			var context:SWFWriterContext = currentContext;
			var bytes:SWFByteArray = context.bytes;
			var result:SWFWriteResult = currentWriteResult;
			var swf:SWF = result.swf;
			
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
				* /
				
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
			*/
		}
				
		protected function finishAsync():void
		{
			_active = false;
			/*
			var bytes1:ByteArray = new ByteArray();
			var bytes:SWFByteArray = new SWFByteArray(bytes1);
			_currentContext.bytes = bytes;
			
			writeSWFHeader(_currentContext, swf.header);
			
			bytes.setBytePosition(0);
			_currentWriteResult.bytes = bytes1;
			

			bytes.setBytePosition(4);
			var tl:uint = bytes.getLength();
			bytes.writeUI32(tl);
			*/
			dispatchEvent(new AsyncSWFWriterEvent(AsyncSWFWriterEvent.WRITE_COMPLETE, _currentContext, _currentWriteResult));
		}
	}
}