package com.swfwire.debugger.injected
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public class Loader extends flash.display.Loader
	{
		public static var globalEvents:EventDispatcher = new EventDispatcher();
		public static var overrideApplicationDomain:ApplicationDomain;
		
		override public function load(request:URLRequest, context:LoaderContext = null):void
		{
			trace('Loader.load("'+request.url+'")');
			var ul:URLLoader = new URLLoader(request);
			ul.dataFormat = URLLoaderDataFormat.BINARY;
			ul.addEventListener(Event.COMPLETE, function(ev:Event):void
			{
				ul.removeEventListener(Event.COMPLETE, arguments.callee);
				loadBytes(ul.data, context);
				ul = null;
			});
			ul.load(request);
		}
		
		override public function loadBytes(bytes:ByteArray, context:LoaderContext = null):void
		{
			if(!context)
			{
				context = new LoaderContext();
			}
			
			context.allowCodeImport = true;
			context.applicationDomain = overrideApplicationDomain;
			context.checkPolicyFile = false;
			context.securityDomain = null;
			
			super.loadBytes(bytes, context);
		}
	}
}