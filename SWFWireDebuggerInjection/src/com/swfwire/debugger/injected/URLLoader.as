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
	import flash.utils.Dictionary;
	
	public class URLLoader extends flash.net.URLLoader
	{
		public static var globalEvents:EventDispatcher = new EventDispatcher();
		public static var applicationRoot:String = '';
		
		private static var urlMap:Dictionary = new Dictionary(true);
		
		private static function openHandler(ev:Event):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(ev.type, {url: urlMap[ev.currentTarget]}));
		}
		
		private static function progressHandler(ev:ProgressEvent):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(ev.type, {url: urlMap[ev.currentTarget], bytesLoaded: ev.bytesLoaded, bytesTotal: ev.bytesTotal}));
		}
		
		private static function completeHandler(ev:Event):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(ev.type, {url: urlMap[ev.currentTarget]}));
		}
		
		private static function errorHandler(ev:Event):void
		{
			globalEvents.dispatchEvent(new DynamicEvent(ev.type, {url: urlMap[ev.currentTarget]}));
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
			urlMap[this] = request.url;
			
			if(request.url.indexOf('://') == -1)
			{
				if(request.url.substr(0, 5) == 'app:/')
				{
					request.url = request.url.substr(5);
				}
				request.url = applicationRoot + request.url;
			}
			//request.url = 'http://localhost/proxy?url='+encodeURIComponent(request.url);
			super.load(request);
		}
	}
}