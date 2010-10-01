package
{
	import com.swfwire.debugger.injected.Logger;
	
	import flash.display.Sprite;
	
	public class SWFWireDebuggerInjection extends Sprite
	{
		private static var imports:Array = [Logger];
		
		public function SWFWireDebuggerInjection()
		{
			Logger.log('SWFWireDebuggerInjection loaded.');
		}
	}
}