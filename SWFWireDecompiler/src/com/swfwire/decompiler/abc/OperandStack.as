package com.swfwire.decompiler.abc
{
	public class OperandStack
	{
		public var values:Vector.<Object>;
		private var copyonwrite:Boolean;
		private var duped:Boolean=false;
		public function OperandStack(_values:Vector.<Object>,cow:Boolean)
		{
			values = _values;
			copyonwrite = cow;
		}
		private function fork():void
		{
			if (copyonwrite && !duped)
			{
				values = values.slice();
				duped = true;
			}
		}
		public function push(value:*):void
		{
			fork();
			values.push(value);
		}
		public function pop():*
		{
			fork();
			if(values.length == 0)
			{
				trace('WARNING: OperandStack underflow');
				values.push('');
			}
			return values.pop();
		}
	}
}