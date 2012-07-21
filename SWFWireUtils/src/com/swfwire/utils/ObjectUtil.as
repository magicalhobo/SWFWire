package com.swfwire.utils
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getTimer;
	
	public class ObjectUtil
	{
		public static function isBoolean(value:*):Boolean
		{
			return value === true || value === false;
		}
		public static function isNumber(value:*):Boolean
		{
			return !isNaN(value);
		}
		public static function join(... args):Object
		{
			var result:Object = args.shift();
			if(!result)
			{
				result = {};
			}
			for(var iter:* in args)
			{
				var obj:Object = args[iter];
				for(var iter2:* in obj)
				{
					result[iter2] = obj[iter2];
				}
			}
			return result;
		}
		public static function objectToString(variable:*, recurse:int, minPropertiesForMultiline:int,
			singleLineLengthLimit:int, maxProperties:int, callGetters:Boolean, indentation:String):String
		{
			return _objectToString(variable, recurse, minPropertiesForMultiline, singleLineLengthLimit,
				maxProperties, callGetters, indentation, []).result;
		}
		private static function _objectToString(variable:*, recurse:int, minPropertiesForMultiline:int,
			singleLineLengthLimit:int, maxProperties:int, callGetters:Boolean, indentation:String, tagged:Array):Object
		{
			for(var iterTags:String in tagged)
			{
				if(tagged[iterTags] === variable)
				{
					return {result: '[Recursion]', hasProperties: false, multiline: false};
				}
			}
			var anyChildHasChildren:Boolean = false;
			var elements:Array = [];
			var recursed:Boolean = false;
			var hasProperties:Boolean = false;
			var multiline:Boolean = false;
			var description:XML;
			if(variable !== undefined && variable !== null)
			{
				description = describeType(variable);
			}
			var type:String = description ? description.@name : '';
			var base:String = description ? description.@base : '';

			if(base == 'Class')
			{
				result = type;
			}
			else
			{
				var dumpLength:uint = 0;
				if(recurse > 0)
				{
					if(variable != null && typeof(variable) == 'object')
					{
						recursed = true;
						tagged.push(variable);
						var counter:Number = 0;
						var props:Dictionary = new Dictionary(true);
						
						var name:*;
						var node:XML;
						if(description)
						{
							for each(node in description.variable)
							{
								if(!node.hasOwnProperty('@uri'))
								{
									name = String(node.@name);
									props[name] = variable[name];
								}
							}
							
							if(callGetters)
							{
								for each(name in description.accessor.(@access == 'readwrite' || @access == 'readonly').@name)
								{
									name = String(name);
									try
									{
										props[name] = variable[name];
									}
									catch(e:Error)
									{
										props[name] = '<exception thrown by getter>';
									}
								}
							}
						}
						for(name in variable)
						{
							props[name] = variable[name];
						}
						var numericProperties:Array = [];
						var numericIndicies:Array = [];
						for(name in props)
						{
							var prop:* = props[name];
							
							if(typeof(prop) == 'function')
							{
								continue;
							}
							if(counter == maxProperties)
							{
								elements.push('[tooManyProperties]');
								break;
							}
							counter++;
							var dumpKey:Object = _objectToString(name, recurse - 1, minPropertiesForMultiline, singleLineLengthLimit, maxProperties, callGetters, indentation, tagged);
							var dumpValue:Object = _objectToString(prop, recurse - 1, minPropertiesForMultiline, singleLineLengthLimit, maxProperties, callGetters, indentation, tagged);
							if(dumpKey.hasProperties || dumpValue.hasProperties)
							{
								anyChildHasChildren = true;
							}
							if(dumpKey.multiline || dumpValue.multiline)
							{
								dumpValue.result = '\n'+StringUtil.indent(dumpValue.result, indentation + indentation);
							}
							var dumpString:String = dumpKey.result+ ': ' + dumpValue.result;
							if(isNaN(Number(name)))
							{
								elements.push(dumpString);
							}
							else
							{
								numericIndicies.push(name);
								numericProperties[name] = dumpString;
							}
							dumpLength += dumpString.length;
						}
						
						elements.sort();
						numericIndicies.sort(Array.NUMERIC);
						for(name in numericIndicies)
						{
							elements.push(numericProperties[numericIndicies[name]]);
						}
					}
				}
				var result:String = '';
				var typeInfo:Array = type.split('::');
				var packageName:String = 'null';
				var className:String = type;
				if(typeInfo.length > 1)
				{
					packageName = typeInfo.shift();
					className = typeInfo.join('::');
				}
				if(className == 'Object' || className == 'Array' || className == 'String' || className == 'Number' || className == 'Boolean')
				{
					className = '';
				}
				if (elements.length == 0)
				{
					var variableType:String = typeof(variable);
					if(variable == null)
					{
						result = String(variable);
					}
					else if(variableType == 'string')
					{
						result = '"' + String(variable) + '"';
					}
					else if(variableType == 'function')
					{
						result = '[function Function]'
					}
					else if(variableType == 'object')
					{
						if(variable.constructor === Array)
						{
							if(recursed)
							{
								result = '[]';
							}
							else
							{
								result = '[depthMax Array]';
							}
						}
						else
						{
							if(recursed)
							{
								result = '{}';
							}
							else
							{
								result = '[depthMax Object]';
							}
						}
					}
					else
					{
						result = String(variable);
					}
				}
				else {
					hasProperties = true;
					if(variable.constructor === Array || packageName == '__AS3__.vec')
					{
						if(anyChildHasChildren || (elements.length >= minPropertiesForMultiline))
						{
							result = '[\n' + indentation + elements.join(',\n' + indentation) + '\n' + ']';
							multiline = true;
						}
						else
						{
							result = '[' + elements.join(', ') + ']';
						}
					}
					else
					{
						if(anyChildHasChildren || (elements.length >= minPropertiesForMultiline) || (dumpLength > singleLineLengthLimit))
						{
							result = '{\n' + indentation + elements.join(',\n' + indentation) + '\n' + '}';
							multiline = true;
						}
						else
						{
							result = '{' + elements.join(', ') + '}';
						}
					}
				}
			}
			return {result: className ? className+'('+result+')' : result, hasProperties: hasProperties, multiline: multiline};
		}
	}
}