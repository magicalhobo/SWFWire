package com.swfwire.debugger.events
{
	import flash.events.Event;

	public class AsyncSWFModifierEvent extends Event
	{
		public static const RUN:String = 'run';
		public static const COMPLETE:String = 'complete';
		
		public var progress:Number;
		
		public function AsyncSWFModifierEvent(type:String, progress:Number)
		{
			super(type);
			
			this.progress = progress;
		}
	}
}