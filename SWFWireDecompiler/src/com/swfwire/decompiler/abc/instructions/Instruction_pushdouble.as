package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_pushdouble extends BaseInstruction
	{
		public var index:uint;

		public function Instruction_pushdouble(index:uint = 0)
		{
			this.index = index;
		}
	}
}