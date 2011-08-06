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
			if(values.length == 0)
			{
				trace('WARNING: OperandStack underflow');
				values.push('');
			}
			return values.pop();
		}
	}
}