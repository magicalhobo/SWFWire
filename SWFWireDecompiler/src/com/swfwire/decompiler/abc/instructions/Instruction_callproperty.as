package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_callproperty implements IInstruction
	{
		public var index:uint;
		public var argCount:uint;
		
		public function Instruction_callproperty(index:uint = 0, argCount:uint = 0)
		{
			this.index = index;
			this.argCount = argCount;
		}
	}
}