package com.swfwire.debugger.ui
{
	import flash.display.InteractiveObject;
	
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
		
		override public function setSelection(beginIndex:int, endIndex:int):void
		{
			if(beginIndex == 0 && endIndex == 0)
			{
				textField.text = '';
				textField.text = text;
				super.setSelection(0, 0);
			}
			else
			{
				super.setSelection(beginIndex, endIndex);
			}
		}
		
		public function appendText(newText:String):void
		{
			textField.appendText(newText);
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
	}
}