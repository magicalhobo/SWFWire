package com.swfwire.debugger.injected
{
	import flash.display.Stage;

	public class SWFWire_Stage
	{
		private static var _swfWireStage:SWFWire_Stage;
		
		public static function set stage(value:Stage):void
		{
			_swfWireStage = new SWFWire_Stage(value);
		}
		
		public static function getInstance():SWFWire_Stage
		{
			return _swfWireStage;
		}
		
		private var _stage:Stage;
		private var _swfWire_loaderInfo:SWFWire_LoaderInfo;
		
		public function SWFWire_Stage(stage:Stage)
		{
			_stage = stage;
			_swfWire_loaderInfo = new SWFWire_LoaderInfo(stage.loaderInfo);
		}
		
		public function get align():String { return _stage.align; }
		public function set align(value:String):void { _stage.align = value; }
		
		public function get scaleMode():String { return _stage.scaleMode; }
		public function set scaleMode(value:String):void { _stage.scaleMode = value; }
		
		public function get stage():SWFWire_Stage
		{
			return _swfWireStage;
		}
		
		public function get stageWidth():int
		{
			return _stage.stageWidth;
		}
		
		public function get stageHeight():int
		{
			return _stage.stageHeight;
		}
		
		public function get swfWire_loaderInfo():SWFWire_LoaderInfo
		{
			return _swfWire_loaderInfo;
		}
	}
}