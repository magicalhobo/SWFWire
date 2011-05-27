package com.swfwire.debugger.injected
{
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	public class URLStream extends flash.net.URLStream
	{
		override public function load(request:URLRequest):void
		{
			trace('URLStream.load("'+request.url+'")');
			super.load(request);
		}
	}
}