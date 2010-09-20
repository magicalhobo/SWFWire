package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.instructions.IInstruction;
	
	import flash.utils.ByteArray;
	
	public class MethodBodyInfoToken implements IToken
	{
		public var method:uint;
		//TODO: automatically calculate limits? in a subclass?
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
		
		public function read(abc:ABCByteArray):void
		{
			var iter:uint;
			method = abc.readU30();
			maxStack = abc.readU30();
			localCount = abc.readU30();
			initScopeDepth = abc.readU30();
			maxScopeDepth = abc.readU30();
			codeLength = abc.readU30();
			code = new ByteArray();
			if(codeLength > 0)
			{
				abc.readBytes(code, 0, codeLength);
			}
			
			exceptionCount = abc.readU30();
			exceptions = new Vector.<ExceptionInfoToken>(exceptionCount);
			for(iter = 0; iter < exceptionCount; iter++)
			{
				var exceptionInfo:ExceptionInfoToken = new ExceptionInfoToken();
				exceptionInfo.read(abc);
				exceptions[iter] = exceptionInfo;
			}
			traitCount = abc.readU30();
			traits = new Vector.<TraitsInfoToken>(traitCount);
			for(iter = 0; iter < traitCount; iter++)
			{
				var trait:TraitsInfoToken = new TraitsInfoToken();
				trait.read(abc);
				traits[iter] = trait;
			}
		}
		public function write(abc:ABCByteArray):void
		{
			var iter:uint;
			abc.writeU30(method);
			abc.writeU30(maxStack);
			abc.writeU30(localCount);
			abc.writeU30(initScopeDepth);
			abc.writeU30(maxScopeDepth);
			abc.writeU30(code.length);
			if(code.length > 0)
			{
				abc.writeBytes(code, 0, code.length);
			}
			abc.writeU30(exceptionCount);
			for(iter = 0; iter < exceptions.length; iter++)
			{
				exceptions[iter].write(abc);
			}
			abc.writeU30(traitCount);
			for(iter = 0; iter < traits.length; iter++)
			{
				traits[iter].write(abc);
			}
		}
	}
}