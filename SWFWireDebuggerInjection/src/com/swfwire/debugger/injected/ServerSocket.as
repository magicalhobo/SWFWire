package com.swfwire.debugger.injected
{
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	
	public class ServerSocket extends flash.net.ServerSocket
	{
		public function ServerSocket()
		{
			addEventListener(flash.events.ServerSocketConnectEvent.CONNECT, connectHandler, false, int.MAX_VALUE);
		}
		private function connectHandler(ev:flash.events.ServerSocketConnectEvent):void
		{
			var event:com.swfwire.debugger.injected.ServerSocketConnectEvent = new com.swfwire.debugger.injected.ServerSocketConnectEvent(ev);
			dispatchEvent(event);
		}
		override public function bind(localPort:int=0, localAddress:String="0.0.0.0"):void
		{
			trace('Binding to '+localAddress+':'+localPort);
			super.bind(localPort, localAddress);
		}
		override public function listen(backlog:int=0):void
		{
			trace('Listening');
			super.listen(backlog);
		}
	}
}