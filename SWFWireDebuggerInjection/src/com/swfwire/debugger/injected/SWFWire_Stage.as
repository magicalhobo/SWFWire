package com.swfwire.debugger.injected
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class SWFWire_Stage implements IEventDispatcher
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
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			return _stage.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return _stage.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return _stage.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			return _stage.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return _stage.willTrigger(type);
		}
	}
}