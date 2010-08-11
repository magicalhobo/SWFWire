package com.swfwire.debugger.utils
{
	public class InstructionTemplate
	{
		public var type:Class;
		public var properties:Object;
		
		public function InstructionTemplate(type:Class, properties:Object)
		{
			this.type = type;
			this.properties = properties;
		}
	}
}