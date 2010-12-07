package com.swfwire.debugger.injected
{
	public class Security
	{
		public static function allowDomain(... args):void
		{
			trace('Security.allowDomain("'+args.join('", "')+'") - nop');
		}
		public static function allowInsecureDomain(... args):void
		{
			trace('Security.allowInsecureDomain("'+args.join('", "')+'") - nop');
		}
		public static function loadPolicyFile(... args):void
		{
			trace('Security.loadPolicyFile("'+args.join('", "')+'") - nop');
		}
	}
}