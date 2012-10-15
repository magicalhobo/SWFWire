package com.swfwire.decompiler.abc
{
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.*;
	import com.swfwire.decompiler.abc.tokens.multinames.*;
	import com.swfwire.decompiler.abc.tokens.traits.*;
	import com.swfwire.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	public class ABCReader extends ABCInstructionReader
	{
		private static const filter4:uint = (1 << 4) - 1;
		
		public function read(bytes:ABCByteArray):ABCReadResult
		{
			var iter:uint;
			
			var abcFile:ABCFile = new ABCFile();
			
			var result:ABCReadResult = new ABCReadResult(abcFile);

			var context:ABCReaderContext = new ABCReaderContext(bytes, result);
			
			abcFile.minorVersion = bytes.readU16();
			abcFile.majorVersion = bytes.readU16();
			
			abcFile.cpool = readConstantPoolToken(context);
			
			abcFile.methodCount = bytes.readU30();
			abcFile.methods = new Vector.<MethodInfoToken>(abcFile.methodCount);
			for(iter = 0; iter < abcFile.methodCount; iter++)
			{
				abcFile.methods[iter] = readMethodInfoToken(context);
			}
			
			abcFile.metadataCount = bytes.readU30();
			abcFile.metadata = new Vector.<MetadataInfoToken>(abcFile.metadataCount);
			for(iter = 0; iter < abcFile.metadataCount; iter++)
			{
				abcFile.metadata[iter] = readMetadataInfoToken(context);
			}
			
			abcFile.classCount = bytes.readU30();
			abcFile.instances = new Vector.<InstanceToken>(abcFile.classCount);
			for(iter = 0; iter < abcFile.classCount; iter++)
			{
				abcFile.instances[iter] = readInstanceToken(context);
			}
			
			abcFile.classes = new Vector.<ClassInfoToken>(abcFile.classCount);
			for(iter = 0; iter < abcFile.classCount; iter++)
			{
				abcFile.classes[iter] = readClassInfoToken(context);
			}
			
			abcFile.scriptCount = bytes.readU30();
			abcFile.scripts = new Vector.<ScriptInfoToken>(abcFile.scriptCount);
			for(iter = 0; iter < abcFile.scriptCount; iter++)
			{
				abcFile.scripts[iter] = readScriptInfoToken(context);
			}
			
			abcFile.methodBodyCount = bytes.readU30();
			abcFile.methodBodies = new Vector.<MethodBodyInfoToken>(abcFile.methodBodyCount);
			for(iter = 0; iter < abcFile.methodBodyCount; iter++)
			{
				abcFile.methodBodies[iter] = readMethodBodyInfoToken(context);
			}
			
			for(iter = 0; iter < abcFile.methodBodies.length; iter++)
			{
				var methodBody:MethodBodyInfoToken = abcFile.methodBodies[iter];
				var methodBodyResult:MethodBodyReadResult = readMethodBody(methodBody);
				methodBody.instructions = methodBodyResult.instructions;
				result.metadata.idFromOffset[iter] = methodBodyResult.offsetFromId;
				result.metadata.offsetFromId[iter] = methodBodyResult.idFromOffset;
			}
			
			return result;
		}
		
		private function readConstantPoolToken(context:ABCReaderContext):ConstantPoolToken
		{
			var bytes:ABCByteArray = context.bytes;
			var metadata:ABCReaderMetadata = context.result.metadata;
			
			var constantPoolToken:ConstantPoolToken = new ConstantPoolToken();
			
			var iter:uint;
			
			var intCount:uint = bytes.readU30();
			constantPoolToken.integers = new Vector.<int>(intCount);
			constantPoolToken.integers[0] = 0;
			for(iter = 1; iter < intCount; iter++)
			{
				constantPoolToken.integers[iter] = bytes.readS32();
			}
			
			var uintCount:uint = bytes.readU30();
			constantPoolToken.uintegers = new Vector.<uint>(uintCount);
			constantPoolToken.uintegers[0] = 0;
			for(iter = 1; iter < uintCount; iter++)
			{
				constantPoolToken.uintegers[iter] = bytes.readU32();
			}
			
			var doubleCount:uint = bytes.readU30();
			constantPoolToken.doubles = new Vector.<Number>(doubleCount);
			constantPoolToken.doubles[0] = 0;
			for(iter = 1; iter < doubleCount; iter++)
			{
				constantPoolToken.doubles[iter] = bytes.readD64();
			}
			
			var stringCount:uint = bytes.readU30();
			constantPoolToken.strings = new Vector.<StringToken>(stringCount);
			constantPoolToken.strings[0] = new StringToken();
			for(iter = 1; iter < stringCount; iter++)
			{
				constantPoolToken.strings[iter] = readStringToken(context);
			}
			
			var namespaceCount:uint = bytes.readU30();
			constantPoolToken.namespaces = new Vector.<NamespaceToken>(namespaceCount);
			constantPoolToken.namespaces[0] = new NamespaceToken();
			for(iter = 1; iter < namespaceCount; iter++)
			{
				constantPoolToken.namespaces[iter] = readNamespaceToken(context);
			}
			
			var nsSetCount:uint = bytes.readU30();
			constantPoolToken.nsSets = new Vector.<NamespaceSetToken>(nsSetCount);
			constantPoolToken.nsSets[0] = new NamespaceSetToken();
			for(iter = 1; iter < nsSetCount; iter++)
			{
				constantPoolToken.nsSets[iter] = readNamespaceSetToken(context);
			}
			
			var multinameCount:uint = bytes.readU30();
			constantPoolToken.multinames = new Vector.<MultinameToken>(multinameCount);
			constantPoolToken.multinames[0] = new MultinameToken();
			for(iter = 1; iter < multinameCount; iter++)
			{
				constantPoolToken.multinames[iter] = readMultinameToken(context);
			}
			
			return constantPoolToken;
		}		
		
		private function readStringToken(context:ABCReaderContext):StringToken
		{
			var bytes:ABCByteArray = context.bytes;

			var string:StringToken = new StringToken();
			
			var size:uint = bytes.readU30();
			string.utf8 = bytes.readString(size);
			
			return string;
		}
		
		private function readNamespaceToken(context:ABCReaderContext):NamespaceToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var namespaceToken:NamespaceToken = new NamespaceToken();
			
			namespaceToken.kind = bytes.readU8();
			namespaceToken.name = bytes.readU30();
			
			return namespaceToken;
		}
		
		private function readNamespaceSetToken(context:ABCReaderContext):NamespaceSetToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var nsSet:NamespaceSetToken = new NamespaceSetToken();
			
			nsSet.count = bytes.readU30();
			nsSet.namespaces = new Vector.<uint>(nsSet.count);
			var iter:uint;
			for(iter = 0; iter < nsSet.count; iter++)
			{
				var namespaceId:uint = bytes.readU30();
				if(namespaceId == 0)
				{
					throw new Error('A namespace entry may not be 0');
				}
				nsSet.namespaces[iter] = namespaceId;
			}
			
			return nsSet;
		}
		
		private function readMultinameToken(context:ABCReaderContext):MultinameToken
		{
			var bytes:ABCByteArray = context.bytes;

			var multiname:MultinameToken = new MultinameToken();
			
			multiname.kind = bytes.readU8();
			
			switch(multiname.kind)
			{
				case MultinameToken.KIND_QName:
				case MultinameToken.KIND_QNameA:
					multiname.data = readMultinameQNameToken(context);
					break;
				case MultinameToken.KIND_RTQName:
				case MultinameToken.KIND_RTQNameA:
					multiname.data = readMultinameRTQNameToken(context);
					break;
				case MultinameToken.KIND_RTQNameL:
				case MultinameToken.KIND_RTQNameLA:
					multiname.data = readMultinameRTQNameLToken(context);
					break;
				case MultinameToken.KIND_Multiname:
				case MultinameToken.KIND_MultinameA:
					multiname.data = readMultinameMultinameToken(context);
					break;
				case MultinameToken.KIND_MultinameL:
				case MultinameToken.KIND_MultinameLA:
					multiname.data = readMultinameMultinameLToken(context);
					break;
				case MultinameToken.KIND_TypeName:
					multiname.data = readMultinameTypeNameToken(context);
					break;
				default:
					throw new Error('Unknown multiname kind: '+multiname.kind);
					break;
			}
			
			return multiname;
		}
		
		private function readMultinameQNameToken(context:ABCReaderContext):MultinameQNameToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:MultinameQNameToken = new MultinameQNameToken();
			
			token.ns = bytes.readU30();
			token.name = bytes.readU30();
			
			return token;
		}
		
		private function readMultinameRTQNameToken(context:ABCReaderContext):MultinameRTQNameToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:MultinameRTQNameToken = new MultinameRTQNameToken();
			
			token.name = bytes.readU30();
			
			return token;
		}
		
		private function readMultinameRTQNameLToken(context:ABCReaderContext):MultinameRTQNameLToken
		{
			return new MultinameRTQNameLToken();
		}
		
		private function readMultinameMultinameToken(context:ABCReaderContext):MultinameMultinameToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:MultinameMultinameToken = new MultinameMultinameToken();
			
			token.name = bytes.readU30();
			token.nsSet = bytes.readU30();
			
			return token;
		}
		
		private function readMultinameMultinameLToken(context:ABCReaderContext):MultinameMultinameLToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:MultinameMultinameLToken = new MultinameMultinameLToken();
			
			token.nsSet = bytes.readU30();
			
			return token;
		}
		
		private function readMultinameTypeNameToken(context:ABCReaderContext):MultinameTypeNameToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:MultinameTypeNameToken = new MultinameTypeNameToken();
			
			token.name = bytes.readU30();
			token.count = bytes.readU30();
			token.subType = bytes.readU30();
			
			return token;
		}
		
		private function readMethodInfoToken(context:ABCReaderContext):MethodInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var methodInfoToken:MethodInfoToken = new MethodInfoToken();

			var iter:uint;
			
			methodInfoToken.paramCount = bytes.readU30();
			methodInfoToken.returnType = bytes.readU30();
			methodInfoToken.paramTypes = new Vector.<uint>(methodInfoToken.paramCount);
			for(iter = 0; iter < methodInfoToken.paramCount; iter++)
			{
				methodInfoToken.paramTypes[iter] = bytes.readU30();
			}
			methodInfoToken.name = bytes.readU30();
			methodInfoToken.flags = bytes.readU8();
			if(methodInfoToken.flags & MethodInfoToken.FLAG_HAS_OPTIONAL)
			{
				methodInfoToken.options = readOptionInfoToken(context);
			}
			methodInfoToken.paramNames = new Vector.<ParamInfoToken>(methodInfoToken.paramCount);
			if(methodInfoToken.flags & MethodInfoToken.FLAG_HAS_PARAM_NAMES)
			{
				for(iter = 0; iter < methodInfoToken.paramCount; iter++)
				{
					methodInfoToken.paramNames[iter] = readParamInfoToken(context);
				}
			}
			
			return methodInfoToken;
		}
		
		private function readParamInfoToken(context:ABCReaderContext):ParamInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var paramInfoToken:ParamInfoToken = new ParamInfoToken();
			
			paramInfoToken.value = bytes.readU30();
			
			return paramInfoToken
		}
		
		private function readMetadataInfoToken(context:ABCReaderContext):MetadataInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var metadataInfoToken:MetadataInfoToken = new MetadataInfoToken();
			
			metadataInfoToken.name = bytes.readU30();
			metadataInfoToken.itemCount = bytes.readU30();
			metadataInfoToken.items = new Vector.<ItemInfoToken>(metadataInfoToken.itemCount);
			var iter:uint = 0;
			for(iter = 0; iter < metadataInfoToken.itemCount; iter++)
			{
				metadataInfoToken.items[iter] = readItemInfoToken(context);
			}
			
			return metadataInfoToken;
		}
		
		private function readItemInfoToken(context:ABCReaderContext):ItemInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var item:ItemInfoToken = new ItemInfoToken();
			item.key = bytes.readU30();
			item.value = bytes.readU30();
			return item;
		}
		
		private function readInstanceToken(context:ABCReaderContext):InstanceToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var instanceToken:InstanceToken = new InstanceToken();

			instanceToken.name = bytes.readU30();
			instanceToken.superName = bytes.readU30();
			instanceToken.flags = bytes.readU8();
			if(instanceToken.flags & InstanceToken.FLAG_CLASS_PROTECTED_NS)
			{
				instanceToken.protectedNs = bytes.readU30();
			}
			instanceToken.interfaceCount = bytes.readU30();
			var iter:uint;
			instanceToken.interfaces = new Vector.<uint>(instanceToken.interfaceCount);
			for(iter = 0; iter < instanceToken.interfaceCount; iter++)
			{
				instanceToken.interfaces[iter] = bytes.readU30();
			}
			instanceToken.iinit = bytes.readU30();
			instanceToken.traitCount = bytes.readU30();
			instanceToken.traits = new Vector.<TraitsInfoToken>(instanceToken.traitCount);
			for(iter = 0; iter < instanceToken.traitCount; iter++)
			{
				instanceToken.traits[iter] = readTraitsInfoToken(context);
			}
			
			return instanceToken;
		}
		
		private function readTraitsInfoToken(context:ABCReaderContext):TraitsInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var trait:TraitsInfoToken = new TraitsInfoToken();

			var iter:uint;
			
			trait.name = bytes.readU30();
			var kindAndAttributes:uint = bytes.readU8();
			
			trait.attributes = kindAndAttributes >> 4;
			trait.kind = kindAndAttributes & filter4;
			
			switch(trait.kind)
			{
				case TraitsInfoToken.KIND_TRAIT_SLOT:
				case TraitsInfoToken.KIND_TRAIT_CONST:
					trait.data = readTraitSlotToken(context);
					break;
				case TraitsInfoToken.KIND_TRAIT_METHOD:
				case TraitsInfoToken.KIND_TRAIT_GETTER:
				case TraitsInfoToken.KIND_TRAIT_SETTER:
					trait.data = readTraitMethodToken(context);
					break;
				case TraitsInfoToken.KIND_TRAIT_CLASS:
					trait.data = readTraitClassToken(context);
					break;
				case TraitsInfoToken.KIND_TRAIT_FUNCTION:
					trait.data = readTraitFunctionToken(context);
					break;
				default:
					throw new Error('Invalid trait kind: '+trait.kind);
					break;
			}
			
			if(trait.attributes & TraitsInfoToken.ATTRIBUTE_METADATA)
			{
				trait.metadataCount = bytes.readU30();
				trait.metadata = new Vector.<uint>(trait.metadataCount);
				for(iter = 0; iter < trait.metadataCount; iter++)
				{
					trait.metadata[iter] = bytes.readU30();
				}
			}
			
			return trait;
		}
		
		private function readTraitSlotToken(context:ABCReaderContext):TraitSlotToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:TraitSlotToken = new TraitSlotToken();
			
			token.slotId = bytes.readU30();
			token.typeName = bytes.readU30();
			token.vIndex = bytes.readU30();
			if(token.vIndex)
			{
				token.vKind = bytes.readU8();
			}
			
			return token;
		}
		
		private function readTraitMethodToken(context:ABCReaderContext):TraitMethodToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:TraitMethodToken = new TraitMethodToken();
			
			token.dispId = bytes.readU30();
			token.methodId = bytes.readU30();
			
			return token;
		}
		
		private function readTraitClassToken(context:ABCReaderContext):TraitClassToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:TraitClassToken = new TraitClassToken();
			
			token.slotId = bytes.readU30();
			token.classId = bytes.readU30();
			
			return token;
		}
		
		private function readTraitFunctionToken(context:ABCReaderContext):TraitFunctionToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var token:TraitFunctionToken = new TraitFunctionToken();
			
			token.slotId = bytes.readU30();
			token.functionId = bytes.readU30();
			
			return token;
		}
		
		private function readClassInfoToken(context:ABCReaderContext):ClassInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var classToken:ClassInfoToken = new ClassInfoToken();

			var iter:uint;
			classToken.cinit = bytes.readU30();
			classToken.traitCount = bytes.readU30();
			classToken.traits = new Vector.<TraitsInfoToken>(classToken.traitCount);
			for(iter = 0; iter < classToken.traitCount; iter++)
			{
				classToken.traits[iter] = readTraitsInfoToken(context);
			}
			
			return classToken;
		}
		
		private function readScriptInfoToken(context:ABCReaderContext):ScriptInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var scriptToken:ScriptInfoToken = new ScriptInfoToken();
			
			var iter:uint;
			scriptToken.init = bytes.readU30();
			scriptToken.traitCount = bytes.readU30();
			scriptToken.traits = new Vector.<TraitsInfoToken>();
			for(iter = 0; iter < scriptToken.traitCount; iter++)
			{
				scriptToken.traits[iter] = readTraitsInfoToken(context);
			}
			
			return scriptToken;
		}
		
		private function readMethodBodyInfoToken(context:ABCReaderContext):MethodBodyInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var methodBodyInfo:MethodBodyInfoToken = new MethodBodyInfoToken();
			
			var iter:uint;
			methodBodyInfo.method = bytes.readU30();
			methodBodyInfo.maxStack = bytes.readU30();
			methodBodyInfo.localCount = bytes.readU30();
			methodBodyInfo.initScopeDepth = bytes.readU30();
			methodBodyInfo.maxScopeDepth = bytes.readU30();
			methodBodyInfo.codeLength = bytes.readU30();
			methodBodyInfo.code = new ByteArray();
			if(methodBodyInfo.codeLength > 0)
			{
				bytes.readBytes(methodBodyInfo.code, 0, methodBodyInfo.codeLength);
			}
			
			methodBodyInfo.exceptionCount = bytes.readU30();
			methodBodyInfo.exceptions = new Vector.<ExceptionInfoToken>(methodBodyInfo.exceptionCount);
			for(iter = 0; iter < methodBodyInfo.exceptionCount; iter++)
			{
				methodBodyInfo.exceptions[iter] = readExceptionInfoToken(context);
			}
			methodBodyInfo.traitCount = bytes.readU30();
			methodBodyInfo.traits = new Vector.<TraitsInfoToken>(methodBodyInfo.traitCount);
			for(iter = 0; iter < methodBodyInfo.traitCount; iter++)
			{
				methodBodyInfo.traits[iter] = readTraitsInfoToken(context);
			}
			
			return methodBodyInfo;
		}
		
		private function readExceptionInfoToken(context:ABCReaderContext):ExceptionInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var exceptionInfo:ExceptionInfoToken = new ExceptionInfoToken();
			
			exceptionInfo.from = bytes.readU30();
			exceptionInfo.to = bytes.readU30();
			exceptionInfo.target = bytes.readU30();
			exceptionInfo.excType = bytes.readU30();
			exceptionInfo.varName = bytes.readU30();

			return exceptionInfo;
		}
		
		private function readOptionInfoToken(context:ABCReaderContext):OptionInfoToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var optionInfoToken:OptionInfoToken = new OptionInfoToken();
			
			optionInfoToken.optionCount = bytes.readU30();
			optionInfoToken.options = new Vector.<OptionDetailToken>(optionInfoToken.optionCount);
			for(var iter:uint = 0; iter < optionInfoToken.optionCount; iter++)
			{
				optionInfoToken.options[iter] = readOptionDetailToken(context);
			}
			
			return optionInfoToken;
		}
		
		private function readOptionDetailToken(context:ABCReaderContext):OptionDetailToken
		{
			var bytes:ABCByteArray = context.bytes;
			
			var option:OptionDetailToken = new OptionDetailToken();
			
			option.val = bytes.readU30();
			option.kind = bytes.readU8();
			
			return option;
		}
		
		private function readMethodBody(methodBody:MethodBodyInfoToken):MethodBodyReadResult
		{
			var bytes:ByteArray = methodBody.code;
			
			var abc:ABCByteArray = new ABCByteArray(bytes);
			
			var instructions:Vector.<IInstruction> = new Vector.<IInstruction>();
			
			bytes.position = 0;
			
			var invalid:Boolean = false;
			var dump:Array = [];
			var instructionId:int = 0;
			var offsetLookup:Object = {};
			var reverseOffsetLookup:Object = {};
			var lengthLookup:Object = {};
			var position:uint = 0;
			var newPosition:uint = 0;
			
			while(bytes.bytesAvailable > 0)
			{
				position = abc.getBytePosition();
				offsetLookup[instructionId] = position;
				reverseOffsetLookup[position] = instructionId;
				var opcode:uint = abc.readU8();
				var instruction:IInstruction = readInstruction(opcode, abc);
				if(instruction is UnknownInstruction)
				{
					invalid = true;
					dump.push('	Invalid instruction encountered ('+ByteArrayUtil.toHexString(opcode, 8)+') at id '+instructionId+'.');
				}
				instructions[instructionId] = instruction;
				newPosition = abc.getBytePosition();
				lengthLookup[instructionId] = newPosition - position;
				instructionId++;
			}
			instructions[instructionId] = new EndInstruction();
			offsetLookup[instructionId] = newPosition;
			reverseOffsetLookup[newPosition] = instructionId;
			lengthLookup[newPosition] = 0;
			
			if(invalid)
			{
				trace('Unknown instruction(s) encountered: \n' + dump.join('\n'));
			}
			
			function getRef(baseId:uint, offset:int):IInstruction
			{
				offset = offsetLookup[baseId] + offset;
				if(reverseOffsetLookup.hasOwnProperty(offset))
				{
					var id:uint = reverseOffsetLookup[offset];
					return instructions[id];
				}
				else
				{
					trace('Encountered an invalid branch.');
					return instructions[0];
					return null;
				}
			}
			
			for(var iter:uint = 0; iter < instructions.length; iter++)
			{
				var op:IInstruction = instructions[iter];
				var opLength:uint = lengthLookup[iter];
				
				var op_ifeq:Instruction_ifeq = op as Instruction_ifeq;
				if(op_ifeq)
				{
					op_ifeq.reference = getRef(iter, opLength + op_ifeq.offset);
				}
				
				var op_iffalse:Instruction_iffalse = op as Instruction_iffalse;
				if(op_iffalse)
				{
					op_iffalse.reference = getRef(iter, opLength + op_iffalse.offset);
				}
				
				var op_ifge:Instruction_ifge = op as Instruction_ifge;
				if(op_ifge)
				{
					op_ifge.reference = getRef(iter, opLength + op_ifge.offset);
				}
				
				var op_ifgt:Instruction_ifgt = op as Instruction_ifgt;
				if(op_ifgt)
				{
					op_ifgt.reference = getRef(iter, opLength + op_ifgt.offset);
				}
				
				var op_ifle:Instruction_ifle = op as Instruction_ifle;
				if(op_ifle)
				{
					op_ifle.reference = getRef(iter, opLength + op_ifle.offset);
				}
				
				var op_iflt:Instruction_iflt = op as Instruction_iflt;
				if(op_iflt)
				{
					op_iflt.reference = getRef(iter, opLength + op_iflt.offset);
				}
				
				var op_ifnge:Instruction_ifnge = op as Instruction_ifnge;
				if(op_ifnge)
				{
					op_ifnge.reference = getRef(iter, opLength + op_ifnge.offset);
				}
				
				var op_ifngt:Instruction_ifngt = op as Instruction_ifngt;
				if(op_ifngt)
				{
					op_ifngt.reference = getRef(iter, opLength + op_ifngt.offset);
				}
				
				var op_ifnle:Instruction_ifnle = op as Instruction_ifnle;
				if(op_ifnle)
				{
					op_ifnle.reference = getRef(iter, opLength + op_ifnle.offset);
				}
				
				var op_ifnlt:Instruction_ifnlt = op as Instruction_ifnlt;
				if(op_ifnlt)
				{
					op_ifnlt.reference = getRef(iter, opLength + op_ifnlt.offset);
				}
				
				var op_ifne:Instruction_ifne = op as Instruction_ifne;
				if(op_ifne)
				{
					op_ifne.reference = getRef(iter, opLength + op_ifne.offset);
				}
				
				var op_ifstricteq:Instruction_ifstricteq = op as Instruction_ifstricteq;
				if(op_ifstricteq)
				{
					op_ifstricteq.reference = getRef(iter, opLength + op_ifstricteq.offset);
				}
				
				var op_ifstrictne:Instruction_ifstrictne = op as Instruction_ifstrictne;
				if(op_ifstrictne)
				{
					op_ifstrictne.reference = getRef(iter, opLength + op_ifstrictne.offset);
				}
				
				var op_iftrue:Instruction_iftrue = op as Instruction_iftrue;
				if(op_iftrue)
				{
					op_iftrue.reference = getRef(iter, opLength + op_iftrue.offset);
				}
				
				var op_jump:Instruction_jump = op as Instruction_jump;
				if(op_jump)
				{
					op_jump.reference = getRef(iter, opLength + op_jump.offset);
				}
				
				var op_lookupswitch:Instruction_lookupswitch = op as Instruction_lookupswitch;
				if(op_lookupswitch)
				{
					op_lookupswitch.defaultReference = getRef(iter, op_lookupswitch.defaultOffset);
					op_lookupswitch.caseReferences = new Vector.<IInstruction>();
					
					for(var iter2:uint = 0; iter2 < op_lookupswitch.caseOffsets.length; iter2++)
					{
						op_lookupswitch.caseReferences[iter2] = getRef(iter, op_lookupswitch.caseOffsets[iter2]);
					}
				}
				
				for(var iter3:uint = 0; iter3 < methodBody.exceptions.length; iter3++)
				{
					var ex:ExceptionInfoToken = methodBody.exceptions[iter3];
					
					ex.fromRef = instructions[reverseOffsetLookup[ex.from]];
					ex.toRef = instructions[reverseOffsetLookup[ex.to]];
					ex.targetRef = instructions[reverseOffsetLookup[ex.target]];
				}
			}
			
			return new MethodBodyReadResult(instructions, offsetLookup, reverseOffsetLookup);
		}
	}
}