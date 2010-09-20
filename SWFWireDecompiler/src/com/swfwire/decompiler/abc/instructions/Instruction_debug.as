package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_debug extends BaseInstruction
	{
		public static const TYPE_DI_LOCAL:uint = 1;
		
		public var debugType:uint;
		public var index:uint;
		public var reg:uint;
		public var extra:uint;

		public function Instruction_debug(debugType:uint = 0, index:uint = 0, reg:uint = 0, extra:uint = 0)
		{
			this.debugType = debugType;
			this.index = index;
			this.reg = reg;
			this.extra = extra;
		}
	}
}