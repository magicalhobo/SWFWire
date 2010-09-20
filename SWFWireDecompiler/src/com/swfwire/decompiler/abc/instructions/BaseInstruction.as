package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.AVM2;

	public class BaseInstruction implements IInstruction
	{
		public function getOffset():int
		{
			return 0;
		}
	}
}