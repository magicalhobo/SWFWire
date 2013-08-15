package com.swfwire.decompiler.data.swf3.actions
{
	import com.swfwire.decompiler.data.swf3.records.ActionRecord;

	public class ButtonCondAction
	{
		public var condActionSize:uint;
		public var condIdleToOverDown:Boolean;
		public var condOutDownToldle:Boolean;
		public var condOutDownToOverDown:Boolean;
		public var condOverDownToOutDown:Boolean;
		public var condOverDownToOverUp:Boolean;
		public var condOverUpToOverDown:Boolean;
		public var condOverUpToIdle:Boolean;
		public var condIdleToOverUp:Boolean;
		public var condKeyPress:uint;
		public var condOverDownToIdle:Boolean;
		public var actions:Vector.<ActionRecord>;
	}
}