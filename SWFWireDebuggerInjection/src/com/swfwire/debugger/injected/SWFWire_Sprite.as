package com.swfwire.debugger.injected
{
	import flash.display.Sprite;
	
	public class SWFWire_Sprite extends flash.display.Sprite
	{
		private var _swfWire_loaderInfo:SWFWire_LoaderInfo;
		private var _swfWire_stage:SWFWire_Stage;
		
		public function SWFWire_Sprite()
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