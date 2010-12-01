package com.swfwire.debugger.injected
{
	import com.swfwire.utils.ObjectUtil;
	import com.swfwire.utils.StringUtil;
	
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class Logger
	{
		public static var logToTrace:Boolean = true;
		public static var logToOutput:Boolean = true;
		public static var showMethodEntry:Boolean = false;
		public static var showMethodExit:Boolean = false;
		public static var showTraceStatements:Boolean = true;
		public static var showArguments:Boolean = false;
		public static var showReturn:Boolean = false;
		public static var skipEnterFrameEvents:Boolean = true;
		public static var indentString:String = '  ';
		
		public static var output:*;
		public static var buffer:String = '';
		
		private static var inEnterFrame:Boolean;
		private static var indent:int = 0;
		private static var startTimes:Array = [];
		private static var stack:Array = [];
		
		public static function enterFrameStart():void
		{
			if(buffer)
			{
				if(logToTrace)
				{
					trace(buffer.substr(0, -1));
				}
				if(logToOutput && output)
				{
					/*
					var str:String = StringUtil.repeat('	', indent) + message;
					if(!(message is String))
					{
						str = ObjectUtil.objectToString(message, 1, 3, 100, 1000, '	');
					}
					*/
					output.text += buffer;
					var shouldScroll:Boolean = output.verticalScrollPosition == output.maxVerticalScrollPosition;
					if(shouldScroll)
					{
						output.validateNow();
						output.verticalScrollPosition = output.maxVerticalScrollPosition;
					}
				}
				buffer = '';
			}
		}
		
		public static function _log(message:*, autoIndent:Boolean = true):void
		{
			var str:String = String(message);
			if(autoIndent)
			{
				str = StringUtil.indent(message, StringUtil.repeat(indentString, indent + 2));
			}
			buffer += str + '\n';
		}
		

		public static function log(... args):void
		{
			if(showTraceStatements)
			{
				_log(args, false);
			}
		}
		
		public static function enterFunction(methodName:String = 'unk', caller:* = null, params:Object = null):void
		{
			if(stack.length == 0)
			{
				for(var iter:* in params)
				{
					if(params[iter] is Event)
					{
						if(Event(params[iter]).type == Event.ENTER_FRAME)
						{
							inEnterFrame = true;
						}
					}
					break;
				}
			}
			/*
			if(methodName.substr(0, 3) == 'fl.')
			{
				return;
			}
			*/
			var show:Boolean = showMethodEntry && (!skipEnterFrameEvents || !inEnterFrame);// && (!skipEnterFrameEvents || !(inEnterFrame || inRender));
			if(show)
			{
				//var methodName2:String = new StackInfo(1).functionName;
				//_log('> ' + methodName + ' | '+methodName2);
				//methodName = new StackInfo(1).functionName;
				_log('> ' + methodName);
			}
			stack.push(methodName);
			indent = stack.length;
			if(show && showArguments && params)
			{
				_log(ObjectUtil.objectToString(params, 2, 2, 50, 50, indentString));
			}
			startTimes.push(getTimer());
		}
		
		public static function exitFunction(methodName:String = 'unk', returnValue:* = null):void
		{
			while(stack.length > 0)
			{
				var start:int = startTimes.pop();
				if(methodName == stack.pop())
				{
					break;
				}
			}
			
			var show:Boolean = showMethodEntry && (!skipEnterFrameEvents || !inEnterFrame);
			
			if(stack.length == 0)
			{
				inEnterFrame = false;
			}
			
			if(showReturn && returnValue !== null)
			{
				_log('return '+ObjectUtil.objectToString(returnValue, 2, 2, 50, 50, indentString));
			}
			indent = stack.length;
			//indent = Math.max(indent, 0);
			
			if(show && showMethodExit)
			{
				//var methodName2:String = new StackInfo(1).functionName;
				//_log('<< ' + methodName2);
				
				var diff:int = getTimer() - start;
				
				_log('< '+diff+'ms');
				
				if(diff > 3000)
				{
					showMethodEntry = false;
					_log('Show method entry disabled for performance');
				}
				
				//_log('<<');
			}
			return;
		}
		
		public static function uncaughtError(e:* = null):void
		{
			indent = 0;
			startTimes = [];
			stack = [];
			
			_log('Uncaught error:');
			_log(ObjectUtil.objectToString(e, 2, 2, 50, 50, indentString));
		}
	}
}