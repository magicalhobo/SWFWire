package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_debugfile extends BaseInstruction
	{
		//String constant pool
		public var index:uint;

		public function Instruction_debugfile(index:uint = 0)
		{
			this.index = index;
		}
	}
}