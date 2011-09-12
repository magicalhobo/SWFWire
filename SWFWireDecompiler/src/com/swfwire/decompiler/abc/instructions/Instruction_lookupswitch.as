package com.swfwire.decompiler.abc.instructions
{
	import com.swfwire.decompiler.abc.*;
	
	public class Instruction_lookupswitch implements IInstruction
	{
		public var defaultOffset:int;
		public var caseOffsets:Vector.<int>;
		
		public var defaultReference:IInstruction;
		public var caseReferences:Vector.<IInstruction>;
	}
}