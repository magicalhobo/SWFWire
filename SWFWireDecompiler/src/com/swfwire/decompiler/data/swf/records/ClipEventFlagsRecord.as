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
		
		public function read(swf:SWFByteArray):void
		{
			keyUp = swf.readFlag();
			keyDown = swf.readFlag();
			mouseUp = swf.readFlag();
			mouseDown = swf.readFlag();
			mouseMove = swf.readFlag();
			unload = swf.readFlag();
			enterFrame = swf.readFlag();
			load = swf.readFlag();
			dragOver = swf.readFlag();
			rollOut = swf.readFlag();
			rollOver = swf.readFlag();
			releaseOutside = swf.readFlag();
			release = swf.readFlag();
			press = swf.readFlag();
			initialize = swf.readFlag();
			data = swf.readFlag();
			construct = swf.readFlag();
			keyPress = swf.readFlag();
			dragOut = swf.readFlag();
		}
		
		public function write(swf:SWFByteArray):void
		{
			swf.writeUB(1, keyUp ? 1 : 0);
			swf.writeUB(1, keyDown ? 1 : 0);
			swf.writeUB(1, mouseUp ? 1 : 0);
			swf.writeUB(1, mouseDown ? 1 : 0);
			swf.writeUB(1, mouseMove ? 1 : 0);
			swf.writeUB(1, unload ? 1 : 0);
			swf.writeUB(1, enterFrame ? 1 : 0);
			swf.writeUB(1, load ? 1 : 0);
			swf.writeUB(1, dragOver ? 1 : 0);
			swf.writeUB(1, rollOut ? 1 : 0);
			swf.writeUB(1, rollOver ? 1 : 0);
			swf.writeUB(1, releaseOutside ? 1 : 0);
			swf.writeUB(1, release ? 1 : 0);
			swf.writeUB(1, press ? 1 : 0);
			swf.writeUB(1, initialize ? 1 : 0);
			swf.writeUB(1, data ? 1 : 0);
			swf.writeUB(1, construct ? 1 : 0);
			swf.writeUB(1, keyPress ? 1 : 0);
			swf.writeUB(1, dragOut ? 1 : 0);
		}
	}
}