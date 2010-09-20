package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	/**
	 * Not in the spec, takes 0 arguments, pops 2 values off the stack, does not modify scope or locals
	 */
	public class Instruction_si8 extends BaseInstruction
	{
		public var index:uint;
	}
}