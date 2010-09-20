package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	/**
	 * Takes 1 argument, pops an object, then argCount values off the stack, pushes an any(*)
	 */
	public class Instruction_applytype extends BaseInstruction
	{
		public var argCount:uint;

		public function Instruction_applytype(argCount:uint = 0)
		{
			this.argCount = argCount;
		}
	}
}
