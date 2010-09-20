package com.swfwire.decompiler.abc.tokens.traits
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class TraitMethodToken implements ITrait
	{
		public var dispId:uint;
		public var methodId:uint;

		public function TraitMethodToken(dispId:uint = 0, methodId:uint = 0)
		{
			this.dispId = dispId;
			this.methodId = methodId;
		}
		
		public function read(abc:ABCByteArray):void
		{
			dispId = abc.readU30();
			methodId = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(dispId);
			abc.writeU30(methodId);
		}
	}
}