package com.swfwire.debugger.injected
{
	import flash.display.Sprite;
	
	public class Sprite extends flash.display.Sprite
	{
		public var swfWire_loaderInfo:SWFWire_LoaderInfo;
		
		public function Sprite()
		{
			swfWire_loaderInfo = new SWFWire_LoaderInfo(loaderInfo);
			
			super();
		}
	}
}