package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_findpropstrict extends BaseInstruction
	{
		//multiname
		public var index:uint;

		public function Instruction_findpropstrict(index:uint = 0)
		{
			this.index = index;
		}
	}
}