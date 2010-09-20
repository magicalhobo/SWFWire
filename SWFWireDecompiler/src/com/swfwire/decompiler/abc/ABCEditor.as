package com.swfwire.decompiler.abc
{
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.*;
	import com.swfwire.decompiler.abc.tokens.multinames.*;
	
	public class ABCEditor
	{
		private var abcFile:ABCFile;
		
		public function ABCEditor(abcFile:ABCFile)
		{
			this.abcFile = abcFile;
		}
		public function getIntIndex(integer:int):int
		{
			var index:int = -1;
			var integers:Vector.<int> = abcFile.cpool.integers;
			for(var iter:uint = 1; iter < integers.length; iter++)
			{
				if(integers[iter] == integer)
				{
					index = iter;
					break;
				}
			}
			return index;
		}
		public function addInt(integer:int):int
		{
			var index:int = getIntIndex(integer);
			var integers:Vector.<int> = abcFile.cpool.integers;
			if(index == -1)
			{
				index = integers.length;
				integers.push(integer);
			}
			return index;
		}
		public function getStringIndex(string:String):int
		{
			var index:int = -1;
			var strings:Vector.<StringToken> = abcFile.cpool.strings;
			for(var iter:uint = 1; iter < strings.length; iter++)
			{
				if(strings[iter].utf8 == string)
				{
					index = iter;
					break;
				}
			}
			return index;
		}
		public function addString(string:String):int
		{
			var index:int = getStringIndex(string);
			var strings:Vector.<StringToken> = abcFile.cpool.strings;
			if(index == -1)
			{
				index = strings.length;
				strings.push(new StringToken(string));
			}
			return index;
		}
		public function getNamespaceIndex(kind:uint, stringIndex:int):int
		{
			var index:int = -1;
			if(stringIndex != -1)
			{
				var namespaces:Vector.<NamespaceToken> = abcFile.cpool.namespaces;
				var namespaceLength:uint = namespaces.length;
				for(var iter:uint = 1; iter < namespaceLength; iter++)
				{
					if(namespaces[iter].name == stringIndex && namespaces[iter].kind == kind)
					{
						index = iter;
						break;
					}
				}
			}
			return index;
		}
		public function addNamespace(kind:uint, stringIndex:int):int
		{
			var index:int = getNamespaceIndex(kind, stringIndex);
			
			var namespaces:Vector.<NamespaceToken> = abcFile.cpool.namespaces;
			if(index == -1)
			{
				index = namespaces.length;
				namespaces.push(new NamespaceToken(kind, stringIndex));
			}
			return index;
		}
		public function getQNameIndex(namespace:int, name:int):int
		{
			var index:int = -1;
			
			var multinames:Vector.<MultinameToken> = abcFile.cpool.multinames;
			for(var iter:uint = 1; iter < multinames.length; iter++)
			{
				var qname:MultinameQNameToken = multinames[iter] as MultinameQNameToken;
				if(qname is MultinameQNameToken)
				{
					if(qname.name == name && qname.ns == namespace)
					{
						index = iter;
						break;
					}
				}
			}
			
			return index;
		}
		public function addQName(namespace:int, name:int):int
		{
			var index:int = getQNameIndex(namespace, name);
			
			var multinames:Vector.<MultinameToken> = abcFile.cpool.multinames;
			if(index == -1)
			{
				index = multinames.length;
				multinames.push(new MultinameToken(MultinameToken.KIND_QName, new MultinameQNameToken(namespace, name)));
			}
			
			return index;
		}
		public function insertInstructions(set1:Vector.<IInstruction>, set2:Vector.<IInstruction>, position:uint):void
		{
			var iter:uint;
			
			var suffix:Vector.<IInstruction> = set1.splice(position, uint.MAX_VALUE);
			
			for(iter = 0; iter < set2.length; iter++)
			{
				set1.push(set2[iter]);
			}
			for(iter = 0; iter < suffix.length; iter++)
			{
				set1.push(suffix[iter]);
			}
		}
		public function getStaticMethodInvocationInstructions(packageName:String, className:String,
			methodName:String, argumentInstructions:Vector.<IInstruction>):Vector.<IInstruction>
		{
			var packageIndex:int = addQName(
				addNamespace(
					NamespaceToken.KIND_PackageNamespace,
					addString(packageName)
				),
				addString(className)
			);
			var methodIndex:int = addQName(
				addNamespace(
					NamespaceToken.KIND_PackageNamespace,
					addString('')
				),
				addString(methodName)
			);
			
			var instructions:Vector.<IInstruction> = Vector.<IInstruction>([
				new Instruction_findpropstrict(packageIndex),
				new Instruction_getproperty(packageIndex),
				new Instruction_callproperty(methodIndex, argumentInstructions.length),
				new Instruction_pop()
			]);
			insertInstructions(instructions, argumentInstructions, 2);
			
			return instructions;
		}
		public function getPushArgumentsToStack(... args):void
		{
			/*
			for(var iter:uint = 0; iter < args.length; iter++)
			{
				var arg:* = args[iter];
				if(arg is int)
				{
					addInt(
				}
			}
			*/
		}
	}
}