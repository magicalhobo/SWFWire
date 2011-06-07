package com.swfwire.utils
{
	import flash.utils.getTimer;

	public class Debug implements IDebug
	{
		public var enabled:Boolean = false;
		public var swfId:String = '';
		public var defaultRecursionDepth:Number = 3;
		public var minPropertiesForMultiline:Number = 6;
		public var singleLineLengthLimit:Number = 60;
		public var maxProperties:Number = 50;
		public var callGetters:Boolean = false;
		
		public function Debug(enabled:Boolean, swfId:String)
		{
			this.enabled = enabled;
			this.swfId = swfId;
		}
		
		public function log(location:String, message:* = '', relatedVariable:Object = null):void
		{
			if(enabled)
			{
				var messageString:String = message ? ': '+String(message) : '';
				var dumpString:String = relatedVariable ? '\n' + StringUtil.indent(dumpToString(relatedVariable), '    ') : '';
				var str:String = '['+getTimer()+'  '+swfId+'/'+location+'()  ]'+messageString+dumpString;
				trace(str);
			}
		}
		
		public function dumpToString(variable:*, recursion:int = 0):String
		{
			if(recursion <= 0)	 recursion = defaultRecursionDepth;
			return ObjectUtil.objectToString(variable, recursion, minPropertiesForMultiline, singleLineLengthLimit, maxProperties, callGetters, '  ');
		}
		
		public function dump(variable:*, recursion:int = 0):void
		{
			trace(dumpToString(variable, recursion));
		}
	}
}