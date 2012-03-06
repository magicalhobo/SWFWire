package com.swfwire.debugger.injected
{
	import com.swfwire.debugger.injected.events.DynamicEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.Dictionary;
	
	public class URLLoader extends flash.net.URLLoader
	{
		public static var globalEvents:EventDispatcher = new EventDispatcher();
		public static var applicationRoot:String = '';
		public static var referer:String = '';
		
		private static var parameters:Dictionary = new Dictionary(true);
		
		private static function openHandler(ev:Event):void
		{
			var params:Object = parameters[ev.currentTarget];
			globalEvents.dispatchEvent(new DynamicEvent(ev.type, {instance: ev.currentTarget, url: params.url, data: params.data}));
		}
		
		private static function progressHandler(ev:ProgressEvent):void
		{
			var params:Object = parameters[ev.currentTarget];
			globalEvents.dispatchEvent(new DynamicEvent(ev.type, {instance: ev.currentTarget, url: params.url, data: params.data}));
		}
		
		private static function completeHandler(ev:Event):void
		{
			var params:Object = parameters[ev.currentTarget];
			globalEvents.dispatchEvent(new DynamicEvent(ev.type, {instance: ev.currentTarget, url: params.url, data: params.data}));
		}
		
		private static function errorHandler(ev:Event):void
		{
			var params:Object = parameters[ev.currentTarget];
			globalEvents.dispatchEvent(new DynamicEvent(ev.type, {instance: ev.currentTarget, url: params.url, data: params.data}));
		}
		
		public function URLLoader(request:URLRequest = null)
		{
			addEventListener(Event.OPEN, openHandler);
			addEventListener(ProgressEvent.PROGRESS, progressHandler);
			addEventListener(Event.COMPLETE, completeHandler);
			addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			
			super(request);
		}
		
		override public function load(request:URLRequest):void
		{
			parameters[this] = {url: request.url, data: request.data};
			
			if(request.url.indexOf('://') == -1)
			{
				request.url = request.url.replace(/^(\.\.\/)*/, '');
				request.url = request.url.replace(/^app:\//, '');
				request.url = applicationRoot + request.url;
			}
			
			request.data;
			
			request.requestHeaders.push(new URLRequestHeader('Referer', referer));
			
			super.load(request);
		}
		
		override public function close():void
		{
			var params:Object = parameters[this];
			globalEvents.dispatchEvent(new DynamicEvent(Event.CLOSE, {instance: this, url: params.url, data: params.data}));
			super.close();
		}
	}
}