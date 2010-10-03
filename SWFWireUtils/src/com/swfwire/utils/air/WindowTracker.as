package com.swfwire.utils.air
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	
	public class WindowTracker
	{
		private var sharedObject:SharedObject;
		private var nativeWindow:NativeWindow;
		private var boundsProperty:String;
		private var stateProperty:String;
		
		public function WindowTracker(sharedObject:SharedObject, nativeWindow:NativeWindow, boundsProperty:String = 'windowBounds', stateProperty:String = 'windowState')
		{
			this.sharedObject = sharedObject;
			this.nativeWindow = nativeWindow;
			this.boundsProperty = boundsProperty;
			this.stateProperty = stateProperty;
		}
		
		private function moveHandler(ev:NativeWindowBoundsEvent):void
		{
			if(nativeWindow.displayState == NativeWindowDisplayState.NORMAL)
			{
				sharedObject.data[boundsProperty] = nativeWindow.bounds;
			}
			sharedObject.flush();
		}
		
		private function displayStateChangeHandler(ev:NativeWindowDisplayStateEvent):void
		{
			sharedObject.data[stateProperty] = nativeWindow.displayState;
			sharedObject.flush();
		}
		
		public function startTracking():void
		{
			nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeHandler);
			nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, moveHandler);
			nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, moveHandler);
		}
		
		public function stopTracking():void
		{
			nativeWindow.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeHandler);
			nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVE, moveHandler);
			nativeWindow.removeEventListener(NativeWindowBoundsEvent.RESIZE, moveHandler);
		}
		
		public function restore():void
		{
			var bounds:Object = sharedObject.data[boundsProperty];
			if(bounds && bounds.x && bounds.y && bounds.width && bounds.height)
			{
				nativeWindow.bounds = new Rectangle(bounds.x, bounds.y, bounds.width, bounds.height);
			}
			else
			{
				delete sharedObject.data[boundsProperty];
				sharedObject.flush();
			}
			var state:Object = sharedObject.data[stateProperty];
			if(state is String)
			{
				switch(state)
				{
					case NativeWindowDisplayState.MAXIMIZED:
						nativeWindow.maximize();
						break;
				}
			}
			else
			{
				delete sharedObject.data[stateProperty];
				sharedObject.flush();
			}
		}
	}
}