package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class ExceptionInfoToken implements IToken
	{
		public var from:uint;
		public var to:uint;
		public var target:uint;
		public var excType:uint;
		public var varName:uint;

		public function ExceptionInfoToken(from:uint = 0, to:uint = 0, target:uint = 0, excType:uint = 0, varName:uint = 0)
		{
			this.from = from;
			this.to = to;
			this.target = target;
			this.excType = excType;
			this.varName = varName;
		}
		
		public function read(abc:ABCByteArray):void
		{
			from = abc.readU30();
			to = abc.readU30();
			target = abc.readU30();
			excType = abc.readU30();
			varName = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(from);
			abc.writeU30(to);
			abc.writeU30(target);
			abc.writeU30(excType);
			abc.writeU30(varName);
		}
	}
}