package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_construct extends BaseInstruction
	{
		public var argCount:uint;

		public function Instruction_construct(argCount:uint = 0)
		{
			this.argCount = argCount;
		}
	}
}