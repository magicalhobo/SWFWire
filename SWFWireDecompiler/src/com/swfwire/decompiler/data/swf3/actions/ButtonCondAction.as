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
		
		public function ButtonCondAction(condActionSize:uint = 0, condIdleToOverDown:Boolean = false, condOutDownToldle:Boolean = false, condOutDownToOverDown:Boolean = false, 
										 condOverDownToOutDown:Boolean = false, condOverDownToOverUp:Boolean = false, condOverUpToOverDown:Boolean = false, condOverUpToIdle:Boolean = false, 
										 condIdleToOverUp:Boolean = false, condKeyPress:uint = 0, condOverDownToIdle:Boolean = false, actions:Vector.<ActionRecord> = null)
		{
			if(!actions)
			{
				actions = new Vector.<ActionRecord>();
			}
			
			this.condActionSize = condActionSize;
			this.condIdleToOverDown = condIdleToOverDown;
			this.condOutDownToldle = condOutDownToldle;
			this.condOutDownToOverDown = condOutDownToOverDown;
			this.condOverDownToOutDown = condOverDownToOutDown;
			this.condOverDownToOverUp = condOverDownToOverUp;
			this.condOverUpToOverDown = condOverUpToOverDown;
			this.condOverUpToIdle = condOverUpToIdle;
			this.condIdleToOverUp = condIdleToOverUp;
			this.condKeyPress = condKeyPress;
			this.condOverDownToIdle = condOverDownToIdle;
			this.actions = actions;
		}
	}
}