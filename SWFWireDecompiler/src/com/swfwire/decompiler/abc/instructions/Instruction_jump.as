package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_jump implements IInstruction
	{
		public var offset:int;
		public var reference:IInstruction;
	}
}