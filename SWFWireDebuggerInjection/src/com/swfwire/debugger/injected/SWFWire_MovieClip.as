package com.swfwire.debugger.injected
{
	import flash.display.MovieClip;
	
	public class SWFWire_MovieClip extends flash.display.MovieClip
	{
		private var _swfWire_loaderInfo:SWFWire_LoaderInfo;
		private var _swfWire_stage:SWFWire_Stage;
		
		public function SWFWire_MovieClip()
		{
			_swfWire_loaderInfo = new SWFWire_LoaderInfo(loaderInfo);
			_swfWire_stage = SWFWire_Stage.getInstance();
			
			super();
		}
		
		public function get swfWire_loaderInfo():SWFWire_LoaderInfo
		{
			return _swfWire_loaderInfo;
		}
		
		public function get swfWire_stage():SWFWire_Stage
		{
			return _swfWire_stage;
		}
	}
}