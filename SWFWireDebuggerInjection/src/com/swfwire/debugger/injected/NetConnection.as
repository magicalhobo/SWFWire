package com.swfwire.debugger.injected
{
	import com.swfwire.debugger.injected.events.DynamicEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	
	public class NetConnection extends flash.net.NetConnection
	{
		public static var globalEvents:EventDispatcher = new EventDispatcher();
		
		public function NetConnection()
		{
			super();
		}
		
		override public function connect(command:String, ...parameters):void
		{
			globalEvents.dispatchEvent(new DynamicEvent('connect', {command: command, parameters: parameters}));
			super.connect(command, parameters);
		}
	}
}