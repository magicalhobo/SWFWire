package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_getlex implements IInstruction
	{
		public var index:uint;
		
		public function Instruction_getlex(index:uint = 0)
		{
			this.index = index;
		}
	}
}