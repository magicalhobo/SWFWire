package com.swfwire.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public class DisplayUtil
	{
		public static const ALIGN_CENTER:uint = 0;
		
		public static const ALIGN_LEFT:uint = 1;
		public static const ALIGN_RIGHT:uint = 2;
		
		public static const ALIGN_TOP:uint = 1;
		public static const ALIGN_BOTTOM:uint = 2;
		
		public static function scaleToFit(fromW:Number, fromH:Number, toW:Number, toH:Number, outerFit:Boolean = false, alignH:uint = ALIGN_CENTER, alignV:uint = ALIGN_CENTER):Rectangle
		{
			var newX:Number = 0;
			var newY:Number = 0;
			var newW:Number = toW;
			var newH:Number = toH;
			if((fromW/fromH > toW/toH && !outerFit) || (fromW/fromH < toW/toH && outerFit))
			{
				newH = toW * (fromH/fromW);
				switch(alignV){
					case ALIGN_TOP:
						newY = 0;
						break;
					case ALIGN_BOTTOM:
						newY = toH - newH;
						break;
					default:
						newY = (toH - newH)/2;
						break;
				}
			}
			else
			{
				newW = toH * (fromW/fromH);
				switch(alignH){
					case ALIGN_LEFT:
						newX = 0;
						break;
					case ALIGN_RIGHT:
						newX = toW - newW;
						break;
					default:
						newX = (toW - newW)/2;
						break;
				}
			}
			return new Rectangle(newX, newY, newW, newH);
		}
		
		public static function getDisplayObjectPath(target:DisplayObject, relativeTo:DisplayObject = null):String
		{
			var path:Array = [];
			while(target && target.parent)
			{
				if(target == relativeTo)
				{
					break;
				}
				path.push(target.name);
				target = target.parent;
			}
			return path.reverse().join('.');
		}
	}
}