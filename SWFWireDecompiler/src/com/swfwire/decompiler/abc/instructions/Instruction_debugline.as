package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;

	public class Instruction_debugline extends BaseInstruction
	{
		public var lineNum:uint;

		public function Instruction_debugline(lineNum:uint = 0)
		{
			this.lineNum = lineNum;
		}
	}
}