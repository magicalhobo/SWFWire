package com.swfwire.decompiler.abc
{
	public class ScopeStack
	{
		public var values:Vector.<Object>;
		
		public function ScopeStack(maxScopeDepth:uint)
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