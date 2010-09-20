package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_pushbyte extends BaseInstruction
	{
		public var byteValue:int;

		public function Instruction_pushbyte(byteValue:int = 0)
		{
			this.byteValue = byteValue;
		}
	}
}