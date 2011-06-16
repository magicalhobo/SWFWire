package com.swfwire.debugger.ui
{
	import com.swfwire.utils.DisplayUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public class PreviewWindow extends NativeWindow
	{
		public var loader:Loader;
		public var content:Sprite;
		public var overlay:Shape;
		
		private var previewStartDown:Point;
		private var overlayGraphics:Graphics;
		
		public function PreviewWindow(owner:NativeWindow)
		{
			var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			
			super(initOptions);
			
			content = new Sprite();
			overlay = new Shape();
			
			overlayGraphics = overlay.graphics;
			
			stage.addChild(content);
			stage.addChild(overlay);
			
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, previewMiddleDownHandler, true, int.MAX_VALUE, true);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, previewMiddleScrollHandler, true, int.MAX_VALUE, true);
		}
		
		private function loaderCompleteHandler(ev:Event):void
		{
			resetSWFPosition();
			
			dispatchEvent(new Event('loaderComplete'));
		}
		
		private function previewMiddleDownHandler(ev:MouseEvent):void
		{
			loader.mouseEnabled = false;
			loader.mouseChildren = false;
			stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, previewMiddleUpHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, previewMoveHandler, false, 0, true);
			previewStartDown = new Point(stage.mouseX - loader.x, stage.mouseY - loader.y);
		}
		
		private function previewMoveHandler(ev:MouseEvent):void
		{
			if(previewStartDown)
			{
				loader.x = stage.mouseX - previewStartDown.x; 
				loader.y = stage.mouseY - previewStartDown.y; 
			}
		}
		
		private function previewMiddleUpHandler(ev:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, previewMoveHandler);
			stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, previewMiddleUpHandler);
			loader.mouseChildren = true;
			loader.mouseEnabled = true;
		}
		
		private function previewMiddleScrollHandler(ev:MouseEvent):void
		{
			ev.stopImmediatePropagation();
			
			var scaleFactor:Number = Math.pow(1.05, ev.delta);
			
			var mouseNow:Point = new Point(loader.mouseX, loader.mouseY);
			var previousMousePosition:Point = loader.localToGlobal(mouseNow);
			
			loader.scaleX *= scaleFactor;
			loader.scaleY *= scaleFactor;
			
			var newMousePosition:Point = loader.localToGlobal(mouseNow);
			
			loader.x -= newMousePosition.x - previousMousePosition.x;
			loader.y -= newMousePosition.y - previousMousePosition.y;
		}
		
		public function loadBytes(bytes:ByteArray, context:LoaderContext):void
		{
			if(loader)
			{
				loader.unloadAndStop();
			}
			else
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.INIT, loaderCompleteHandler, false, 0, true);
				content.addChild(loader);
			}
			loader.loadBytes(bytes, context);
		}
		
		public function unload():void
		{
			if(loader)
			{
				loader.unloadAndStop();
				loader = null;
			}
		}
		
		public function setSWFBackground(color:uint):void
		{
			//setStyle('backgroundColor', color);
		}
		
		public function setSWFSize(width:Number, height:Number):void
		{
			this.width = width;
			this.height = height;
		}
		
		public function resetSWFPosition():void
		{
			loader.scaleX = 1;
			loader.scaleY = 1;
			
			loader.x = 0
			loader.y = 0
		}
		
		public function highlight(target:DisplayObject, clear:Boolean = true):void
		{
			if(clear)
			{
				overlayGraphics.clear();
			}
			if(target)
			{
				overlayGraphics.lineStyle(4, 0x00FF00, 0.5);
				var bounds:Rectangle = target.getRect(overlay);
				overlayGraphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
			}
		}
	}
}