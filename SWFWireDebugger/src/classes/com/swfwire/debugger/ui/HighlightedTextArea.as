package com.swfwire.debugger.ui
{
	import mx.controls.TextArea;
	import mx.events.FlexEvent;
	
	public class HighlightedTextArea extends TextArea
	{
		public function HighlightedTextArea()
		{
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		protected function creationCompleteHandler(ev:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			textField.alwaysShowSelection = true;
		}
	}
}