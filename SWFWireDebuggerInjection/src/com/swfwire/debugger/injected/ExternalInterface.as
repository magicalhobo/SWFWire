package com.swfwire.debugger.injected
{
	import flash.external.ExternalInterface;

	
	public class ExternalInterface
	{
		public static function get available():Boolean
		{
			return false;
		}
		public static function get marshallExceptions():Boolean
		{
			return false;
		}
		public static function set marshallExceptions(value:Boolean):void
		{
		}
		public static function get objectId():String
		{
			return '';
		}
		public static function call(functionName:String, ...parameters):*
		{
			trace('ExternalInterface.call("'+functionName+'") - nop');
		}
		public static function addCallback(functionName:String, closure:Function):void
		{
			trace('ExternalInterface.addCallback("'+functionName+'") - nop');
		}
	}
}