package com.swfwire.utils
{
	public class StringUtil
	{
		public static var INDENT:String = '\t';
		public static var LINE_FEED:String = '\n';
		public static var CARRIAGE_RETURN:String = '\r';
		public static var NEWLINE_REGEXP:RegExp = new RegExp("(\r|\n)", "g");
		
		public static function indent(string:String, indent:String):String
		{
			var indentedString:String = indent + string.replace(NEWLINE_REGEXP, "$1" + indent);
			return indentedString;
		}
		public static function repeat(string:String, repetitions:int):String
		{
			var newString:String = '';
			for(var iter:uint = 0; iter < repetitions; iter++)
			{
				newString += string;
			}
			return newString;
		}
		public static function isMultiline(string:String):Boolean
		{
			var multiline:Boolean = string.search(NEWLINE_REGEXP) != -1;
			return multiline;
		}
		public static function namedSubstitute(str:String, substitutions:Object, pattern:String = '{(.*?)}', unknownToken:String = null):String
		{
			if(str != null){
				str = str.replace(new RegExp(pattern, 'g'), function(...args):String
				{
					var replacement:String = unknownToken !== null ? unknownToken : args[0];
					if(substitutions){
						if(substitutions.hasOwnProperty(args[1]))
						{
							replacement = substitutions[args[1]] === null ? replacement : String(substitutions[args[1]]);
						}
					}
					return replacement;
				});
			}
			return str;
		}
		public static function getNamedSubstitutes(str:String, pattern:String = '{(.*?)}'):Array
		{
			var matches:Array = str.match(new RegExp(pattern, 'g'));
			return matches;
		}
		public static function getSubstitutingSetter(host:*, prop:String, substitutions:Object):Function
		{
			return function(newValue:String):void {
				host[prop] = StringUtil.namedSubstitute(newValue, substitutions);
			}
		}
		public static function decodeHex(string:String):String
		{ 
			var decodedString:String = ''; 
			var hexCodes:Array = string.split(new RegExp('[%:]', 'g')); 
			for(var iter:uint = 0; iter < hexCodes.length; iter++)
			{ 
				var hexCode:String = hexCodes[iter].substring(0,2); 
				var char:String = String.fromCharCode(parseInt(hexCodes[iter].substring(0, 2), 16)) + hexCodes[iter].substring(2); 
				if (char && hexCode)
				{ 
					decodedString += char; 
				} 
			}
			return decodedString; 
		}
		public static function padEnd(string:String, padding:String):String
		{
			return string + padding.substr(string.length);
		}
	}
}