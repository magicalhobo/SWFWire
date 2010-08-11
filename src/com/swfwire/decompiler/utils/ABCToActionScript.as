package com.swfwire.decompiler.utils
{
	import com.swfwire.decompiler.abc.ABCFile;
	import com.swfwire.decompiler.abc.instructions.IInstruction;
	import com.swfwire.decompiler.abc.tokens.*;
	import com.swfwire.decompiler.abc.tokens.multinames.*;
	import com.swfwire.decompiler.abc.tokens.traits.*;
	import com.swfwire.utils.ObjectUtil;
	import com.swfwire.utils.StringUtil;
	
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	public class ABCToActionScript
	{
		private var abcFile:ABCFile;
		
		private var methodLookupCache:Array;
		private var customNamespaces:Object;
		
		public function ABCToActionScript(abcFile:ABCFile)
		{
			this.abcFile = abcFile;
			
			methodLookupCache = new Array();
			for(var iter:uint = 0; iter < abcFile.methodBodyCount; iter++)
			{
				methodLookupCache[abcFile.methodBodies[iter].method] = iter;
			}
			
			customNamespaces = new Array();
		}
		
		public function getReadableMultiname(index:uint, readable:ReadableMultiname):void
		{
			var cpool:ConstantPoolToken = abcFile.cpool;
			
			var multiname:MultinameToken = cpool.multinames[index];
			readable.namespace = '';
			readable.name = '?';
			if(index == 0)
			{
				readable.name = '*';
			}
			else
			{
				switch(multiname.kind)
				{
					case MultinameToken.KIND_QName:
					case MultinameToken.KIND_QNameA:
						var mq:MultinameQNameToken = multiname.data as MultinameQNameToken;
						readable.namespace = namespaceToString(mq.ns);
						readable.name = cpool.strings[mq.name].utf8;
						break;
				}
			}
		}
		
		public function getReadableTrait(traitInfo:TraitsInfoToken, r:ReadableTrait):void
		{
			r.arguments = new Vector.<ReadableMultiname>();
			
			var args:Array = [];
			var cpool:ConstantPoolToken = abcFile.cpool;
			r.declaration = new ReadableMultiname();
			multinameTraitToString(traitInfo.name, r.declaration);
			if(traitInfo.kind == 0)
			{
				var slotInfo:TraitSlotToken = TraitSlotToken(traitInfo.data);
				
				r.traitType = ReadableTrait.TYPE_PROPERTY;
				r.type = new ReadableMultiname();
				getReadableMultiname(slotInfo.typeName, r.type);
				//result = traitName+':'+multinameTypeToString(TraitSlotToken(traitInfo.data).typeName, r);
			}
			else if(traitInfo.kind == 1)
			{
				r.traitType = ReadableTrait.TYPE_METHOD;
				var traitMethod:TraitMethodToken = TraitMethodToken(traitInfo.data);
				var methodInfo:MethodInfoToken = abcFile.methods[traitMethod.methodId];
				for(var iter:uint = 0; iter < methodInfo.paramCount; iter++)
				{
					var paramType:uint = methodInfo.paramTypes[iter];
					var readableArg:ReadableMultiname = new ReadableMultiname();
					getReadableMultiname(paramType, readableArg);
					r.arguments[iter] = readableArg;
					//args.push('arg'+iter+':'+multinameTypeToString(cpool, paramType));
				}
				var bodyId:int = getBodyIdFromMethodId(traitMethod.methodId);
				if(bodyId >= 0)
				{
					r.instructions = abcFile.methodBodies[bodyId].instructions;
				}

				r.type = new ReadableMultiname(); 
				getReadableMultiname(methodInfo.returnType, r.type);
			}
			else if(traitInfo.kind == 6)
			{
				r.traitType = ReadableTrait.TYPE_PROPERTY;
				r.type = new ReadableMultiname();
				getReadableMultiname(TraitSlotToken(traitInfo.data).typeName, r.type);
				r.isConst = true;
			}
			if(traitInfo.kind == 0 || traitInfo.kind == 6)
			{
				var slotInfo2:TraitSlotToken = TraitSlotToken(traitInfo.data);
				switch(slotInfo2.vKind)
				{
					case 0x01:
						r.initializer = '"' + String(abcFile.cpool.strings[slotInfo2.vIndex].utf8) + '"';
						break;
					case 0x03:
						r.initializer = String(abcFile.cpool.integers[slotInfo2.vIndex]);
						break;
					case 0x08:
						var ns:String = namespaceToString(slotInfo2.vIndex);
						customNamespaces[ns] = r.declaration.name;
						r.traitType = ReadableTrait.TYPE_NAMESPACE;
						r.initializer = '"' + ns + '"';
						break;
				}
				
				/*
				CONSTANT_Int 0x03 integer
				CONSTANT_UInt 0x04 uinteger
				CONSTANT_Double 0x06 double
				CONSTANT_Utf8 0x01 string
				CONSTANT_True 0x0B -
				CONSTANT_False 0x0A -
				CONSTANT_Null 0x0C -
				CONSTANT_Undefined 0x00 -
				CONSTANT_Namespace 0x08 namespace
				CONSTANT_PackageNamespace 0x16 namespace
				CONSTANT_PackageInternalNs 0x17 Namespace
				CONSTANT_ProtectedNamespace 0x18 Namespace
				CONSTANT_ExplicitNamespace 0x19 Namespace
				CONSTANT_StaticProtectedNs 0x1A Namespace
				CONSTANT_PrivateNs 0x05 namespace
				*/
			}
		}
		
		private function getBodyIdFromMethodId(methodId:uint):int
		{
			return methodLookupCache[methodId];
		}
		
		public function namespaceToString(index:uint):String
		{
			var result:String = '';
			var ns:NamespaceToken = abcFile.cpool.namespaces[index];
			if(ns.kind == 0x05)
			{
				result = 'private';
			}
			else if(ns.kind == 0x17)
			{
				result = 'internal';
			}
			else if(ns.kind == 0x18 || ns.kind == 0x1A)
			{
				result = 'protected';
			}
			else
			{
				result = abcFile.cpool.strings[ns.name].utf8;
			}
			return result;
		}
		
		private function instructionsToString(instructions:Vector.<IInstruction>):String
		{
			var lines:Array = [];
			for each(var instruction:IInstruction in instructions)
			{
				var description:XML = describeType(instruction);
				var string:String = String(description.@name).replace(/.*Instruction_/, '');
				
				var params:Array = [];
				for each(var name:String in description.variable.@name)
				{
					params.push(name+': '+instruction[name]);
					//props[name] = variable[name];
				}
				string += '  ' + params.join(', ');
				
				lines.push(string);
				//lines.push(ObjectUtil.objectToString(instruction, 4, 10, 100, 10, '	'));
			}
			return lines.join('\n			');;
		}
		
		public function traitToString(r:ReadableTrait):String
		{
			var pieces:Array = [r.declaration.namespace+' '];
			if(r.traitType == ReadableTrait.TYPE_METHOD)
			{
				if(r.isStatic)
				{
					pieces.push('static ');
				}
				pieces.push('function ');
			}
			else if(r.traitType == ReadableTrait.TYPE_NAMESPACE)
			{
				pieces.push('namespace ');
				pieces.push(r.declaration.name+':'+multinameTypeToString(r.type));
				if(r.initializer)
				{
					pieces.push(' = '+r.initializer);
				}				
				pieces.push(';');
			}
			else if(r.traitType == ReadableTrait.TYPE_PROPERTY)
			{
				if(r.isStatic)
				{
					pieces.push('static ');
				}
				if(r.isConst)
				{
					pieces.push('const ');
				}
				else
				{
					pieces.push('var ');
				}
				pieces.push(r.declaration.name+':'+multinameTypeToString(r.type));
				if(r.initializer)
				{
					pieces.push(' = '+r.initializer);
				}				
				pieces.push(';');
			}
			else
			{
				trace('undefined trait type: '+r.traitType);
				pieces = [];
			}
			if(r.traitType == ReadableTrait.TYPE_METHOD)
			{
				var args:Array = [];
				for(var iter:uint = 0; iter < r.arguments.length; iter++)
				{
					args.push('arg' + iter + ':' + multinameTypeToString(r.arguments[iter]));
				}
				pieces.push(r.declaration.name);
				pieces.push('('+args.join(', ')+')');
				pieces.push(':'+multinameTypeToString(r.type));
				
				if(r.instructions && r.instructions.length > 0)
				{
					pieces.push('\n		{\n			'+instructionsToString(r.instructions)+'\n		}');
				}
				else
				{
					pieces.push(' {}');
				}
			}
			return pieces.join('');
		}
		
		public function multinameTraitToString(index:uint, r:ReadableMultiname):void
		{
			getReadableMultiname(index, r);
			if(customNamespaces[r.namespace])
			{
				r.namespace = customNamespaces[r.namespace];
			}
			if(r.namespace ==  '')
			{
				r.namespace = 'public';
			}
		}
		
		public function multinameTypeToString(r:ReadableMultiname):String
		{
			var result:String = '';
			if(customNamespaces[r.namespace])
			{
				r.namespace = customNamespaces[r.namespace];
			}
			if(r.namespace == '')
			{
				result = r.name;
			}
			else
			{
				result = r.namespace + '::' + r.name;
			}
			return result;
		}
		
		public function classToString(c:ReadableClass):String
		{
			var properties:Array = [];
			for(var iter:String in c.traits)
			{
				properties.push(traitToString(c.traits[iter]));
			}
			var result:String = 
'package '+c.className.namespace+'\n' +
'{\n' +
'	public class '+c.className.name+' extends '+c.superName.namespace+'::'+c.superName.name+'\n' +
'	{\n' +
'		' + properties.join('\n		') + '\n' +
'	}\n' +
'}';
			return result;
			/*
			var template:String = 'package {packageName} { public class {className}}}';
			return StringUtil.namedSubstitute(template, 
				{
					packageName: c.className.namespace,
					className: c.className.name,
					properties: properties.join('\n')
				});
			*/
		}
	}
}