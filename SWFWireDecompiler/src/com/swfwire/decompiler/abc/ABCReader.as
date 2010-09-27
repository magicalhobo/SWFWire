package com.swfwire.decompiler.abc
{
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.*;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	public class ABCReader
	{
		public function read(bytes:ABCByteArray):ABCReadResult
		{
			var result:ABCReadResult = new ABCReadResult();
			
			var abc:ABCFile = new ABCFile();
			
			abc.minorVersion = bytes.readU16();
			abc.majorVersion = bytes.readU16();
			
			abc.cpool = new ConstantPoolToken();
			abc.cpool.read(bytes);
			
			var iter:uint;
			
			abc.methodCount = bytes.readU30();
			abc.methods = new Vector.<MethodInfoToken>(abc.methodCount);
			for(iter = 0; iter < abc.methodCount; iter++)
			{
				var methodInfoToken:MethodInfoToken = new MethodInfoToken();
				methodInfoToken.read(bytes);
				abc.methods[iter] = methodInfoToken;
			}
			
			abc.metadataCount = bytes.readU30();
			abc.metadata = new Vector.<MetadataInfoToken>(abc.metadataCount);
			for(iter = 0; iter < abc.metadataCount; iter++)
			{
				var metadataInfoToken:MetadataInfoToken = new MetadataInfoToken();
				metadataInfoToken.read(bytes);
				abc.metadata[iter] = metadataInfoToken;
			}
			
			abc.classCount = bytes.readU30();
			abc.instances = new Vector.<InstanceToken>(abc.classCount);
			for(iter = 0; iter < abc.classCount; iter++)
			{
				var instanceToken:InstanceToken = new InstanceToken();
				instanceToken.read(bytes);
				abc.instances[iter] = instanceToken;
			}
			
			abc.classes = new Vector.<ClassInfoToken>(abc.classCount);
			for(iter = 0; iter < abc.classCount; iter++)
			{
				var classToken:ClassInfoToken = new ClassInfoToken();
				classToken.read(bytes);
				abc.classes[iter] = classToken;
			}
			
			abc.scriptCount = bytes.readU30();
			abc.scripts = new Vector.<ScriptInfoToken>(abc.scriptCount);
			for(iter = 0; iter < abc.scriptCount; iter++)
			{
				var scriptToken:ScriptInfoToken = new ScriptInfoToken();
				scriptToken.read(bytes);
				abc.scripts[iter] = scriptToken;
			}
			
			abc.methodBodyCount = bytes.readU30();
			abc.methodBodies = new Vector.<MethodBodyInfoToken>(abc.methodBodyCount);
			for(iter = 0; iter < abc.methodBodyCount; iter++)
			{
				var methodBodyInfo:MethodBodyInfoToken = new MethodBodyInfoToken();
				methodBodyInfo.read(bytes);
				abc.methodBodies[iter] = methodBodyInfo;
			}
			
			for(iter = 0; iter < abc.methodBodies.length; iter++)
			{
				var methodBody:MethodBodyInfoToken = abc.methodBodies[iter];
				var methodBodyResult:MethodBodyReadResult = readMethodBody(methodBody);
				methodBody.instructions = methodBodyResult.instructions;
				result.metadata.idFromOffset[iter] = methodBodyResult.offsetFromId;
				result.metadata.offsetFromId[iter] = methodBodyResult.idFromOffset;
			}
			
			result.abc = abc;
			
			return result;
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
				var InstructionClass:Class = ABCInstructions.getClass(opcode);
				if(InstructionClass)
				{
					instructions[instructionId] = readInstruction(opcode, abc);
				}
				if(!instructions[instructionId])
				{
					invalid = true;
					dump.push('			Invalid instruction encountered ('+opcode.toString(16)+') at id '+instructionId+'.');
				}
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
				trace(dump.join('\n'));
				throw new Error('Encountered an unknown instruction.');
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
			
			//Debug.dump(result);
			
			return new MethodBodyReadResult(instructions, offsetLookup, reverseOffsetLookup);
		}

		public function readInstruction(opcode:uint, abc:ABCByteArray):IInstruction
		{
			var op:IInstruction;
			
			switch(opcode)
			{
				case 0x01:
					op = read_0x01(abc);
					break;
				case 0x02:
					op = read_nop(abc);
					break;
				case 0x03:
					op = read_throw(abc);
					break;
				case 0x04:
					op = read_getsuper(abc);
					break;
				case 0x05:
					op = read_setsuper(abc);
					break;
				case 0x06:
					op = read_dxns(abc);
					break;
				case 0x07:
					op = read_dxnslate(abc);
					break;
				case 0x08:
					op = read_kill(abc);
					break;
				case 0x09:
					op = read_label(abc);
					break;
				case 0x0C:
					op = read_ifnlt(abc);
					break;
				case 0x0D:
					op = read_ifnle(abc);
					break;
				case 0x0E:
					op = read_ifngt(abc);
					break;
				case 0x0F:
					op = read_ifnge(abc);
					break;
				case 0x10:
					op = read_jump(abc);
					break;
				case 0x11:
					op = read_iftrue(abc);
					break;
				case 0x12:
					op = read_iffalse(abc);
					break;
				case 0x13:
					op = read_ifeq(abc);
					break;
				case 0x14:
					op = read_ifne(abc);
					break;
				case 0x15:
					op = read_iflt(abc);
					break;
				case 0x16:
					op = read_ifle(abc);
					break;
				case 0x17:
					op = read_ifgt(abc);
					break;
				case 0x18:
					op = read_ifge(abc);
					break;
				case 0x19:
					op = read_ifstricteq(abc);
					break;
				case 0x1A:
					op = read_ifstrictne(abc);
					break;
				case 0x1B:
					op = read_lookupswitch(abc);
					break;
				case 0x1C:
					op = read_pushwith(abc);
					break;
				case 0x1D:
					op = read_popscope(abc);
					break;
				case 0x1E:
					op = read_nextname(abc);
					break;
				case 0x1F:
					op = read_hasnext(abc);
					break;
				case 0x20:
					op = read_pushnull(abc);
					break;
				case 0x21:
					op = read_pushundefined(abc);
					break;
				case 0x23:
					op = read_nextvalue(abc);
					break;
				case 0x24:
					op = read_pushbyte(abc);
					break;
				case 0x25:
					op = read_pushshort(abc);
					break;
				case 0x26:
					op = read_pushtrue(abc);
					break;
				case 0x27:
					op = read_pushfalse(abc);
					break;
				case 0x28:
					op = read_pushnan(abc);
					break;
				case 0x29:
					op = read_pop(abc);
					break;
				case 0x2A:
					op = read_dup(abc);
					break;
				case 0x2B:
					op = read_swap(abc);
					break;
				case 0x2C:
					op = read_pushstring(abc);
					break;
				case 0x2D:
					op = read_pushint(abc);
					break;
				case 0x2E:
					op = read_pushuint(abc);
					break;
				case 0x2F:
					op = read_pushdouble(abc);
					break;
				case 0x30:
					op = read_pushscope(abc);
					break;
				case 0x31:
					op = read_pushnamespace(abc);
					break;
				case 0x32:
					op = read_hasnext2(abc);
					break;
				case 0x35:
					op = read_li8(abc);
					break;
				case 0x36:
					op = read_li16(abc);
					break;
				case 0x37:
					op = read_li32(abc);
					break;
				case 0x38:
					op = read_lf32(abc);
					break;
				case 0x39:
					op = read_lf64(abc);
					break;
				case 0x3A:
					op = read_si8(abc);
					break;
				case 0x3B:
					op = read_si16(abc);
					break;
				case 0x3C:
					op = read_si32(abc);
					break;
				case 0x3D:
					op = read_sf32(abc);
					break;
				case 0x3E:
					op = read_sf64(abc);
					break;
				case 0x40:
					op = read_newfunction(abc);
					break;
				case 0x41:
					op = read_call(abc);
					break;
				case 0x42:
					op = read_construct(abc);
					break;
				case 0x43:
					op = read_callmethod(abc);
					break;
				case 0x44:
					op = read_callstatic(abc);
					break;
				case 0x45:
					op = read_callsuper(abc);
					break;
				case 0x46:
					op = read_callproperty(abc);
					break;
				case 0x47:
					op = read_returnvoid(abc);
					break;
				case 0x48:
					op = read_returnvalue(abc);
					break;
				case 0x49:
					op = read_constructsuper(abc);
					break;
				case 0x4A:
					op = read_constructprop(abc);
					break;
				case 0x4C:
					op = read_callproplex(abc);
					break;
				case 0x4E:
					op = read_callsupervoid(abc);
					break;
				case 0x4F:
					op = read_callpropvoid(abc);
					break;
				case 0x50:
					op = read_sxi1(abc);
					break;
				case 0x51:
					op = read_sxi8(abc);
					break;
				case 0x52:
					op = read_sxi16(abc);
					break;
				case 0x53:
					op = read_applytype(abc);
					break;
				case 0x55:
					op = read_newobject(abc);
					break;
				case 0x56:
					op = read_newarray(abc);
					break;
				case 0x57:
					op = read_newactivation(abc);
					break;
				case 0x58:
					op = read_newclass(abc);
					break;
				case 0x59:
					op = read_getdescendants(abc);
					break;
				case 0x5A:
					op = read_newcatch(abc);
					break;
				case 0x5B:
					op = read_findpropglobalstrict(abc);
					break;
				case 0x5C:
					op = read_findpropglobal(abc);
					break;
				case 0x5D:
					op = read_findpropstrict(abc);
					break;
				case 0x5E:
					op = read_findproperty(abc);
					break;
				case 0x5F:
					op = read_finddef(abc);
					break;  
				case 0x60:
					op = read_getlex(abc);
					break;
				case 0x61:
					op = read_setproperty(abc);
					break;
				case 0x62:
					op = read_getlocal(abc);
					break;
				case 0x63:
					op = read_setlocal(abc);
					break;
				case 0x64:
					op = read_getglobalscope(abc);
					break;
				case 0x65:
					op = read_getscopeobject(abc);
					break;
				case 0x66:
					op = read_getproperty(abc);
					break;
				case 0x67:
					op = read_getouterscope(abc);
					break;
				case 0x68:
					op = read_initproperty(abc);
					break;
				case 0x6A:
					op = read_deleteproperty(abc);
					break;
				case 0x6C:
					op = read_getslot(abc);
					break;
				case 0x6D:
					op = read_setslot(abc);
					break;
				case 0x6E:
					op = read_getglobalslot(abc);
					break;
				case 0x6F:
					op = read_setglobalslot(abc);
					break;
				case 0x70:
					op = read_convert_s(abc);
					break;
				case 0x71:
					op = read_esc_xelem(abc);
					break;
				case 0x72:
					op = read_esc_xattr(abc);
					break;
				case 0x73:
					op = read_convert_i(abc);
					break;
				case 0x74:
					op = read_convert_u(abc);
					break;
				case 0x75:
					op = read_convert_d(abc);
					break;
				case 0x76:
					op = read_convert_b(abc);
					break;
				case 0x77:
					op = read_convert_o(abc);
					break;
				case 0x78:
					op = read_checkfilter(abc);
					break;
				case 0x80:
					op = read_coerce(abc);
					break;
				case 0x81:
					op = read_coerce_b(abc);
					break;
				case 0x82:
					op = read_coerce_a(abc);
					break;
				case 0x83:
					op = read_coerce_i(abc);
					break; 
				case 0x84:
					op = read_coerce_d(abc);
					break; 
				case 0x85:
					op = read_coerce_s(abc);
					break;
				case 0x86:
					op = read_astype(abc);
					break;
				case 0x87:
					op = read_astypelate(abc);
					break;
				case 0x88:
					op = read_coerce_u(abc);
					break;
				case 0x89:
					op = read_coerce_o(abc);
					break;
				case 0x90:
					op = read_negate(abc);
					break;
				case 0x91:
					op = read_increment(abc);
					break;
				case 0x92:
					op = read_inclocal(abc);
					break;
				case 0x93:
					op = read_decrement(abc);
					break;
				case 0x94:
					op = read_declocal(abc);
					break;
				case 0x95:
					op = read_typeof(abc);
					break;
				case 0x96:
					op = read_not(abc);
					break;
				case 0x97:
					op = read_bitnot(abc);
					break;
				case 0xA0:
					op = read_add(abc);
					break;
				case 0xA1:
					op = read_subtract(abc);
					break;
				case 0xA2:
					op = read_multiply(abc);
					break;
				case 0xA3:
					op = read_divide(abc);
					break;
				case 0xA4:
					op = read_modulo(abc);
					break;
				case 0xA5:
					op = read_lshift(abc);
					break;
				case 0xA6:
					op = read_rshift(abc);
					break;
				case 0xA7:
					op = read_urshift(abc);
					break;
				case 0xA8:
					op = read_bitand(abc);
					break;
				case 0xA9:
					op = read_bitor(abc);
					break;
				case 0xAA:
					op = read_bitxor(abc);
					break;
				case 0xAB:
					op = read_equals(abc);
					break;
				case 0xAC:
					op = read_strictequals(abc);
					break;
				case 0xAD:
					op = read_lessthan(abc);
					break;
				case 0xAE:
					op = read_lessequals(abc);
					break;
				case 0xAF:
					op = read_greaterthan(abc);
					break;
				case 0xB0:
					op = read_greaterequals(abc);
					break;
				case 0xB1:
					op = read_instanceof(abc);
					break;
				case 0xB2:
					op = read_istype(abc);
					break;
				case 0xB3:
					op = read_istypelate(abc);
					break;
				case 0xB4:
					op = read_in(abc);
					break;
				case 0xC0:
					op = read_increment_i(abc);
					break;
				case 0xC1:
					op = read_decrement_i(abc);
					break;
				case 0xC2:
					op = read_inclocal_i(abc);
					break;
				case 0xC3:
					op = read_declocal_i(abc);
					break;
				case 0xC4:
					op = read_negate_i(abc);
					break;
				case 0xC5:
					op = read_add_i(abc);
					break;
				case 0xC6:
					op = read_subtract_i(abc);
					break;
				case 0xC7:
					op = read_multiply_i(abc);
					break;
				case 0xD0:
					op = read_getlocal0(abc);
					break;
				case 0xD1:
					op = read_getlocal1(abc);
					break;
				case 0xD2:
					op = read_getlocal2(abc);
					break;
				case 0xD3:
					op = read_getlocal3(abc);
					break;
				case 0xD4:
					op = read_setlocal0(abc);
					break;
				case 0xD5:
					op = read_setlocal1(abc);
					break;
				case 0xD6:
					op = read_setlocal2(abc);
					break;
				case 0xD7:
					op = read_setlocal3(abc);
					break;
				case 0xEF:
					op = read_debug(abc);
					break;
				case 0xF0:
					op = read_debugline(abc);
					break;
				case 0xF1:
					op = read_debugfile(abc);
					break;
				case 0xF2:
					op = read_0xF2(abc);
					break;
				default:
					throw new Error('Invalid instruction encountered: '+opcode.toString(16));
					break;
			}
			
			if(!op)
			{
				trace('uh oh: '+opcode.toString(16));
			}
			
			return op;
		}
		
		public function read_negate_i(abc:ABCByteArray):Instruction_negate_i
		{
			return new Instruction_negate_i();
		}
		
		public function read_add_i(abc:ABCByteArray):Instruction_add_i
		{
			return new Instruction_add_i();
		}
		
		public function read_subtract_i(abc:ABCByteArray):Instruction_subtract_i
		{
			return new Instruction_subtract_i();
		}
		
		public function read_multiply_i(abc:ABCByteArray):Instruction_multiply_i
		{
			return new Instruction_multiply_i();
		}
		
		public function read_0xF2(abc:ABCByteArray):Instruction_0xF2
		{
			var op:Instruction_0xF2 = new Instruction_0xF2();
			
			op.unknown = abc.readU30();
			
			return op;
		}
		
		public function read_applytype(abc:ABCByteArray):Instruction_applytype
		{
			var op:Instruction_applytype = new Instruction_applytype();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_astype(abc:ABCByteArray):Instruction_astype
		{
			var op:Instruction_astype = new Instruction_astype();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_call(abc:ABCByteArray):Instruction_call
		{
			var op:Instruction_call = new Instruction_call();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_callmethod(abc:ABCByteArray):Instruction_callmethod
		{
			var op:Instruction_callmethod = new Instruction_callmethod();
			
			op.index = abc.readU30();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_callproperty(abc:ABCByteArray):Instruction_callproperty
		{
			var op:Instruction_callproperty = new Instruction_callproperty();
			
			op.index = abc.readU30();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_returnvoid(abc:ABCByteArray):Instruction_returnvoid
		{
			return new Instruction_returnvoid();
		}
		
		public function read_returnvalue(abc:ABCByteArray):Instruction_returnvalue
		{
			return new Instruction_returnvalue();
		}
		
		public function read_callproplex(abc:ABCByteArray):Instruction_callproplex
		{
			var op:Instruction_callproplex = new Instruction_callproplex();
			
			op.index = abc.readU30();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_callpropvoid(abc:ABCByteArray):Instruction_callpropvoid
		{
			var op:Instruction_callpropvoid = new Instruction_callpropvoid();
			
			op.index = abc.readU30();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_callstatic(abc:ABCByteArray):Instruction_callstatic
		{
			var op:Instruction_callstatic = new Instruction_callstatic();
			
			op.index = abc.readU30();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_callsuper(abc:ABCByteArray):Instruction_callsuper
		{
			var op:Instruction_callsuper = new Instruction_callsuper();
			
			op.index = abc.readU30();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_callsupervoid(abc:ABCByteArray):Instruction_callsupervoid
		{
			var op:Instruction_callsupervoid = new Instruction_callsupervoid();
			
			op.index = abc.readU30();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_coerce(abc:ABCByteArray):Instruction_coerce
		{
			var op:Instruction_coerce = new Instruction_coerce();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_construct(abc:ABCByteArray):Instruction_construct
		{
			var op:Instruction_construct = new Instruction_construct();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_constructprop(abc:ABCByteArray):Instruction_constructprop
		{
			var op:Instruction_constructprop = new Instruction_constructprop();
			
			op.index = abc.readU30();
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_constructsuper(abc:ABCByteArray):Instruction_constructsuper
		{
			var op:Instruction_constructsuper = new Instruction_constructsuper();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_debug(abc:ABCByteArray):Instruction_debug
		{
			var op:Instruction_debug = new Instruction_debug();
			
			op.debugType = abc.readU8();
			op.index = abc.readU30();
			op.reg = abc.readU8();
			op.extra = abc.readU30();
			
			return op;
		}
		
		public function read_debugfile(abc:ABCByteArray):Instruction_debugfile
		{
			var op:Instruction_debugfile = new Instruction_debugfile();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_debugline(abc:ABCByteArray):Instruction_debugline
		{
			var op:Instruction_debugline = new Instruction_debugline();
			
			op.lineNum = abc.readU30();
			
			return op;
		}
		
		public function read_convert_s(abc:ABCByteArray):Instruction_convert_s
		{
			return new Instruction_convert_s();
		}

		public function read_esc_xelem(abc:ABCByteArray):Instruction_esc_xelem
		{
			return new Instruction_esc_xelem();
		}

		public function read_esc_xattr(abc:ABCByteArray):Instruction_esc_xattr
		{
			return new Instruction_esc_xattr();
		}

		public function read_convert_i(abc:ABCByteArray):Instruction_convert_i
		{
			return new Instruction_convert_i();
		}

		public function read_convert_u(abc:ABCByteArray):Instruction_convert_u
		{
			return new Instruction_convert_u();
		}

		public function read_convert_d(abc:ABCByteArray):Instruction_convert_d
		{
			return new Instruction_convert_d();
		}

		public function read_convert_b(abc:ABCByteArray):Instruction_convert_b
		{
			return new Instruction_convert_b();
		}

		public function read_convert_o(abc:ABCByteArray):Instruction_convert_o
		{
			return new Instruction_convert_o();
		}

		public function read_checkfilter(abc:ABCByteArray):Instruction_checkfilter
		{
			return new Instruction_checkfilter();
		}

		public function read_coerce_b(abc:ABCByteArray):Instruction_coerce_b
		{
			return new Instruction_coerce_b();
		}

		public function read_coerce_a(abc:ABCByteArray):Instruction_coerce_a
		{
			return new Instruction_coerce_a();
		}

		public function read_coerce_i(abc:ABCByteArray):Instruction_coerce_i
		{
			return new Instruction_coerce_i();
		}

		public function read_coerce_d(abc:ABCByteArray):Instruction_coerce_d
		{
			return new Instruction_coerce_d();
		}

		public function read_coerce_s(abc:ABCByteArray):Instruction_coerce_s
		{
			return new Instruction_coerce_s();
		}

		public function read_astypelate(abc:ABCByteArray):Instruction_astypelate
		{
			return new Instruction_astypelate();
		}

		public function read_coerce_u(abc:ABCByteArray):Instruction_coerce_u
		{
			return new Instruction_coerce_u();
		}

		public function read_coerce_o(abc:ABCByteArray):Instruction_coerce_o
		{
			return new Instruction_coerce_o();
		}

		public function read_negate(abc:ABCByteArray):Instruction_negate
		{
			return new Instruction_negate();
		}

		public function read_increment(abc:ABCByteArray):Instruction_increment
		{
			return new Instruction_increment();
		}

		public function read_decrement(abc:ABCByteArray):Instruction_decrement
		{
			return new Instruction_decrement();
		}

		public function read_declocal(abc:ABCByteArray):Instruction_declocal
		{
			var op:Instruction_declocal = new Instruction_declocal();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_declocal_i(abc:ABCByteArray):Instruction_declocal_i
		{
			var op:Instruction_declocal_i = new Instruction_declocal_i();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_getlocal0(abc:ABCByteArray):Instruction_getlocal0
		{
			return new Instruction_getlocal0();
		}
		
		public function read_getlocal1(abc:ABCByteArray):Instruction_getlocal1
		{
			return new Instruction_getlocal1();
		}
		
		public function read_getlocal2(abc:ABCByteArray):Instruction_getlocal2
		{
			return new Instruction_getlocal2();
		}
		
		public function read_getlocal3(abc:ABCByteArray):Instruction_getlocal3
		{
			return new Instruction_getlocal3();
		}
		
		public function read_setlocal0(abc:ABCByteArray):Instruction_setlocal0
		{
			return new Instruction_setlocal0();
		}
		
		public function read_setlocal1(abc:ABCByteArray):Instruction_setlocal1
		{
			return new Instruction_setlocal1();
		}
		
		public function read_setlocal2(abc:ABCByteArray):Instruction_setlocal2
		{
			return new Instruction_setlocal2();
		}
		
		public function read_setlocal3(abc:ABCByteArray):Instruction_setlocal3
		{
			return new Instruction_setlocal3();
		}

		public function read_deleteproperty(abc:ABCByteArray):Instruction_deleteproperty
		{
			var op:Instruction_deleteproperty = new Instruction_deleteproperty();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_dxns(abc:ABCByteArray):Instruction_dxns
		{
			var op:Instruction_dxns = new Instruction_dxns();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_dxnslate(abc:ABCByteArray):Instruction_dxnslate
		{
			return new Instruction_dxnslate();
		}
		
		public function read_finddef(abc:ABCByteArray):Instruction_finddef
		{
			var op:Instruction_finddef = new Instruction_finddef();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_findproperty(abc:ABCByteArray):Instruction_findproperty
		{
			var op:Instruction_findproperty = new Instruction_findproperty();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_findpropglobal(abc:ABCByteArray):Instruction_findpropglobal
		{
			var op:Instruction_findpropglobal = new Instruction_findpropglobal();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_findpropglobalstrict(abc:ABCByteArray):Instruction_findpropglobalstrict
		{
			var op:Instruction_findpropglobalstrict = new Instruction_findpropglobalstrict();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_findpropstrict(abc:ABCByteArray):Instruction_findpropstrict
		{
			var op:Instruction_findpropstrict = new Instruction_findpropstrict();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_getdescendants(abc:ABCByteArray):Instruction_getdescendants
		{
			var op:Instruction_getdescendants = new Instruction_getdescendants();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_getglobalslot(abc:ABCByteArray):Instruction_getglobalslot
		{
			var op:Instruction_getglobalslot = new Instruction_getglobalslot();
			
			op.slotIndex = abc.readU30();
			
			return op;
		}
		
		public function read_getlex(abc:ABCByteArray):Instruction_getlex
		{
			var op:Instruction_getlex = new Instruction_getlex();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_getlocal(abc:ABCByteArray):Instruction_getlocal
		{
			var op:Instruction_getlocal = new Instruction_getlocal();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_getouterscope(abc:ABCByteArray):Instruction_getouterscope
		{
			var op:Instruction_getouterscope = new Instruction_getouterscope();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_getproperty(abc:ABCByteArray):Instruction_getproperty
		{
			var op:Instruction_getproperty = new Instruction_getproperty();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_getscopeobject(abc:ABCByteArray):Instruction_getscopeobject
		{
			var op:Instruction_getscopeobject = new Instruction_getscopeobject();
			
			op.index = abc.readU8();
			
			return op;
		}
		
		public function read_getslot(abc:ABCByteArray):Instruction_getslot
		{
			var op:Instruction_getslot = new Instruction_getslot();
			
			op.slotIndex = abc.readU30();
			
			return op;
		}
		
		public function read_0x01(abc:ABCByteArray):Instruction_0x01
		{
			return new Instruction_0x01();
		}
		
		public function read_nop(abc:ABCByteArray):Instruction_nop
		{
			return new Instruction_nop();
		}
		
		public function read_throw(abc:ABCByteArray):Instruction_throw
		{
			return new Instruction_throw();
		}
		
		public function read_getsuper(abc:ABCByteArray):Instruction_getsuper
		{
			var op:Instruction_getsuper = new Instruction_getsuper();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_hasnext2(abc:ABCByteArray):Instruction_hasnext2
		{
			var op:Instruction_hasnext2 = new Instruction_hasnext2();
			
			op.objectReg = abc.readU30();
			op.indexReg = abc.readU30();
			
			return op;
		}
		
		public function read_inclocal(abc:ABCByteArray):Instruction_inclocal
		{
			var op:Instruction_inclocal = new Instruction_inclocal();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_typeof(abc:ABCByteArray):Instruction_typeof
		{
			return new Instruction_typeof();
		}

		public function read_not(abc:ABCByteArray):Instruction_not
		{
			return new Instruction_not();
		}

		public function read_bitnot(abc:ABCByteArray):Instruction_bitnot
		{
			return new Instruction_bitnot();
		}

		public function read_add(abc:ABCByteArray):Instruction_add
		{
			return new Instruction_add();
		}

		public function read_subtract(abc:ABCByteArray):Instruction_subtract
		{
			return new Instruction_subtract();
		}

		public function read_multiply(abc:ABCByteArray):Instruction_multiply
		{
			return new Instruction_multiply();
		}

		public function read_divide(abc:ABCByteArray):Instruction_divide
		{
			return new Instruction_divide();
		}

		public function read_modulo(abc:ABCByteArray):Instruction_modulo
		{
			return new Instruction_modulo();
		}

		public function read_lshift(abc:ABCByteArray):Instruction_lshift
		{
			return new Instruction_lshift();
		}

		public function read_rshift(abc:ABCByteArray):Instruction_rshift
		{
			return new Instruction_rshift();
		}

		public function read_urshift(abc:ABCByteArray):Instruction_urshift
		{
			return new Instruction_urshift();
		}

		public function read_bitand(abc:ABCByteArray):Instruction_bitand
		{
			return new Instruction_bitand();
		}

		public function read_bitor(abc:ABCByteArray):Instruction_bitor
		{
			return new Instruction_bitor();
		}

		public function read_bitxor(abc:ABCByteArray):Instruction_bitxor
		{
			return new Instruction_bitxor();
		}

		public function read_equals(abc:ABCByteArray):Instruction_equals
		{
			return new Instruction_equals();
		}

		public function read_strictequals(abc:ABCByteArray):Instruction_strictequals
		{
			return new Instruction_strictequals();
		}

		public function read_lessthan(abc:ABCByteArray):Instruction_lessthan
		{
			return new Instruction_lessthan();
		}

		public function read_lessequals(abc:ABCByteArray):Instruction_lessequals
		{
			return new Instruction_lessequals();
		}

		public function read_greaterthan(abc:ABCByteArray):Instruction_greaterthan
		{
			return new Instruction_greaterthan();
		}

		public function read_greaterequals(abc:ABCByteArray):Instruction_greaterequals
		{
			return new Instruction_greaterequals();
		}

		public function read_instanceof(abc:ABCByteArray):Instruction_instanceof
		{
			return new Instruction_instanceof();
		}

		public function read_istypelate(abc:ABCByteArray):Instruction_istypelate
		{
			return new Instruction_istypelate();
		}

		public function read_in(abc:ABCByteArray):Instruction_in
		{
			return new Instruction_in();
		}

		public function read_increment_i(abc:ABCByteArray):Instruction_increment_i
		{
			return new Instruction_increment_i();
		}

		public function read_decrement_i(abc:ABCByteArray):Instruction_decrement_i
		{
			return new Instruction_decrement_i();
		}


		
		public function read_inclocal_i(abc:ABCByteArray):Instruction_inclocal_i
		{
			var op:Instruction_inclocal_i = new Instruction_inclocal_i();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_initproperty(abc:ABCByteArray):Instruction_initproperty
		{
			var op:Instruction_initproperty = new Instruction_initproperty();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_istype(abc:ABCByteArray):Instruction_istype
		{
			var op:Instruction_istype = new Instruction_istype();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_jump(abc:ABCByteArray):Instruction_jump
		{
			var op:Instruction_jump = new Instruction_jump();
			
			op.offset = abc.readS24();
			
			return op;
		}
		
		public function read_kill(abc:ABCByteArray):Instruction_kill
		{
			var op:Instruction_kill = new Instruction_kill();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_label(abc:ABCByteArray):Instruction_label
		{
			return new Instruction_label();
		}

		public function read_ifnlt(abc:ABCByteArray):Instruction_ifnlt
		{
			var op:Instruction_ifnlt = new Instruction_ifnlt();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifnle(abc:ABCByteArray):Instruction_ifnle
		{
			var op:Instruction_ifnle = new Instruction_ifnle();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifngt(abc:ABCByteArray):Instruction_ifngt
		{
			var op:Instruction_ifngt = new Instruction_ifngt();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifnge(abc:ABCByteArray):Instruction_ifnge
		{
			var op:Instruction_ifnge = new Instruction_ifnge();
			op.offset = abc.readS24()
			return op;
		}

		public function read_iftrue(abc:ABCByteArray):Instruction_iftrue
		{
			var op:Instruction_iftrue = new Instruction_iftrue();
			op.offset = abc.readS24()
			return op;
		}

		public function read_iffalse(abc:ABCByteArray):Instruction_iffalse
		{
			var op:Instruction_iffalse = new Instruction_iffalse();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifeq(abc:ABCByteArray):Instruction_ifeq
		{
			var op:Instruction_ifeq = new Instruction_ifeq();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifne(abc:ABCByteArray):Instruction_ifne
		{
			var op:Instruction_ifne = new Instruction_ifne();
			op.offset = abc.readS24()
			return op;
		}

		public function read_iflt(abc:ABCByteArray):Instruction_iflt
		{
			var op:Instruction_iflt = new Instruction_iflt();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifle(abc:ABCByteArray):Instruction_ifle
		{
			var op:Instruction_ifle = new Instruction_ifle();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifgt(abc:ABCByteArray):Instruction_ifgt
		{
			var op:Instruction_ifgt = new Instruction_ifgt();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifge(abc:ABCByteArray):Instruction_ifge
		{
			var op:Instruction_ifge = new Instruction_ifge();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifstricteq(abc:ABCByteArray):Instruction_ifstricteq
		{
			var op:Instruction_ifstricteq = new Instruction_ifstricteq();
			op.offset = abc.readS24()
			return op;
		}

		public function read_ifstrictne(abc:ABCByteArray):Instruction_ifstrictne
		{
			var op:Instruction_ifstrictne = new Instruction_ifstrictne();
			op.offset = abc.readS24()
			return op;
		}

		
		public function read_lookupswitch(abc:ABCByteArray):Instruction_lookupswitch
		{
			var op:Instruction_lookupswitch = new Instruction_lookupswitch();
			
			op.defaultOffset = abc.readS24();
			var caseCount:uint = abc.readU30();
			op.caseOffsets = new Vector.<int>();
			for(var iter:uint = 0; iter < caseCount + 1; iter++)
			{
				op.caseOffsets[iter] = abc.readS24();
			}
			
			return op;
		}
		
		public function read_pushwith(abc:ABCByteArray):Instruction_pushwith
		{
			return new Instruction_pushwith();
		}

		public function read_popscope(abc:ABCByteArray):Instruction_popscope
		{
			return new Instruction_popscope();
		}

		public function read_nextname(abc:ABCByteArray):Instruction_nextname
		{
			return new Instruction_nextname();
		}

		public function read_hasnext(abc:ABCByteArray):Instruction_hasnext
		{
			return new Instruction_hasnext();
		}

		public function read_pushnull(abc:ABCByteArray):Instruction_pushnull
		{
			return new Instruction_pushnull();
		}

		public function read_pushundefined(abc:ABCByteArray):Instruction_pushundefined
		{
			return new Instruction_pushundefined();
		}

		public function read_nextvalue(abc:ABCByteArray):Instruction_nextvalue
		{
			return new Instruction_nextvalue();
		}
		
		public function read_newarray(abc:ABCByteArray):Instruction_newarray
		{
			var op:Instruction_newarray = new Instruction_newarray();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_newactivation(abc:ABCByteArray):Instruction_newactivation
		{
			return new Instruction_newactivation();
		}
		
		public function read_newcatch(abc:ABCByteArray):Instruction_newcatch
		{
			var op:Instruction_newcatch = new Instruction_newcatch();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_newclass(abc:ABCByteArray):Instruction_newclass
		{
			var op:Instruction_newclass = new Instruction_newclass();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_newfunction(abc:ABCByteArray):Instruction_newfunction
		{
			var op:Instruction_newfunction = new Instruction_newfunction();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_newobject(abc:ABCByteArray):Instruction_newobject
		{
			var op:Instruction_newobject = new Instruction_newobject();
			
			op.argCount = abc.readU30();
			
			return op;
		}
		
		public function read_pushbyte(abc:ABCByteArray):Instruction_pushbyte
		{
			var op:Instruction_pushbyte = new Instruction_pushbyte();
			
			op.byteValue = int(abc.readU8());
			
			return op;
		}
		
		public function read_pushdouble(abc:ABCByteArray):Instruction_pushdouble
		{
			var op:Instruction_pushdouble = new Instruction_pushdouble();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_pushscope(abc:ABCByteArray):Instruction_pushscope
		{
			return new Instruction_pushscope();
		}
		
		public function read_pushint(abc:ABCByteArray):Instruction_pushint
		{
			var op:Instruction_pushint = new Instruction_pushint();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_pushnamespace(abc:ABCByteArray):Instruction_pushnamespace
		{
			var op:Instruction_pushnamespace = new Instruction_pushnamespace();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_pushshort(abc:ABCByteArray):Instruction_pushshort
		{
			var op:Instruction_pushshort = new Instruction_pushshort();
			
			op.value = abc.readU30();
			
			return op;
		}
		
		public function read_pushtrue(abc:ABCByteArray):Instruction_pushtrue
		{
			return new Instruction_pushtrue();
		}
		
		public function read_pushfalse(abc:ABCByteArray):Instruction_pushfalse
		{
			return new Instruction_pushfalse();
		}
		
		public function read_pushnan(abc:ABCByteArray):Instruction_pushnan
		{
			return new Instruction_pushnan();
		}
		
		public function read_pop(abc:ABCByteArray):Instruction_pop
		{
			return new Instruction_pop();
		}
		
		public function read_dup(abc:ABCByteArray):Instruction_dup
		{
			return new Instruction_dup();
		}
		
		public function read_swap(abc:ABCByteArray):Instruction_swap
		{
			return new Instruction_swap();
		}

		public function read_pushstring(abc:ABCByteArray):Instruction_pushstring
		{
			var op:Instruction_pushstring = new Instruction_pushstring();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_pushuint(abc:ABCByteArray):Instruction_pushuint
		{
			var op:Instruction_pushuint = new Instruction_pushuint();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_setglobalslot(abc:ABCByteArray):Instruction_setglobalslot
		{
			var op:Instruction_setglobalslot = new Instruction_setglobalslot();
			
			op.slotIndex = abc.readU30();
			
			return op;
		}
		
		public function read_setlocal(abc:ABCByteArray):Instruction_setlocal
		{
			var op:Instruction_setlocal = new Instruction_setlocal();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_getglobalscope(abc:ABCByteArray):Instruction_getglobalscope
		{
			return new Instruction_getglobalscope();
		}
		
		public function read_setproperty(abc:ABCByteArray):Instruction_setproperty
		{
			var op:Instruction_setproperty = new Instruction_setproperty();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_setslot(abc:ABCByteArray):Instruction_setslot
		{
			var op:Instruction_setslot = new Instruction_setslot();
			
			op.slotIndex = abc.readU30();
			
			return op;
		}
		
		public function read_setsuper(abc:ABCByteArray):Instruction_setsuper
		{
			var op:Instruction_setsuper = new Instruction_setsuper();
			
			op.index = abc.readU30();
			
			return op;
		}
		
		public function read_si8(abc:ABCByteArray):Instruction_si8
		{
			return new Instruction_si8();
		}
		
		public function read_si16(abc:ABCByteArray):Instruction_si16
		{
			return new Instruction_si16();
		}
		
		public function read_si32(abc:ABCByteArray):Instruction_si32
		{
			return new Instruction_si32();
		}
		
		public function read_sf32(abc:ABCByteArray):Instruction_sf32
		{
			return new Instruction_sf32();
		}
		
		public function read_sf64(abc:ABCByteArray):Instruction_sf64
		{
			return new Instruction_sf64();
		}
		
		public function read_li8(abc:ABCByteArray):Instruction_li8
		{
			return new Instruction_li8();
		}
		
		public function read_li16(abc:ABCByteArray):Instruction_li16
		{
			return new Instruction_li16();
		}
		
		public function read_li32(abc:ABCByteArray):Instruction_li32
		{
			return new Instruction_li32();
		}
		
		public function read_lf32(abc:ABCByteArray):Instruction_lf32
		{
			return new Instruction_lf32();
		}
		
		public function read_lf64(abc:ABCByteArray):Instruction_lf64
		{
			return new Instruction_lf64();
		}
		
		public function read_sxi1(abc:ABCByteArray):Instruction_sxi1
		{
			return new Instruction_sxi1();
		}
		
		public function read_sxi8(abc:ABCByteArray):Instruction_sxi8
		{
			return new Instruction_sxi8();
		}
		
		public function read_sxi16(abc:ABCByteArray):Instruction_sxi16
		{
			return new Instruction_sxi16();
		}
	}
}