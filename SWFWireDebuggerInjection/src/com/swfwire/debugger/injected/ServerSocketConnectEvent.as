package com.swfwire.debugger.injected
{
	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	
	public class ServerSocketConnectEvent extends Event
	{
		public var socket:Socket;
		
		public function ServerSocketConnectEvent(source:flash.events.ServerSocketConnectEvent)
		{
			super(source.type, source.bubbles, source.cancelable);
			//this.socket = source.socket;
		}
	}
}