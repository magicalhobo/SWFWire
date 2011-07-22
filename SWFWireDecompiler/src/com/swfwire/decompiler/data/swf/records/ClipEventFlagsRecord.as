package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class ClipEventFlagsRecord implements IRecord
	{
		public var keyUp:Boolean;
		public var keyDown:Boolean;
		public var mouseUp:Boolean;
		public var mouseDown:Boolean;
		public var mouseMove:Boolean;
		public var unload:Boolean;
		public var enterFrame:Boolean;
		public var load:Boolean;
		public var dragOver:Boolean;
		public var rollOut:Boolean;
		public var rollOver:Boolean;
		public var releaseOutside:Boolean;
		public var release:Boolean;
		public var press:Boolean;
		public var initialize:Boolean;
		public var data:Boolean;
		public var construct:Boolean;
		public var keyPress:Boolean;
		public var dragOut:Boolean;

		public function ClipEventFlagsRecord(keyUp:Boolean = false, keyDown:Boolean = false, mouseUp:Boolean = false, mouseDown:Boolean = false, mouseMove:Boolean = false, unload:Boolean = false, enterFrame:Boolean = false, load:Boolean = false, dragOver:Boolean = false, rollOut:Boolean = false, rollOver:Boolean = false, releaseOutside:Boolean = false, release:Boolean = false, press:Boolean = false, initialize:Boolean = false, data:Boolean = false, construct:Boolean = false, keyPress:Boolean = false, dragOut:Boolean = false)
		{
			this.keyUp = keyUp;
			this.keyDown = keyDown;
			this.mouseUp = mouseUp;
			this.mouseDown = mouseDown;
			this.mouseMove = mouseMove;
			this.unload = unload;
			this.enterFrame = enterFrame;
			this.load = load;
			this.dragOver = dragOver;
			this.rollOut = rollOut;
			this.rollOver = rollOver;
			this.releaseOutside = releaseOutside;
			this.release = release;
			this.press = press;
			this.initialize = initialize;
			this.data = data;
			this.construct = construct;
			this.keyPress = keyPress;
			this.dragOut = dragOut;
		}
	}
}