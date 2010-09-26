package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_pushstring implements IInstruction
	{
		//cpool.strings
		public var index:uint;
		
		public function Instruction_pushstring(index:uint = 0)
		{
			this.index = index;
		}
	}
}