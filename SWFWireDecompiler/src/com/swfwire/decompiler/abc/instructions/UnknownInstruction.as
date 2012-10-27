package com.swfwire.decompiler.abc.instructions
{
	public class UnknownInstruction implements IInstruction
	{
		public var type:uint;
		
		public function UnknownInstruction(type:uint = 0)
		{
			this.type = type;
		}
	}
}