package com.swfwire.debugger.injected
{
	import com.swfwire.utils.ObjectUtil;
	import com.swfwire.utils.StringUtil;
	
	import mx.controls.TextArea;
	
	public class Logger
	{
		public static var output:TextArea
		
		public static function log(message:*):void
		{
			if(output)
			{
				var str:String = message;
				if(!(message is String))
				{
					str = ObjectUtil.objectToString(message, 1, 3, 100, 1000, '	');
				}
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
		
		private static var indent:int = 0;
		
		public static function enterFunction(methodName:String = 'unk'):void
		{
			var methodName2:String = new StackInfo(1).functionName;
			
			log(StringUtil.repeat('	', indent) + '>> ' + methodName + ' - ' + methodName2);
			indent++;
		}
		
		public static function exitFunction(methodName:String = 'unk'):void
		{
			indent--;
			indent = Math.max(indent, 0);
			var methodName2:String = new StackInfo(1).functionName;
			log(StringUtil.repeat('	', indent) + '<< ' + methodName + ' - ' + methodName2);
		}
	}
}