package com.swfwire.decompiler.abc
{
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.*;
	import com.swfwire.decompiler.abc.tokens.multinames.*;
	import com.swfwire.decompiler.abc.tokens.traits.*;
	import com.swfwire.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	public class ABCWriter extends ABCInstructionWriter
	{
		private static const filter4:uint = (1 << 4) - 1;
		
		public function write(abcFile:ABCFile):ABCWriteResult
		{
			var iter:uint;
			
			var byteArray:ByteArray = new ByteArray();
			
			var bytes:ABCByteArray = new ABCByteArray(byteArray);
			
			var result:ABCWriteResult = new ABCWriteResult();
			
			var context:ABCWriterContext = new ABCWriterContext(bytes, result);
			
			bytes.writeU16(abcFile.minorVersion);
			bytes.writeU16(abcFile.majorVersion);
			
			writeConstantPoolToken(context, abcFile.cpool);
			
			bytes.writeU30(abcFile.methods.length);
			for(iter = 0; iter < abcFile.methods.length; iter++)
			{
				writeMethodInfoToken(context, abcFile.methods[iter]);
			}
			
			bytes.writeU30(abcFile.metadata.length);
			for(iter = 0; iter < abcFile.metadata.length; iter++)
			{
				writeMetadataInfoToken(context, abcFile.metadata[iter]);
			}
			
			bytes.writeU30(abcFile.classes.length);
			for(iter = 0; iter < abcFile.classes.length; iter++)
			{
				writeInstanceToken(context, abcFile.instances[iter]);
			}
			
			for(iter = 0; iter < abcFile.classes.length; iter++)
			{
				writeClassInfoToken(context, abcFile.classes[iter]);
			}
			
			bytes.writeU30(abcFile.scripts.length);
			for(iter = 0; iter < abcFile.scripts.length; iter++)
			{
				writeScriptInfoToken(context, abcFile.scripts[iter]);
			}
			
			bytes.writeU30(abcFile.methodBodies.length);
			for(iter = 0; iter < abcFile.methodBodies.length; iter++)
			{
				writeMethodBody(abcFile.methodBodies[iter]);
				writeMethodBodyInfoToken(context, abcFile.methodBodies[iter]);
			}
			
			result.bytes = byteArray;
			
			return result;
		}
		
		private function writeConstantPoolToken(context:ABCWriterContext, token:ConstantPoolToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			var iter:uint;
			
			bytes.writeU30(token.integers.length == 1 ? 0 : token.integers.length);
			for(iter = 1; iter < token.integers.length; iter++)
			{
				bytes.writeS32(token.integers[iter]);
			}
			
			bytes.writeU30(token.uintegers.length == 1 ? 0 : token.uintegers.length);
			for(iter = 1; iter < token.uintegers.length; iter++)
			{
				bytes.writeU32(token.uintegers[iter]);
			}
			
			bytes.writeU30(token.doubles.length == 1 ? 0 : token.doubles.length);
			for(iter = 1; iter < token.doubles.length; iter++)
			{
				bytes.writeD64(token.doubles[iter])
			}
			
			bytes.writeU30(token.strings.length == 1 ? 0 : token.strings.length);
			for(iter = 1; iter < token.strings.length; iter++)
			{
				writeStringToken(context, token.strings[iter]);
			}
			
			bytes.writeU30(token.namespaces.length == 1 ? 0 : token.namespaces.length);
			for(iter = 1; iter < token.namespaces.length; iter++)
			{
				writeNamespaceToken(context, token.namespaces[iter]);
			}
			
			bytes.writeU30(token.nsSets.length == 1 ? 0 : token.nsSets.length);
			for(iter = 1; iter < token.nsSets.length; iter++)
			{
				writeNamespaceSetToken(context, token.nsSets[iter]);
			}
			
			bytes.writeU30(token.multinames.length == 1 ? 0 : token.multinames.length);
			for(iter = 1; iter < token.multinames.length; iter++)
			{
				writeMultinameToken(context, token.multinames[iter]);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}		
		
		private function writeStringToken(context:ABCWriterContext, token:StringToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			var size:uint = ByteArrayUtil.getUTF8Length(token.utf8);
			bytes.writeU30(size);
			bytes.writeString(token.utf8);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeNamespaceToken(context:ABCWriterContext, token:NamespaceToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU8(token.kind);
			bytes.writeU30(token.name);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeNamespaceSetToken(context:ABCWriterContext, token:NamespaceSetToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.count);
			
			var iter:uint;
			
			var l:uint = token.namespaces.length;
			
			for(iter = 0; iter < l; iter++)
			{
				var namespaceId:uint = token.namespaces[iter];
				bytes.writeU30(namespaceId);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMultinameToken(context:ABCWriterContext, token:MultinameToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU8(token.kind);
			
			switch(token.kind)
			{
				case MultinameToken.KIND_QName:
				case MultinameToken.KIND_QNameA:
					writeMultinameQNameToken(context, MultinameQNameToken(token.data));
					break;
				case MultinameToken.KIND_RTQName:
				case MultinameToken.KIND_RTQNameA:
					writeMultinameRTQNameToken(context, MultinameRTQNameToken(token.data));
					break;
				case MultinameToken.KIND_RTQNameL:
				case MultinameToken.KIND_RTQNameLA:
					writeMultinameRTQNameLToken(context, MultinameRTQNameLToken(token.data));
					break;
				case MultinameToken.KIND_Multiname:
				case MultinameToken.KIND_MultinameA:
					writeMultinameMultinameToken(context, MultinameMultinameToken(token.data));
					break;
				case MultinameToken.KIND_MultinameL:
				case MultinameToken.KIND_MultinameLA:
					writeMultinameMultinameLToken(context, MultinameMultinameLToken(token.data));
					break;
				case MultinameToken.KIND_TypeName:
					writeMultinameTypeNameToken(context, MultinameTypeNameToken(token.data));
					break;
				default:
					throw new Error('Unknown multiname kind: '+token.kind);
					break;
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMultinameQNameToken(context:ABCWriterContext, token:MultinameQNameToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.ns);
			bytes.writeU30(token.name);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMultinameRTQNameToken(context:ABCWriterContext, token:MultinameRTQNameToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.name);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMultinameRTQNameLToken(context:ABCWriterContext, token:MultinameRTQNameLToken):void
		{
		}
		
		private function writeMultinameMultinameToken(context:ABCWriterContext, token:MultinameMultinameToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.name);
			bytes.writeU30(token.nsSet);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMultinameMultinameLToken(context:ABCWriterContext, token:MultinameMultinameLToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.nsSet);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMultinameTypeNameToken(context:ABCWriterContext, token:MultinameTypeNameToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.name);
			bytes.writeU30(token.count);
			bytes.writeU30(token.subType);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMethodInfoToken(context:ABCWriterContext, token:MethodInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			var iter:uint;
			
			bytes.writeU30(token.paramTypes.length);
			bytes.writeU30(token.returnType);
			for(iter = 0; iter < token.paramTypes.length; iter++)
			{
				bytes.writeU30(token.paramTypes[iter]);
			}
			bytes.writeU30(token.name);
			bytes.writeU8(token.flags);
			if(token.flags & MethodInfoToken.FLAG_HAS_OPTIONAL)
			{
				writeOptionInfoToken(context, token.options);
			}
			if(token.flags & MethodInfoToken.FLAG_HAS_PARAM_NAMES)
			{
				for(iter = 0; iter < token.paramCount; iter++)
				{
					writeParamInfoToken(context, token.paramNames[iter]);
				}
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeParamInfoToken(context:ABCWriterContext, token:ParamInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.value);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMetadataInfoToken(context:ABCWriterContext, token:MetadataInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.name);
			bytes.writeU30(token.itemCount);
			var iter:uint = 0;
			for(iter = 0; iter < token.items.length; iter++)
			{
				writeItemInfoToken(context, token.items[iter]);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);

		}
		
		private function writeItemInfoToken(context:ABCWriterContext, token:ItemInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.key);
			bytes.writeU30(token.value);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeInstanceToken(context:ABCWriterContext, token:InstanceToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.name);
			bytes.writeU30(token.superName);
			bytes.writeU8(token.flags);
			if(token.flags & InstanceToken.FLAG_CLASS_PROTECTED_NS)
			{
				bytes.writeU30(token.protectedNs);
			}
			bytes.writeU30(token.interfaces.length);
			var iter:uint;
			for(iter = 0; iter < token.interfaces.length; iter++)
			{
				bytes.writeU30(token.interfaces[iter]);
			}
			bytes.writeU30(token.iinit);
			bytes.writeU30(token.traits.length);
			for(iter = 0; iter < token.traits.length; iter++)
			{
				writeTraitsInfoToken(context, token.traits[iter]);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeTraitsInfoToken(context:ABCWriterContext, token:TraitsInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			var iter:uint;
			
			bytes.writeU30(token.name);
			
			var kindAndAttributes:uint = 0;
			kindAndAttributes = (token.attributes << 4) | (token.kind & filter4);
			
			bytes.writeU8(kindAndAttributes);
			
			switch(token.kind)
			{
				case TraitsInfoToken.KIND_TRAIT_SLOT:
				case TraitsInfoToken.KIND_TRAIT_CONST:
					writeTraitSlotToken(context, TraitSlotToken(token.data));
					break;
				case TraitsInfoToken.KIND_TRAIT_METHOD:
				case TraitsInfoToken.KIND_TRAIT_GETTER:
				case TraitsInfoToken.KIND_TRAIT_SETTER:
					writeTraitMethodToken(context, TraitMethodToken(token.data));
					break;
				case TraitsInfoToken.KIND_TRAIT_CLASS:
					writeTraitClassToken(context, TraitClassToken(token.data));
					break;
				case TraitsInfoToken.KIND_TRAIT_FUNCTION:
					writeTraitFunctionToken(context, TraitFunctionToken(token.data));
					break;
				default:
					throw new Error('Invalid trait kind: '+token.kind);
					break;
			}
			
			if(token.attributes & TraitsInfoToken.ATTRIBUTE_METADATA)
			{
				bytes.writeU30(token.metadata.length);
				for(iter = 0; iter < token.metadata.length; iter++)
				{
					bytes.writeU30(token.metadata[iter]);
				}
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeTraitSlotToken(context:ABCWriterContext, token:TraitSlotToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.slotId);
			bytes.writeU30(token.typeName);
			bytes.writeU30(token.vIndex);
			
			if(token.vIndex)
			{
				bytes.writeU8(token.vKind);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeTraitMethodToken(context:ABCWriterContext, token:TraitMethodToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.dispId);
			bytes.writeU30(token.methodId);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeTraitClassToken(context:ABCWriterContext, token:TraitClassToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.slotId);
			bytes.writeU30(token.classId);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeTraitFunctionToken(context:ABCWriterContext, token:TraitFunctionToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.slotId);
			bytes.writeU30(token.functionId);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeClassInfoToken(context:ABCWriterContext, token:ClassInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			var iter:uint;
			bytes.writeU30(token.cinit);
			bytes.writeU30(token.traits.length);
			for(iter = 0; iter < token.traits.length; iter++)
			{
				writeTraitsInfoToken(context, token.traits[iter]);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeScriptInfoToken(context:ABCWriterContext, token:ScriptInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			var iter:uint;
			bytes.writeU30(token.init);
			bytes.writeU30(token.traitCount);
			for(iter = 0; iter < token.traits.length; iter++)
			{
				writeTraitsInfoToken(context, token.traits[iter]);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMethodBodyInfoToken(context:ABCWriterContext, token:MethodBodyInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			var iter:uint;
			bytes.writeU30(token.method);
			bytes.writeU30(token.maxStack);
			bytes.writeU30(token.localCount);
			bytes.writeU30(token.initScopeDepth);
			bytes.writeU30(token.maxScopeDepth);
			bytes.writeU30(token.code.length);
			if(token.code.length > 0)
			{
				bytes.writeBytes(token.code, 0, token.code.length);
			}
			bytes.writeU30(token.exceptionCount);
			for(iter = 0; iter < token.exceptions.length; iter++)
			{
				writeExceptionInfoToken(context, token.exceptions[iter]);
			}
			bytes.writeU30(token.traitCount);
			for(iter = 0; iter < token.traits.length; iter++)
			{
				writeTraitsInfoToken(context, token.traits[iter]);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeExceptionInfoToken(context:ABCWriterContext, token:ExceptionInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.from);
			bytes.writeU30(token.to);
			bytes.writeU30(token.target);
			bytes.writeU30(token.excType);
			bytes.writeU30(token.varName);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeOptionInfoToken(context:ABCWriterContext, token:OptionInfoToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.options.length);
			for(var iter:uint = 0; iter < token.options.length; iter++)
			{
				writeOptionDetailToken(context, token.options[iter]);
			}
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeOptionDetailToken(context:ABCWriterContext, token:OptionDetailToken):void
		{
			var bytes:ABCByteArray = context.bytes;
			var start:uint = bytes.getBytePosition();
			var startTime:int = getTimer();
			
			bytes.writeU30(token.val);
			bytes.writeU8(token.kind);
			
			context.result.metadata.setData(token, start, bytes.getBytePosition(), getTimer() - startTime);
		}
		
		private function writeMethodBody(methodBody:MethodBodyInfoToken):void
		{
			var bytes:ByteArray = new ByteArray();
			
			var abc:ABCByteArray = new ABCByteArray(bytes);
			
			var position:uint = 0;
			var endPosition:uint = 0;
			var offsetLookup:Dictionary = new Dictionary();
			var lengthLookup:Dictionary = new Dictionary();
			
			for(var iter:uint = 0; iter < methodBody.instructions.length; iter++)
			{
				var instruction:IInstruction = methodBody.instructions[iter];
				
				var InstructionClass:Class = Object(instruction).constructor;
				var id:uint = ABCInstructions.getId(InstructionClass);
				
				position = abc.getBytePosition();
				
				if(InstructionClass != EndInstruction && InstructionClass != UnknownInstruction)
				{
					abc.writeU8(id);
				}
				writeInstruction(abc, instruction);
				
				endPosition = abc.getBytePosition();
				
				offsetLookup[instruction] = position;
				lengthLookup[instruction] = endPosition - position;
			}
			
			for(var iter2:uint = 0; iter2 < methodBody.instructions.length; iter2++)
			{
				var instruction2:IInstruction = methodBody.instructions[iter2];
				
				abc.setBytePosition(offsetLookup[instruction2] + 1);
				
				writeInstruction2(abc, instruction2, offsetLookup, lengthLookup);
			}
			
			for(var iter3:uint = 0; iter3 < methodBody.exceptions.length; iter3++)
			{
				var ex:ExceptionInfoToken = methodBody.exceptions[iter3];
				ex.from = offsetLookup[ex.fromRef];
				ex.to = offsetLookup[ex.toRef];
				ex.target = offsetLookup[ex.targetRef];
			}
			
			methodBody.code = bytes;
		}
	}
}