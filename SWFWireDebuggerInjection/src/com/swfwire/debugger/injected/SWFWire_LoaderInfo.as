package com.swfwire.debugger.injected
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;

	public class SWFWire_LoaderInfo implements IEventDispatcher
	{
		public static var defaultParameters:Object = {};
		
		public var parameters:Object;
		
		private var loaderInfo:LoaderInfo;
		
		public function SWFWire_LoaderInfo(loaderInfo:LoaderInfo)
		{
			this.parameters = defaultParameters;
			this.loaderInfo = loaderInfo;
		}
		
		public function get childAllowsParent():Boolean { return loaderInfo.childAllowsParent; }
		public function get parentAllowsChild():Boolean { return loaderInfo.parentAllowsChild; }
		public function get url():String { return loaderInfo.url; }
		public function get width():int { return loaderInfo.width; }
		public function get height():int { return loaderInfo.height; }
		public function get applicationDomain():ApplicationDomain { return loaderInfo.applicationDomain; }
		public function get bytesLoaded():uint { return loaderInfo.bytesLoaded; }
		public function get bytesTotal():uint { return loaderInfo.bytesLoaded; }
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			return loaderInfo.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return loaderInfo.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean
		{
			return loaderInfo.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			return loaderInfo.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return loaderInfo.willTrigger(type);
		}
	}
}