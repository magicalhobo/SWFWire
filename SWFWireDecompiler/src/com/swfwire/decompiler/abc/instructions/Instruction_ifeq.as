package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_ifeq implements IInstruction
	{
		public var offset:int;
		public var reference:IInstruction;
	}
}