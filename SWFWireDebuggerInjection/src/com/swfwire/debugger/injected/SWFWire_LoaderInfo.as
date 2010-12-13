package com.swfwire.debugger.injected
{
	import flash.display.LoaderInfo;

	public class SWFWire_LoaderInfo
	{
		public static var defaultParameters:Object = {};
		
		public var parameters:Object;
		
		private var loaderInfo:LoaderInfo;
		
		public function SWFWire_LoaderInfo(loaderInfo:LoaderInfo)
		{
			this.parameters = defaultParameters;
			this.loaderInfo = loaderInfo;
		}
	}
}