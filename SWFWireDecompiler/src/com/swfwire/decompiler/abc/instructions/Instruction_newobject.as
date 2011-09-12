package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_newobject implements IInstruction
	{
		public var argCount:uint;
		
		public function Instruction_newobject(argCount:uint = 0)
		{
			this.argCount = argCount;
		}
	}
}