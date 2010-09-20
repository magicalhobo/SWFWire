package com.swfwire.decompiler.abc
{
	public class LocalRegisters
	{
		public var values:Array = [];
		public var names:Array = [];
		
		public function setValue(index:uint, value:*):void
		{
			values[index] = value;
		}
		public function getValue(index:uint):*
		{
			return values[index];
		}
		public function setName(index:uint, name:String):void
		{
			names[index] = name;
		}
		public function getName(index:uint):String
		{
			return names[index];
		}
	}
}