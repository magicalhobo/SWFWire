package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	/**
	 * Not in the spec, taks 1 argument, does not modify stack, scope or locals
	 */
	public class Instruction_findpropglobal implements IInstruction
	{
		public var index:uint;
	}
}