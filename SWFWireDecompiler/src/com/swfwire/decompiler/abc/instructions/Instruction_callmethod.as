package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_callmethod implements IInstruction
	{
		public var index:uint;
		public var argCount:uint;

		public function Instruction_callmethod(index:uint = 0, argCount:uint = 0)
		{
			this.index = index;
			this.argCount = argCount;
		}
	}
}