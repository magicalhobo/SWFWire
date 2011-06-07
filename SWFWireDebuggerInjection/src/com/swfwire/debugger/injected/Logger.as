package com.swfwire.debugger.injected
{
	import com.swfwire.utils.ObjectUtil;
	import com.swfwire.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	public class Logger
	{
		public static var logToTrace:Boolean = false;
		public static var logToOutput:Boolean = true;
		public static var showMethodEntry:Boolean = false;
		public static var showMethodExit:Boolean = true;
		public static var showTraceStatements:Boolean = true;
		public static var showArguments:Boolean = false;
		public static var showReturn:Boolean = false;
		
		public static var skipEnterFrame:Boolean = true;
		public static var skipExitFrame:Boolean = true;
		public static var skipRender:Boolean = true;
		public static var skipFrameConstructed:Boolean = true;
		public static var skipTimer:Boolean = true;
		public static var skipFL:Boolean = true;
		public static var skipMX:Boolean = true;
		public static var skipFlashX:Boolean = true;
		
		public static var indentString:String = '  ';
		
		public static var maxStack:uint = 50;
		
		public static var output:*;
		public static var buffer:String = '';
		
		private static var objectReferences:Dictionary = new Dictionary(true);
		
		private static var inEnterFrame:Boolean;
		private static var inExitFrame:Boolean;
		private static var inRender:Boolean;
		private static var inFrameConstructed:Boolean;
		private static var inTimer:Boolean;
		private static var show2:Boolean;
		
		private static var indent:int = 0;
		private static var startTimes:Array = [];
		private static var stack:Array = [];
		private static var objectId:int = 0;
		
		public static function flushBuffer():void
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
				str = StringUtil.indent(message, StringUtil.repeat(indentString, indent));
			}
			buffer += str + '\n';
		}
		

		public static function log(... args):void
		{
			if(show2 && showTraceStatements)
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
						var t:String = Event(params[iter]).type;
						if(t == 'enterFrame')
						{
							inEnterFrame = true;
						}
						else if(t == 'exitFrame')
						{
							inExitFrame = true;
						}
						else if(t == 'render')
						{
							inRender = true;
						}
						else if(t == 'frameConstructed')
						{
							inFrameConstructed = true;
						}
						else if(t == 'timer')
						{
							inTimer = true;
						}
					}
					break;
				}
				show2 = (!skipEnterFrame || !inEnterFrame) &&
						(!skipExitFrame || !inExitFrame) &&
						(!skipRender || !inRender) &&
						(!skipFrameConstructed || !inFrameConstructed) &&
						(!skipTimer || !inTimer);
			}
			
			var show3:Boolean = show2 && stack.length < maxStack &&
				!(skipMX && methodName.substr(0, 3) == 'mx.') && 
				!(skipFL && methodName.substr(0, 3) == 'fl.') &&
				!(skipFlashX && methodName.substr(0, 7) == 'flashx.');

			stack.push(methodName);
			if(show3 && showMethodEntry)
			{
				//var methodName2:String = new StackInfo(1).functionName;
				//_log('> ' + methodName + ' | '+methodName2);
				//methodName = new StackInfo(1).functionName;
				_log('> ' + methodName);
				indent++;
			}
			//indent = stack.length;
			if(show3 && showArguments && params)
			{
				_log(ObjectUtil.objectToString(params, 2, 2, 50, 50, false, indentString));
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
			
			var show:Boolean = show2;
			/*
			var show:Boolean = showMethodEntry &&
				(!skipEnterFrame|| !inEnterFrame) &&
				(!skipExitFrame || !inExitFrame) &&
				(!skipRender || !inRender) &&
				(!skipFrameConstructed || !inFrameConstructed) &&
				(!skipTimer || !inTimer);
			*/
			
			if(stack.length == 0)
			{
 				inEnterFrame = false;
 				inExitFrame = false;
 				inRender = false;
 				inFrameConstructed = false;
 				inTimer = false;
				
				show2 = true;
			}
			
			var show3:Boolean = show && stack.length < maxStack && 
				!(skipMX && methodName.substr(0, 3) == 'mx.') && 
				!(skipFL && methodName.substr(0, 3) == 'fl.') &&
				!(skipFlashX && methodName.substr(0, 7) == 'flashx.');
			
			var n:String = 'nothing';
			if(methodName == 'com.ffi.utils:FMSConnector/get hasAudio')
			{
				trace('found it');
			}
			
			if(showReturn && returnValue !== null && show3)
			{
				_log('return '+ObjectUtil.objectToString(returnValue, 2, 2, 50, 50, false, indentString));
			}
			//indent = stack.length;
			
			if(show3)
			{
				indent--;
				indent = Math.max(indent, 0);
			}
			
			if(show3 && showMethodEntry && showMethodExit)
			{
				//var methodName2:String = new StackInfo(1).functionName;
				//_log('<< ' + methodName2);
				
				var diff:int = getTimer() - start;
				
				_log('< '+methodName+' ('+diff+'ms)');
				
				if(diff > 3000)
				{
					showMethodEntry = false;
					_log('Show method entry disabled for performance');
				}
				
				//_log('<<');
			}
			return;
		}
		
		public static function newObject(object:*):void
		{
			if(object)
			{
				if(!(object is QName))
				{
					objectReferences[object] = {creationTime: getTimer(), id: objectId++, method: stack[stack.length - 1]};
				}
				log('new '+getQualifiedClassName(object));
			}
		}
		
		public static function enumerateObjects():Array
		{
			var result:Array = [];
			for(var iter:* in objectReferences)
			{
				var d:* = objectReferences[iter];
				result.push({id: String(d.id), type: getQualifiedClassName(iter), method: d.method, creationTime: String(d.creationTime)});
			}
			return result;
		}
		
		public static function getObjectCount():int
		{
			var result:int = 0;
			for(var iter:* in objectReferences)
			{
				result++;
			}
			return result;
		}
		
		public static function getObjectById(id:int):*
		{
			var result:*;
			for(var iter:* in objectReferences)
			{
				var d:* = objectReferences[iter];
				if(d.id == id)
				{
					result = iter;
					break;
				}
			}
			return result;
		}
		
		public static function uncaughtError(e:* = null):void
		{
			indent = 0;
			startTimes = [];
			stack = [];
			
			flushBuffer();
			
			_log('Uncaught error:');
			_log(ObjectUtil.objectToString(e, 2, 2, 50, 50, true, indentString));
		}
	}
}