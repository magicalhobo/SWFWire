package com.swfwire.decompiler.abc
{
	import com.swfwire.decompiler.abc.tokens.ConstantPoolToken;
	import com.swfwire.decompiler.abc.tokens.MultinameToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameMultinameToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameQNameToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameRTQNameLToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameRTQNameToken;

	public class AVM2
	{
		public static const TYPE_Any:String			 = '*';
		public static const TYPE_undefined:String	 = 'undefined';
		public static const TYPE_null:String		 = 'null';
		public static const TYPE_Boolean:String		 = 'Boolean';
		public static const TYPE_int:String			 = 'int';
		public static const TYPE_uint:String		 = 'uint';
		public static const TYPE_Number:String		 = 'Number';
		public static const TYPE_String:String		 = 'String';
		public static const TYPE_Date:String		 = 'Date';
		public static const TYPE_XML:String			 = 'XML';
		public static const TYPE_XMLList:String		 = 'XMLList';
		public static const TYPE_Class:String		 = 'Class';
		
		public var cpool:ConstantPoolToken;
		public var stack:OperandStack;
		public var scopeStack:ScopeStack;
		public var localRegisters:LocalRegisters;
		
		public function AVM2(cpool:ConstantPoolToken, operandStack:OperandStack, scopeStack:ScopeStack, localRegisters:LocalRegisters)
		{
			this.cpool = cpool;
			this.stack = operandStack;
			this.scopeStack = scopeStack;
			this.localRegisters = localRegisters;
		}
		
		public function toInt32(value:*):int
		{
			return int(value)
		}
		
		public function setDebugFileName(fileName:String):void
		{
			
		}
		public function setDebugLine(line:uint):void
		{
			
		}
		public function invokeMethod(object:Object, arguments:Array):void
		{
			
		}
		public function resolveMultiname(index:uint):String
		{
			var multiname:MultinameToken = cpool.multinames[index];
			var qName:MultinameQNameToken = multiname as MultinameQNameToken;
			if(qName)
			{
				
			}
			var rtqName:MultinameRTQNameToken = multiname as MultinameRTQNameToken;
			if(rtqName)
			{
				
			}
			var rtqNameL:MultinameRTQNameLToken = multiname as MultinameRTQNameLToken;
			if(rtqNameL)
			{
				
			}
			var mName:MultinameMultinameToken = multiname as MultinameMultinameToken;
			if(mName)
			{
			}
			return 'multiname';
		}
		public function resolveStaticMultiname(index:uint):String
		{
			var multiname:MultinameToken = cpool.multinames[index];
			var qName:MultinameQNameToken = multiname as MultinameQNameToken;
			if(!qName)
			{
				throw new Error('The multiname was not a static name... something like that');
			}
			return cpool.strings[cpool.namespaces[qName.ns].name].utf8+'::'+cpool.strings[qName.name].utf8;
		}
		public function resolveMethod(index:uint):String
		{
			//TODO: index into methods
			return 'method return type';
		}
		public function isType(type:String, targetType:String):Boolean
		{
			//TODO: implement this with inheritence
			return type == targetType;
		}
	}
}