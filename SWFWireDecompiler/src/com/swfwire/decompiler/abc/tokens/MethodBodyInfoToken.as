package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.abc.instructions.IInstruction;
	
	import flash.utils.ByteArray;
	
	public class MethodBodyInfoToken implements IToken
	{
		public var method:uint;
		public var maxStack:uint;
		public var localCount:uint;
		public var initScopeDepth:uint;
		public var maxScopeDepth:uint;
		public var codeLength:uint;
		public var code:ByteArray;
		public var exceptionCount:uint;
		public var exceptions:Vector.<ExceptionInfoToken>;
		public var traitCount:uint;
		public var traits:Vector.<TraitsInfoToken>;
		public var instructions:Vector.<IInstruction>;

		public function MethodBodyInfoToken(method:uint = 0, maxStack:uint = 0, localCount:uint = 0, initScopeDepth:uint = 0, maxScopeDepth:uint = 0, codeLength:uint = 0, code:ByteArray = null, exceptionCount:uint = 0, exceptions:Vector.<ExceptionInfoToken> = null, traitCount:uint = 0, traits:Vector.<TraitsInfoToken> = null, instructions:Vector.<IInstruction> = null)
		{
			if(code == null)
			{
				code = new ByteArray();
			}
			if(exceptions == null)
			{
				exceptions = new Vector.<ExceptionInfoToken>();
			}
			if(traits == null)
			{
				traits = new Vector.<TraitsInfoToken>();
			}
			if(instructions == null)
			{
				instructions = new Vector.<IInstruction>();
			}

			this.method = method;
			this.maxStack = maxStack;
			this.localCount = localCount;
			this.initScopeDepth = initScopeDepth;
			this.maxScopeDepth = maxScopeDepth;
			this.codeLength = codeLength;
			this.code = code;
			this.exceptionCount = exceptionCount;
			this.exceptions = exceptions;
			this.traitCount = traitCount;
			this.traits = traits;
			this.instructions = instructions;
		}
	}
}