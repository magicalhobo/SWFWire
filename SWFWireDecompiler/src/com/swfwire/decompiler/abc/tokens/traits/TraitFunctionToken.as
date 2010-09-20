package com.swfwire.decompiler.abc.tokens.traits
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class TraitFunctionToken implements ITrait
	{
		public var slotId:uint;
		public var functionId:uint;

		public function TraitFunctionToken(slotId:uint = 0, functionId:uint = 0)
		{
			this.slotId = slotId;
			this.functionId = functionId;
		}
		
		public function read(abc:ABCByteArray):void
		{
			slotId = abc.readU30();
			functionId = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(slotId);
			abc.writeU30(functionId);
		}
	}
}