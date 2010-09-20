package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_pushuint extends BaseInstruction
	{
		public var index:uint;
		
		public function Instruction_pushuint(index:uint = 0)
		{
			this.index = index;
		}
	}
}