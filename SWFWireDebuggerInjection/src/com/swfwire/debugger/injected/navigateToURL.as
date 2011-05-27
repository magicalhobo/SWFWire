package com.swfwire.debugger.injected
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public function navigateToURL(request:URLRequest, window:String = null):void
	{
		if(request && request.url.search(/^javascript\s*:/g) != -1)
		{
			trace('navigateToURL("'+request.url+'") - nop');
		}
		else
		{
			flash.net.navigateToURL(request, window);
		}
	}
}