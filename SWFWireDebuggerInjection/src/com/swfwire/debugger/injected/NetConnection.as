package com.swfwire.debugger.injected
{
	import com.swfwire.debugger.injected.events.DynamicEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	public class NetConnection extends flash.net.NetConnection
	{
		public static var globalEvents:EventDispatcher = new EventDispatcher();
		
		private static const CONNECTING:String = 'connecting';
		private static const CONNECTED:String = 'connected';
		private static const DISCONNECTED:String = 'disconnected';
		
		private function netStatusHandler(ev:NetStatusEvent):void
		{
			var previousState:String = state;
			state = connected ? CONNECTED : DISCONNECTED;
			
			if(previousState != state)
			{
				if(previousState == CONNECTING)
				{
					if(state == CONNECTED)
					{
						globalEvents.dispatchEvent(new DynamicEvent('connected', {instance: this}));
					}
					else
					{
						globalEvents.dispatchEvent(new DynamicEvent('rejected', {instance: this}));
					}
				}
				else if(previousState == CONNECTED)
				{
					globalEvents.dispatchEvent(new DynamicEvent('disconnected', {instance: this}));
				}
			}
			previousConnected = connected;
		}
		
		private var previousConnected:Boolean;
		private var state:String;
		
		public function NetConnection():void
		{
			addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			super();
		}
		
		override public function connect(command:String, ...parameters):void
		{
			globalEvents.dispatchEvent(new DynamicEvent('connect', {instance: this, command: command, parameters: parameters}));
			var args:Array = parameters.slice();
			args.unshift(command);
			state = CONNECTING;
			super.connect.apply(this, args);
		}
	}
}