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
	
	/**
	 * Writes SWF tags asynchronously, so a progress bar can be displayed.
	 */
	public class AsyncSWFWriter extends SWF13Writer
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
		protected var _currentPointer:int;
		protected var _currentSWF:SWF;
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
			_currentContext = new SWFWriterContext(null, swf.header.fileVersion, _currentWriteResult);
			_currentSWF = swf;
			_currentPointer = 0;
			
			if(swf.header.fileVersion > version)
			{
				_currentWriteResult.warnings.push('Invalid file version ('+swf.header.fileVersion+') in header.');
			}
			
			var tagCount:uint = swf.tags.length;
			_currentContext.tagBytes = new Vector.<ByteArray>(tagCount, true);
			
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
			if(_currentPointer >= _currentSWF.tags.length)
			{
				_currentWriteResult.warnings.push('Expected end tag.');
				finishAsync();
			}
			else
			{
				var tag:SWFTag = _currentSWF.tags[_currentPointer];
				
				var bytes:ByteArray = new ByteArray();
				
				try
				{
					_currentContext.tagId = _currentPointer;
					_currentContext.bytes = new SWFByteArray(bytes);
					writeTag(_currentContext, tag);
					tag.header.length = bytes.length;
				}
				catch(e:Error)
				{
					_currentWriteResult.errors.push('Could not write Tag #'+_currentPointer+': '+e);
				}
				
				_currentContext.tagBytes[_currentPointer] = bytes;
				
				_currentPointer++;
				
				dispatchEvent(new AsyncSWFWriterEvent(AsyncSWFWriterEvent.TAG_WRITTEN, _currentContext, _currentWriteResult, _currentPointer/_currentSWF.tags.length));

				if(tag is EndTag)
				{
					finishAsync();
				}
			}
		}
				
		protected function finishAsync():void
		{
			_active = false;
			
			var tagBytes:Vector.<ByteArray> = _currentContext.tagBytes;
			
			var rawBytes:ByteArray = new ByteArray();
			var bytes:SWFByteArray = new SWFByteArray(rawBytes);
			_currentContext.bytes = bytes;
			
			writeSWFHeader(_currentContext, _currentSWF.header);
			
			var iter:int;
			var tagCount:uint = _currentContext.tagBytes.length;
			
			for(iter = 0; iter < tagCount; iter++)
			{
				bytes.alignBytes();
				var header:TagHeaderRecord = _currentSWF.tags[iter].header;
				writeTagHeaderRecord(_currentContext, header);
				bytes.writeBytes(tagBytes[iter]);
			}
			
			var length:uint = bytes.getLength();
			
			compress(_currentSWF.header, bytes);
			
			bytes.setBytePosition(4);
			bytes.writeUI32(length);
			
			bytes.setBytePosition(0);
			
			_currentWriteResult.bytes = rawBytes;
			
			dispatchEvent(new AsyncSWFWriterEvent(AsyncSWFWriterEvent.WRITE_COMPLETE, _currentContext, _currentWriteResult, 1));
		}
	}
}