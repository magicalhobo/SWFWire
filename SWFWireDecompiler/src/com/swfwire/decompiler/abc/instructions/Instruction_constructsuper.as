package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_constructsuper implements IInstruction
	{
		public var argCount:uint;

		public function Instruction_constructsuper(argCount:uint = 0)
		{
			this.argCount = argCount;
		}
	}
}