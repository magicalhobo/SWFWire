package com.swfwire.debugger.injected
{
	public class Security
	{
		public static function allowDomain(... args):void
		{
			trace('Security.allowDomain - nop');
		}
		public static function loadPolicyFile(... args):void
		{
			trace('Security.loadPolicyFile - nop');
		}
	}
}