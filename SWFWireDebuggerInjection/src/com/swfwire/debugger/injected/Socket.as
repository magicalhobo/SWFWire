package com.swfwire.debugger.injected
{
	import com.swfwire.debugger.injected.events.DynamicEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;

	public class Socket extends flash.net.Socket
	{
		public static var globalEvents:EventDispatcher = new EventDispatcher();
		
		private var lastHost:String = '';
		private var lastPort:int = 0;
		
		public function Socket()
		{
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(Event.CLOSE, closeHandler);
		}
		
		protected function connectHandler(ev:Event):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(Event.CONNECT, {instance: this, host: lastHost, port: lastPort}));
		}
		
		protected function socketDataHandler(ev:ProgressEvent):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(ProgressEvent.SOCKET_DATA, {instance: this, host: lastHost, port: lastPort}));
		}
		
		protected function securityErrorHandler(ev:SecurityErrorEvent):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(SecurityErrorEvent.SECURITY_ERROR, {instance: this, host: lastHost, port: lastPort}));
		}
		
		protected function ioErrorHandler(ev:IOErrorEvent):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(IOErrorEvent.IO_ERROR, {instance: this, host: lastHost, port: lastPort}));
		}
		
		protected function closeHandler(ev:Event):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(Event.CLOSE, {instance: this, host: lastHost, port: lastPort}));
		}
		
		override public function connect(host:String, port:int):void
		{
			globalEvents.dispatchEvent(new DynamicEvent('swfWireConnect', {host: host, port: port}));
			lastHost = host;
			lastPort = port;
			super.connect(host, port);
		}
		
		override public function close():void
		{
			globalEvents.dispatchEvent(new DynamicEvent('swfWireClose', {instance: this, host: lastHost, port: lastPort}));
			super.close();
		}
	}
}