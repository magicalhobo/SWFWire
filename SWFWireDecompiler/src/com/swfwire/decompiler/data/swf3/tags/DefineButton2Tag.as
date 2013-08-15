package com.swfwire.decompiler.data.swf3.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.actions.ButtonCondAction;
	import com.swfwire.decompiler.data.swf3.records.ButtonRecord2;
	
	import mx.controls.Button;
	
	public class DefineButton2Tag extends SWFTag
	{
		public var buttonId:uint;
		public var reserved:uint;
		public var trackAsMenu:Boolean;
		public var actionOffset:uint;
		public var characters:Vector.<ButtonRecord2>;
		public var actions:Vector.<ButtonCondAction>;
	}
}