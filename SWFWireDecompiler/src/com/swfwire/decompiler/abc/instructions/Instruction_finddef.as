package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	/**
	 * Not in the spec, takes 1 argument (index into multinames), pushes an Object onto the stack, does not modify scope or locals
	 */
	public class Instruction_finddef implements IInstruction
	{
		public var index:uint;
	}
}