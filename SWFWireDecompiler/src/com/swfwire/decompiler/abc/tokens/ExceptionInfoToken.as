package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.abc.instructions.IInstruction;
	
	public class ExceptionInfoToken implements IToken
	{
		public var from:uint;
		public var to:uint;
		public var target:uint;
		public var fromRef:IInstruction;
		public var toRef:IInstruction;
		public var targetRef:IInstruction;
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
	}
}