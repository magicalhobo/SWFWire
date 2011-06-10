package com.swfwire.debugger.injected
{
	import flash.system.Security;

	public class Security
	{
		public static const APPLICATION:String = 'application';
		public static const LOCAL_TRUSTED:String = 'localTrusted';
		public static const LOCAL_WITH_FILE:String = 'localWithFile';
		public static const LOCAL_WITH_NETWORK:String = 'localWithNetwork';
		public static const REMOTE:String = 'remote';
		
		private static var _exactSettings:Boolean = true;
		
		public static function get sandboxType():String
		{
			return APPLICATION;
		}
		public static function get exactSettings():Boolean
		{
			return _exactSettings;
		}
		public static function set exactSettings(value:Boolean):void
		{
			_exactSettings = value;
		}
		
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
		public static function showSettings(... args):void
		{
			trace('Security.showSettings("'+args.join('", "')+'") - nop');
		}
	}
}