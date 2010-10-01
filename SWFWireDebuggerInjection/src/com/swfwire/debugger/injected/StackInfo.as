package com.swfwire.debugger.injected
{
	public class StackInfo
	{
		public var stackTrace:String;
		public var functionName:String;
		public var callDepth:Number;
		
		public function StackInfo(ignoredCalls:int = 0, error:Error = null)
		{
			ignoredCalls++;
			if(error == null){
				error = new Error();
			}
			stackTrace = error.getStackTrace();
			if(stackTrace == null){
				stackTrace = 'UNKNOWN';
			}
			else {
				var stack:Array = stackTrace.split('\n');
				if(stack.length == 0){
					stackTrace = 'UNKNOWN';
				}
				else {
					stack.shift();
					if(stack.length > ignoredCalls){
						stack.splice(0, ignoredCalls);
						callDepth = stack.length;
						functionName = String(stack[0]).substring(4, String(stack[0]).indexOf('()') + 2);
						stackTrace = stack.join('\n');
					}
				}
			}
		}
	}
}