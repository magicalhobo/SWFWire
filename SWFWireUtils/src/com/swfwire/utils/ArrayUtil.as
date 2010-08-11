package com.swfwire.utils
{
	public class ArrayUtil
	{
		public static function sortNumeric(a:Number, b:Number):int
		{
			if(isNaN(a) && isNaN(b) || a == b)
			{
				return 0;
			}
			if(a > b || isNaN(b))
			{
				return 1;
			}
			if(a < b || isNaN(a))
			{
				return -1;
			}
			return 0;
		}
		
		public static function getSortNumeric(prop:String):Function
		{
			return function(a:*, b:*):int
			{
				return sortNumeric(a[prop], b[prop]);
			}
		}
	}
}