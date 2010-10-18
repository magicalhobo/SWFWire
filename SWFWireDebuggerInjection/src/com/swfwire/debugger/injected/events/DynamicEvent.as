package com.swfwire.debugger.injected.events
{
	import flash.events.Event;
	
	public dynamic class DynamicEvent extends Event
	{
		public function DynamicEvent(type:String, properties:Object)
		{
			for(var iter:String in properties)
			{
				this[iter] = properties[iter];
			}
			super(type);
		}
	}
}