package com.swfwire.debugger.utils
{
	public class InstructionLocation
	{
		public var methodBody:int;
		public var id:int;
		
		public function InstructionLocation(methodBody:int = -1, id:int = -1)
		{
			this.methodBody = methodBody;
			this.id = id;
		}
	}
}