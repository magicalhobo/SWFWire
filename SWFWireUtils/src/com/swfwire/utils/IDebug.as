package com.swfwire.utils
{
	public interface IDebug
	{
		function log(location:String, message:* = '', relatedVariable:Object = null):void
		function dumpToString(variable:*, recursion:int = 0):String
		function dump(variable:*, recursion:int = 0):void
	}
}