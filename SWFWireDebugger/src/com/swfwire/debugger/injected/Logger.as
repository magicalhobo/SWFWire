package com.swfwire.debugger.injected
{
	import com.swfwire.utils.ObjectUtil;
	import com.swfwire.utils.StringUtil;
	
	import mx.controls.TextArea;
	
	public class Logger
	{
		public static var showMethodEntry:Boolean = true;
		public static var dumpArguments:Boolean = true;
		public static var showTrace:Boolean = true;
		
		public static var output:TextArea;
		public static var buffer:String;
		
		private static var indent:int = 0;
		
		public static function _log(message:*):void
		{
			var str:String = StringUtil.indent(message, StringUtil.repeat('	', indent));
			/*
			trace(str);
			return;
			*/
			if(output)
			{
				/*
				var str:String = StringUtil.repeat('	', indent) + message;
				if(!(message is String))
				{
					str = ObjectUtil.objectToString(message, 1, 3, 100, 1000, '	');
				}
				*/
				if(output.text == '')
				{
					output.text += str;
				}
				else
				{
					output.text += '\n' + str;
				}
				var shouldScroll:Boolean = output.verticalScrollPosition == output.maxVerticalScrollPosition;
				if(shouldScroll)
				{
					output.validateNow();
					output.verticalScrollPosition = output.maxVerticalScrollPosition;
				}
			}
		}
		
		public static function log(message:*):void
		{
			if(showTrace)
			{
				_log(message);
			}
		}
		
		public static function enterFunction(methodName:String = 'unk', caller:* = null, params:Object = null):void
		{
			if(showMethodEntry)
			{
				var methodName2:String = new StackInfo(1).functionName;
				_log('>> ' + methodName2);
			}
			//log(caller);
			indent++;
			if(dumpArguments && params)
			{
				_log(ObjectUtil.objectToString(params, 2, 2, 50, 50, '	'));
			}
		}
		
		public static function exitFunction(methodName:String = 'unk'):void
		{
			indent--;
			indent = Math.max(indent, 0);
			if(showMethodEntry)
			{
				var methodName2:String = new StackInfo(1).functionName;
				//_log('<< ' + methodName2);
				_log('<<');
			}
		}
	}
}