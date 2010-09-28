package com.swfwire.utils
{
	import flash.utils.getTimer;

	public class Debug
	{
		public static var enabled:Boolean = false;
		public static var swfId:String = '';
		public static var defaultRecursionDepth:Number = 3;
		public static var minPropertiesForMultiline:Number = 6;
		public static var singleLineLengthLimit:Number = 60;
		public static var maxProperties:Number = 50;
		
		/**
		 * Logs a function call and variable with a standard format
		 * 
		 * @param location Location is a string, so that you can search files for the exact string you 
		 * see in the output.  It's also faster than doing any kind of lookup based on the caller.
		 */
		public static function log(location:String, message:* = '', relatedVariable:Object = null):void
		{
			if(!enabled)
			{
				return;
			}
			var messageString:String = message ? ': '+String(message) : '';
			var dumpString:String = relatedVariable ? '\n' + StringUtil.indent(_dump(relatedVariable), '    ') : '';
			//Don't do anything smart when swfId is empty, so it looks ugly and the user adds a swfId
			var str:String = '['+getTimer()+'  '+swfId+'/'+location+'()  ]'+messageString+dumpString;
			trace(str);
		}
		
		/**
		 * Dumps a variable's dynamic properties
		 * 
		 * @param variable Variable to dump.
		 * @param recursion Number of levels to go down.
		 * @return The dump as a string.
		 */		
		public static function _dump(variable:*, recursion:int = 0):String
		{
			if(recursion <= 0)	 recursion = defaultRecursionDepth;
			return ObjectUtil.objectToString(variable, recursion, minPropertiesForMultiline, singleLineLengthLimit, maxProperties, '  ');
		}
		
		public static function dump(variable:*, recursion:int = 0):void
		{
			trace(_dump(variable, recursion));
		}
	}
}