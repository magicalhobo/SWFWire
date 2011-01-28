package com.swfwire.decompiler.abc
{
	public class OperandStack
	{
		public var values:Vector.<Object>;
		
		public function OperandStack()
		{
			values = new Vector.<Object>();
		}
		public function push(value:*):void
		{
			values.push(value);
		}
		public function pop():*
		{
			return values.pop();
		}
	}
}