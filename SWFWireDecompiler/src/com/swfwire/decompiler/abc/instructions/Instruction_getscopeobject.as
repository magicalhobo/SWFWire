package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_getscopeobject implements IInstruction
	{
		//local scope stack
		public var index:uint;

		public function Instruction_getscopeobject(index:uint = 0)
		{
			this.index = index;
		}
	}
}