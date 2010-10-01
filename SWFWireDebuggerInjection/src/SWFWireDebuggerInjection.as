package
{
	import com.swfwire.debugger.injected.Logger;
	import com.swfwire.debugger.injected.Security;
	
	import flash.display.Sprite;
	
	public class SWFWireDebuggerInjection extends Sprite
	{
		private static var imports:Array = [Logger, Security];
		
		public function SWFWireDebuggerInjection()
		{
			Logger.log('SWFWireDebuggerInjection loaded: '+imports.join(', '));
		}
	}
}