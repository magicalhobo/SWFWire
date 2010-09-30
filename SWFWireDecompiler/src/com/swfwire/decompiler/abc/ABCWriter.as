package com.swfwire.decompiler.abc
{
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.*;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class ABCWriter
	{
		public function write(abc:ABCFile):ABCWriteResult
		{
			var result:ABCWriteResult = new ABCWriteResult();
			
			var byteArray:ByteArray = new ByteArray();
			var bytes:ABCByteArray = new ABCByteArray(byteArray);
			
			bytes.writeU16(abc.minorVersion);
			bytes.writeU16(abc.majorVersion);
			
			abc.cpool.write(bytes);
			
			var iter:uint;
			
			bytes.writeU30(abc.methods.length);
			for(iter = 0; iter < abc.methods.length; iter++)
			{
				abc.methods[iter].write(bytes);
			}
			
			bytes.writeU30(abc.metadata.length);
			for(iter = 0; iter < abc.metadata.length; iter++)
			{
				abc.metadata[iter].write(bytes);
			}
			
			bytes.writeU30(abc.classes.length);
			for(iter = 0; iter < abc.classes.length; iter++)
			{
				abc.instances[iter].write(bytes);
			}
			
			for(iter = 0; iter < abc.classes.length; iter++)
			{
				abc.classes[iter].write(bytes);
			}
			
			bytes.writeU30(abc.scripts.length);
			for(iter = 0; iter < abc.scripts.length; iter++)
			{
				abc.scripts[iter].write(bytes);
			}
			
			bytes.writeU30(abc.methodBodies.length);
			for(iter = 0; iter < abc.methodBodies.length; iter++)
			{
				writeMethodBody(abc.methodBodies[iter]);
				abc.methodBodies[iter].write(bytes);
			}
			
			result.metadata = 'test';
			
			result.bytes = byteArray;
			
			return result;
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
		
		public function writeInstruction(abc:ABCByteArray, instruction:IInstruction):void
		{
			var op:* = instruction;

			switch(Object(instruction).constructor)
			{
				case EndInstruction:
				case Instruction_0x01:
				case Instruction_nop:
				case Instruction_throw:
				case Instruction_pushwith:
				case Instruction_popscope:
				case Instruction_nextname:
				case Instruction_hasnext:
				case Instruction_pushnull:
				case Instruction_pushundefined:
				case Instruction_nextvalue:
				case Instruction_pushtrue:
				case Instruction_pushfalse:
				case Instruction_pushnan:
				case Instruction_pop:
				case Instruction_dup:
				case Instruction_swap:
				case Instruction_returnvoid:
				case Instruction_returnvalue:
				case Instruction_newactivation:
				case Instruction_getglobalscope:
				case Instruction_convert_s:
				case Instruction_esc_xelem:
				case Instruction_esc_xattr:
				case Instruction_convert_i:
				case Instruction_convert_u:
				case Instruction_convert_d:
				case Instruction_convert_b:
				case Instruction_convert_o:
				case Instruction_checkfilter:
				case Instruction_coerce_b:
				case Instruction_coerce_a:
				case Instruction_coerce_i:
				case Instruction_coerce_d:
				case Instruction_coerce_s:
				case Instruction_astypelate:
				case Instruction_coerce_u:
				case Instruction_coerce_o:
				case Instruction_negate:
				case Instruction_increment:
				case Instruction_typeof:
				case Instruction_not:
				case Instruction_bitnot:
				case Instruction_add:
				case Instruction_subtract:
				case Instruction_multiply:
				case Instruction_divide:
				case Instruction_modulo:
				case Instruction_lshift:
				case Instruction_rshift:
				case Instruction_urshift:
				case Instruction_bitand:
				case Instruction_bitor:
				case Instruction_bitxor:
				case Instruction_equals:
				case Instruction_strictequals:
				case Instruction_lessthan:
				case Instruction_lessequals:
				case Instruction_greaterthan:
				case Instruction_greaterequals:
				case Instruction_instanceof:
				case Instruction_istypelate:
				case Instruction_in:
				case Instruction_increment_i:
				case Instruction_decrement_i:
				case Instruction_negate_i:
				case Instruction_add_i:
				case Instruction_subtract_i:
				case Instruction_multiply_i:
				case Instruction_getlocal0:
				case Instruction_getlocal1:
				case Instruction_getlocal2:
				case Instruction_getlocal3:
				case Instruction_setlocal0:
				case Instruction_setlocal1:
				case Instruction_setlocal2:
				case Instruction_setlocal3:
				case Instruction_dxnslate:
				case Instruction_label:
				case Instruction_pushscope:
				case Instruction_decrement:
				case Instruction_li8:
				case Instruction_li16:
				case Instruction_li32:
				case Instruction_lf32:
				case Instruction_lf64:
				case Instruction_si8:
				case Instruction_si16:
				case Instruction_si32:
				case Instruction_sf32:
				case Instruction_sf64:
				case Instruction_sxi1:
				case Instruction_sxi8:
				case Instruction_sxi16:
					break;
				case Instruction_getsuper:
					write_getsuper(op, abc);
					break;
				case Instruction_setsuper:
					write_setsuper(op, abc);
					break;
				case Instruction_dxns:
					write_dxns(op, abc);
					break;
				case Instruction_kill:
					write_kill(op, abc);
					break;
				case Instruction_ifnlt:
					write_ifnlt(op, abc);
					break;
				case Instruction_ifnle:
					write_ifnle(op, abc);
					break;
				case Instruction_ifngt:
					write_ifngt(op, abc);
					break;
				case Instruction_ifnge:
					write_ifnge(op, abc);
					break;
				case Instruction_jump:
					write_jump(op, abc);
					break;
				case Instruction_iftrue:
					write_iftrue(op, abc);
					break;
				case Instruction_iffalse:
					write_iffalse(op, abc);
					break;
				case Instruction_ifeq:
					write_ifeq(op, abc);
					break;
				case Instruction_ifne:
					write_ifne(op, abc);
					break;
				case Instruction_iflt:
					write_iflt(op, abc);
					break;
				case Instruction_ifle:
					write_ifle(op, abc);
					break;
				case Instruction_ifgt:
					write_ifgt(op, abc);
					break;
				case Instruction_ifge:
					write_ifge(op, abc);
					break;
				case Instruction_ifstricteq:
					write_ifstricteq(op, abc);
					break;
				case Instruction_ifstrictne:
					write_ifstrictne(op, abc);
					break;
				case Instruction_lookupswitch:
					write_lookupswitch(op, abc);
					break;
				case Instruction_pushbyte:
					write_pushbyte(op, abc);
					break;
				case Instruction_pushshort:
					write_pushshort(op, abc);
					break;
				case Instruction_pushstring:
					write_pushstring(op, abc);
					break;
				case Instruction_pushint:
					write_pushint(op, abc);
					break;
				case Instruction_pushuint:
					write_pushuint(op, abc);
					break;
				case Instruction_pushdouble:
					write_pushdouble(op, abc);
					break;
				case Instruction_pushnamespace:
					write_pushnamespace(op, abc);
					break;
				case Instruction_hasnext2:
					write_hasnext2(op, abc);
					break;
				case Instruction_newfunction:
					write_newfunction(op, abc);
					break;
				case Instruction_call:
					write_call(op, abc);
					break;
				case Instruction_construct:
					write_construct(op, abc);
					break;
				case Instruction_callmethod:
					write_callmethod(op, abc);
					break;
				case Instruction_callstatic:
					write_callstatic(op, abc);
					break;
				case Instruction_callsuper:
					write_callsuper(op, abc);
					break;
				case Instruction_callproperty:
					write_callproperty(op, abc);
					break;
				case Instruction_constructsuper:
					write_constructsuper(op, abc);
					break;
				case Instruction_constructprop:
					write_constructprop(op, abc);
					break;
				case Instruction_callproplex:
					write_callproplex(op, abc);
					break;
				case Instruction_callsupervoid:
					write_callsupervoid(op, abc);
					break;
				case Instruction_callpropvoid:
					write_callpropvoid(op, abc);
					break;
				case Instruction_applytype:
					write_applytype(op, abc);
					break;
				case Instruction_newobject:
					write_newobject(op, abc);
					break;
				case Instruction_newarray:
					write_newarray(op, abc);
					break;
				case Instruction_newclass:
					write_newclass(op, abc);
					break;
				case Instruction_getdescendants:
					write_getdescendants(op, abc);
					break;
				case Instruction_newcatch:
					write_newcatch(op, abc);
					break;
				case Instruction_findpropglobalstrict:
					write_findpropglobalstrict(op, abc);
					break;
				case Instruction_findpropglobal:
					write_findpropglobal(op, abc);
					break;
				case Instruction_findpropstrict:
					write_findpropstrict(op, abc);
					break;
				case Instruction_findproperty:
					write_findproperty(op, abc);
					break;
				case Instruction_finddef:
					write_finddef(op, abc);
					break;  
				case Instruction_getlex:
					write_getlex(op, abc);
					break;
				case Instruction_setproperty:
					write_setproperty(op, abc);
					break;
				case Instruction_getlocal:
					write_getlocal(op, abc);
					break;
				case Instruction_setlocal:
					write_setlocal(op, abc);
					break;
				case Instruction_getscopeobject:
					write_getscopeobject(op, abc);
					break;
				case Instruction_getproperty:
					write_getproperty(op, abc);
					break;
				case Instruction_getouterscope:
					write_getouterscope(op, abc);
					break;
				case Instruction_initproperty:
					write_initproperty(op, abc);
					break;
				case Instruction_deleteproperty:
					write_deleteproperty(op, abc);
					break;
				case Instruction_getslot:
					write_getslot(op, abc);
					break;
				case Instruction_setslot:
					write_setslot(op, abc);
					break;
				case Instruction_getglobalslot:
					write_getglobalslot(op, abc);
					break;
				case Instruction_setglobalslot:
					write_setglobalslot(op, abc);
					break;
				case Instruction_coerce:
					write_coerce(op, abc);
					break;
				case Instruction_astype:
					write_astype(op, abc);
					break;
				case Instruction_inclocal:
					write_inclocal(op, abc);
					break;
				case Instruction_declocal:
					write_declocal(op, abc);
					break;
				case Instruction_istype:
					write_istype(op, abc);
					break;
				case Instruction_inclocal_i:
					write_inclocal_i(op, abc);
					break;
				case Instruction_declocal_i:
					write_declocal_i(op, abc);
					break;
				case Instruction_debug:
					write_debug(op, abc);
					break;
				case Instruction_debugline:
					write_debugline(op, abc);
					break;
				case Instruction_debugfile:
					write_debugfile(op, abc);
					break;
				case Instruction_0xF2:
					write_0xF2(op, abc);
					break;
				case UnknownInstruction:
					writeUnknown(op, abc);
					break;
				default:
					throw new Error('uh oh, can\'t write: '+getQualifiedClassName(op));
					break;
			}
		}
		
		public function writeInstruction2(abc:ABCByteArray, instruction:IInstruction, offsetLookup:Dictionary, lengthLookup:Dictionary):void
		{
			var op:* = instruction;
			var baseOffset:uint = offsetLookup[op];
			var opLength:uint = lengthLookup[op];
			var offset:int;
			
			switch(op.constructor)
			{
				case Instruction_ifeq:
					var op_ifeq:Instruction_ifeq = op as Instruction_ifeq;
					offset = offsetLookup[op_ifeq.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_iffalse:
					var op_iffalse:Instruction_iffalse = op as Instruction_iffalse;
					offset = offsetLookup[op_iffalse.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifge:
					var op_ifge:Instruction_ifge = op as Instruction_ifge;
					offset = offsetLookup[op_ifge.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifgt:
					var op_ifgt:Instruction_ifgt = op as Instruction_ifgt;
					offset = offsetLookup[op_ifgt.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifle:
					var op_ifle:Instruction_ifle = op as Instruction_ifle;
					offset = offsetLookup[op_ifle.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_iflt:
					var op_iflt:Instruction_iflt = op as Instruction_iflt;
					offset = offsetLookup[op_iflt.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifnge:
					var op_ifnge:Instruction_ifnge = op as Instruction_ifnge;
					offset = offsetLookup[op_ifnge.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifngt:
					var op_ifngt:Instruction_ifngt = op as Instruction_ifngt;
					offset = offsetLookup[op_ifngt.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifnle:
					var op_ifnle:Instruction_ifnle = op as Instruction_ifnle;
					offset = offsetLookup[op_ifnle.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifnlt:
					var op_ifnlt:Instruction_ifnlt = op as Instruction_ifnlt;
					offset = offsetLookup[op_ifnlt.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifne:
					var op_ifne:Instruction_ifne = op as Instruction_ifne;
					offset = offsetLookup[op_ifne.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifstricteq:
					var op_ifstricteq:Instruction_ifstricteq = op as Instruction_ifstricteq;
					offset = offsetLookup[op_ifstricteq.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_ifstrictne:
					var op_ifstrictne:Instruction_ifstrictne = op as Instruction_ifstrictne;
					offset = offsetLookup[op_ifstrictne.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_iftrue:
					var op_iftrue:Instruction_iftrue = op as Instruction_iftrue;
					offset = offsetLookup[op_iftrue.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_jump:
					var op_jump:Instruction_jump = op as Instruction_jump;
					offset = offsetLookup[op_jump.reference] - (baseOffset + opLength);
					abc.writeS24(offset);
					break;
				case Instruction_lookupswitch:
					var op_lookup:Instruction_lookupswitch = op as Instruction_lookupswitch;
					offset = offsetLookup[op_lookup.defaultReference] - baseOffset;
					abc.writeS24(offset);
					
					abc.writeU30(op.caseReferences.length - 1);
					
					for(var iter:uint = 0; iter < op_lookup.caseReferences.length; iter++)
					{
						offset = offsetLookup[op_lookup.caseReferences[iter]] - baseOffset;
						abc.writeS24(offset);
					}
					break;
			}
		}
		
		public function writeUnknown(op:UnknownInstruction, abc:ABCByteArray):void
		{
			abc.writeU8(op.type);
		}
		
		public function write_0xF2(op:Instruction_0xF2, abc:ABCByteArray):void
		{
			abc.writeU30(op.unknown);
		}
		
		public function write_applytype(op:Instruction_applytype, abc:ABCByteArray):void
		{
			abc.writeU30(op.argCount);
		}
		
		public function write_astype(op:Instruction_astype, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_call(op:Instruction_call, abc:ABCByteArray):void
		{
			abc.writeU30(op.argCount);
		}
		
		public function write_callmethod(op:Instruction_callmethod, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
			abc.writeU30(op.argCount);
		}
		
		public function write_callproperty(op:Instruction_callproperty, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
			abc.writeU30(op.argCount);
		}
		
		public function write_callproplex(op:Instruction_callproplex, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
			abc.writeU30(op.argCount);
		}
		
		public function write_callpropvoid(op:Instruction_callpropvoid, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
			abc.writeU30(op.argCount);
		}
		
		public function write_callstatic(op:Instruction_callstatic, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
			abc.writeU30(op.argCount);
		}
		
		public function write_callsuper(op:Instruction_callsuper, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
			abc.writeU30(op.argCount);
		}
		
		public function write_callsupervoid(op:Instruction_callsupervoid, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
			abc.writeU30(op.argCount);
		}
		
		public function write_coerce(op:Instruction_coerce, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_construct(op:Instruction_construct, abc:ABCByteArray):void
		{
			abc.writeU30(op.argCount);
		}
		
		public function write_constructprop(op:Instruction_constructprop, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
			abc.writeU30(op.argCount);
		}
		
		public function write_constructsuper(op:Instruction_constructsuper, abc:ABCByteArray):void
		{
			abc.writeU30(op.argCount);
		}
		
		public function write_debug(op:Instruction_debug, abc:ABCByteArray):void
		{
			abc.writeU8(op.debugType);
			abc.writeU30(op.index);
			abc.writeU8(op.reg);
			abc.writeU30(op.extra);
		}
		
		public function write_debugfile(op:Instruction_debugfile, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_debugline(op:Instruction_debugline, abc:ABCByteArray):void
		{
			abc.writeU30(op.lineNum);
		}
		
		public function write_declocal(op:Instruction_declocal, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_declocal_i(op:Instruction_declocal_i, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_deleteproperty(op:Instruction_deleteproperty, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_dxns(op:Instruction_dxns, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_finddef(op:Instruction_finddef, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_findproperty(op:Instruction_findproperty, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_findpropglobal(op:Instruction_findpropglobal, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_findpropglobalstrict(op:Instruction_findpropglobalstrict, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_findpropstrict(op:Instruction_findpropstrict, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_getdescendants(op:Instruction_getdescendants, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_getglobalslot(op:Instruction_getglobalslot, abc:ABCByteArray):void
		{
			abc.writeU30(op.slotIndex);
		}
		
		public function write_getlex(op:Instruction_getlex, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_getlocal(op:Instruction_getlocal, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_getouterscope(op:Instruction_getouterscope, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_getproperty(op:Instruction_getproperty, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_getscopeobject(op:Instruction_getscopeobject, abc:ABCByteArray):void
		{
			abc.writeU8(op.index);
		}
		
		public function write_getslot(op:Instruction_getslot, abc:ABCByteArray):void
		{
			abc.writeU30(op.slotIndex);
		}
		
		public function write_getsuper(op:Instruction_getsuper, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_hasnext2(op:Instruction_hasnext2, abc:ABCByteArray):void
		{
			abc.writeU30(op.objectReg);
			abc.writeU30(op.indexReg);
		}
		
		public function write_ifnlt(op:Instruction_ifnlt, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifnle(op:Instruction_ifnle, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifngt(op:Instruction_ifngt, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifnge(op:Instruction_ifnge, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_iftrue(op:Instruction_iftrue, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_iffalse(op:Instruction_iffalse, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifeq(op:Instruction_ifeq, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifne(op:Instruction_ifne, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_iflt(op:Instruction_iflt, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifle(op:Instruction_ifle, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifgt(op:Instruction_ifgt, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifge(op:Instruction_ifge, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifstricteq(op:Instruction_ifstricteq, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_ifstrictne(op:Instruction_ifstrictne, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_inclocal(op:Instruction_inclocal, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_inclocal_i(op:Instruction_inclocal_i, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_initproperty(op:Instruction_initproperty, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_istype(op:Instruction_istype, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_jump(op:Instruction_jump, abc:ABCByteArray):void
		{
			abc.writeS24(op.offset);
		}
		
		public function write_kill(op:Instruction_kill, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_lookupswitch(op:Instruction_lookupswitch, abc:ABCByteArray):void
		{
			abc.writeS24(op.defaultOffset);
			abc.writeU30(op.caseOffsets.length - 1);
			for(var iter:uint = 0; iter < op.caseOffsets.length; iter++)
			{
				abc.writeS24(op.caseOffsets[iter]);
			}
		}

		public function write_newarray(op:Instruction_newarray, abc:ABCByteArray):void
		{
			abc.writeU30(op.argCount);
		}
		
		public function write_newcatch(op:Instruction_newcatch, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_newclass(op:Instruction_newclass, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_newfunction(op:Instruction_newfunction, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_newobject(op:Instruction_newobject, abc:ABCByteArray):void
		{
			abc.writeU30(op.argCount);
		}
		
		public function write_pushbyte(op:Instruction_pushbyte, abc:ABCByteArray):void
		{
			abc.writeU8(uint(op.byteValue));
		}
		
		public function write_pushdouble(op:Instruction_pushdouble, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_pushint(op:Instruction_pushint, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_pushnamespace(op:Instruction_pushnamespace, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_pushshort(op:Instruction_pushshort, abc:ABCByteArray):void
		{
			abc.writeU30(op.value);
		}
		
		public function write_pushstring(op:Instruction_pushstring, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_pushuint(op:Instruction_pushuint, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_setglobalslot(op:Instruction_setglobalslot, abc:ABCByteArray):void
		{
			abc.writeU30(op.slotIndex);
		}
		
		public function write_setlocal(op:Instruction_setlocal, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_setproperty(op:Instruction_setproperty, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
		
		public function write_setslot(op:Instruction_setslot, abc:ABCByteArray):void
		{
			abc.writeU30(op.slotIndex);
		}
		
		public function write_setsuper(op:Instruction_setsuper, abc:ABCByteArray):void
		{
			abc.writeU30(op.index);
		}
	}
}