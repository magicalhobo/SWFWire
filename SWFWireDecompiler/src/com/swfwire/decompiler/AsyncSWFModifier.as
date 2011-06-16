package com.swfwire.decompiler
{
	import com.swfwire.decompiler.events.AsyncSWFModifierEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	[Event(type="com.swfwire.decompiler.events.AsyncSWFModifierEvent", name="run")]
	[Event(type="com.swfwire.decompiler.events.AsyncSWFModifierEvent", name="complete")]
	
	public class AsyncSWFModifier extends EventDispatcher
	{
		public function get active():Boolean
		{
			return _active;
		}
		public function get runCount():uint
		{
			return _runCount;
		}
		
		protected var timer:Timer;
		protected var timeLimit:uint;
		private var _lastWrite:uint;
		private var _active:Boolean;
		private var _runCount:uint;
		
		public function AsyncSWFModifier(timeLimit:uint = 100)
		{
			super(this);
			
			this.timeLimit = timeLimit;
			
			timer = new Timer(1, 1);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
		}
		
		public function start():Boolean
		{
			if(!_active)
			{
				_active = true;
				_runCount = 0;
				
				timer.start();
				
				return true;
			}
		
			return false;
		}
		
		private function timerHandler(ev:TimerEvent):void
		{
			_lastWrite = getTimer();
			do
			{
				_runCount++;
				var progress:Number = run();
				if(_active)
				{
					dispatchEvent(new AsyncSWFModifierEvent(AsyncSWFModifierEvent.RUN, progress));
				}
				else
				{
					dispatchEvent(new AsyncSWFModifierEvent(AsyncSWFModifierEvent.COMPLETE, progress));
					break;
				}
			}
			while((getTimer() - _lastWrite < timeLimit))
			if(_active)
			{
				timer.reset();
				timer.start();
			}
		}
		
		protected function run():Number
		{
			finish();
			return 1;
		}
		
		protected function finish():void
		{
			timer.stop();
			_active = false;
		}
	}
}