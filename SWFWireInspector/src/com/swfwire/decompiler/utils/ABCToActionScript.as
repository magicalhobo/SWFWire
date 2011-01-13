package com.swfwire.decompiler.utils
{
	import com.swfwire.decompiler.abc.ABCFile;
	import com.swfwire.decompiler.abc.AVM2;
	import com.swfwire.decompiler.abc.LocalRegisters;
	import com.swfwire.decompiler.abc.OperandStack;
	import com.swfwire.decompiler.abc.ScopeStack;
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.*;
	import com.swfwire.decompiler.abc.tokens.multinames.*;
	import com.swfwire.decompiler.abc.tokens.traits.*;
	import com.swfwire.utils.Debug;
	import com.swfwire.utils.ObjectUtil;
	import com.swfwire.utils.StringUtil;
	
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	public class ABCToActionScript
	{
		private var abcFile:ABCFile;
		private var offsetLookup:Object;
		
		public var showByteCode:Boolean = true;
		public var showActionScript:Boolean = true;
		public var showStack:Boolean = true;
		public var showDebug:Boolean = false;
		
		private var methodLookupCache:Array;
		private var customNamespaces:Object;
		
		public function ABCToActionScript(abcFile:ABCFile, offsetLookup:Object = null)
		{
			this.abcFile = abcFile;
			this.offsetLookup = offsetLookup;
			
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
		
		public function getMethodBody(name:uint, methodId:uint, r:ReadableTrait):void
		{
			r.arguments = new Vector.<ReadableMultiname>();
			r.declaration = new ReadableMultiname();
			r.traitType = ReadableTrait.TYPE_METHOD;
			multinameTraitToString(name, r.declaration);

			var methodInfo:MethodInfoToken = abcFile.methods[methodId];
			for(var iter:uint = 0; iter < methodInfo.paramCount; iter++)
			{
				var paramType:uint = methodInfo.paramTypes[iter];
				var readableArg:ReadableMultiname = new ReadableMultiname();
				getReadableMultiname(paramType, readableArg);
				r.arguments[iter] = readableArg;
				//args.push('arg'+iter+':'+multinameTypeToString(cpool, paramType));
			}
			var bodyId:int = getBodyIdFromMethodId(methodId);
			if(bodyId >= 0)
			{
				r.instructions = abcFile.methodBodies[bodyId].instructions;
			}
			
			r.type = new ReadableMultiname(); 
			getReadableMultiname(methodInfo.returnType, r.type);
		}
		
		public function getReadableTrait(traitInfo:TraitsInfoToken, r:ReadableTrait):void
		{
			r.arguments = new Vector.<ReadableMultiname>();
			
			var args:Array = [];
			var cpool:ConstantPoolToken = abcFile.cpool;
			r.declaration = new ReadableMultiname();
			multinameTraitToString(traitInfo.name, r.declaration);
			if(traitInfo.kind == TraitsInfoToken.KIND_TRAIT_SLOT)
			{
				var slotInfo:TraitSlotToken = TraitSlotToken(traitInfo.data);
				
				r.traitType = ReadableTrait.TYPE_PROPERTY;
				r.type = new ReadableMultiname();
				getReadableMultiname(slotInfo.typeName, r.type);
				//result = traitName+':'+multinameTypeToString(TraitSlotToken(traitInfo.data).typeName, r);
			}
			else if(traitInfo.kind == TraitsInfoToken.KIND_TRAIT_METHOD || traitInfo.kind == TraitsInfoToken.KIND_TRAIT_GETTER || traitInfo.kind == TraitsInfoToken.KIND_TRAIT_SETTER)
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
					r.localCount = abcFile.methodBodies[bodyId].localCount;
				}

				r.type = new ReadableMultiname(); 
				getReadableMultiname(methodInfo.returnType, r.type);
			}
			else if(traitInfo.kind == TraitsInfoToken.KIND_TRAIT_CONST)
			{
				r.traitType = ReadableTrait.TYPE_PROPERTY;
				r.type = new ReadableMultiname();
				getReadableMultiname(TraitSlotToken(traitInfo.data).typeName, r.type);
				r.isConst = true;
			}
			if(traitInfo.kind == TraitsInfoToken.KIND_TRAIT_GETTER)
			{
				r.declaration.name = 'get '+r.declaration.name;
			}
			if(traitInfo.kind == TraitsInfoToken.KIND_TRAIT_SETTER)
			{
				r.declaration.name = 'get '+r.declaration.name;
			}
			if(traitInfo.kind == TraitsInfoToken.KIND_TRAIT_SLOT || traitInfo.kind == TraitsInfoToken.KIND_TRAIT_CONST)
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
			if(ns.kind == NamespaceToken.KIND_PrivateNs)
			{
				result = 'private';
			}
			else if(ns.kind == NamespaceToken.KIND_PackageInternalNs)
			{
				result = 'internal';
			}
			else if(ns.kind == NamespaceToken.KIND_ProtectedNamespace || ns.kind == NamespaceToken.KIND_StaticProtectedNs)
			{
				result = 'protected';
			}
			else
			{
				result = abcFile.cpool.strings[ns.name].utf8;
			}
			return result;
		}
		
		private function instructionsToString(instructions:Vector.<IInstruction>,
											  argumentCount:uint,
											  localCount:uint,
											  start:uint = 0,
											  hitmap:Object = null, 
											  positionLookup:Dictionary = null,
											  stopOnJump:Boolean = false,
											  scope:ScopeStack = null,
											  locals:LocalRegisters = null,
											  stack:OperandStack = null,
											  target:int = -1):Object
		{
			var lines:Array = [];
			
			if(!scope)
			{
				scope = new ScopeStack(0);
			}
			if(!locals)
			{
				locals = new LocalRegisters();
				locals.setName(0, 'this');
				var iter:uint;
				for(iter = 0; iter < argumentCount; iter++)
				{
					locals.setName(iter + 1, 'arg'+iter);
				}
				for(; iter < localCount; iter++)
				{
					locals.setName(iter + 1, 'local'+(iter - argumentCount));
				}
			}
			if(!stack)
			{
				stack = new OperandStack(0);
			}
			var localCount:uint = 0;
			
			if(!hitmap)
			{
				hitmap = {};
			}
			if(!positionLookup)
			{
				positionLookup = new Dictionary();
				for(var iter1:uint = 0; iter1 < instructions.length; iter1++)
				{
					positionLookup[instructions[iter1]] = iter1;
				}
			}
			
			var flow:Array = [];
			var sourceUntil:Object = {};
			var breakOn:int = -1;
			
			for(var iter:uint = start; iter < instructions.length; iter++)
			{
				sourceUntil[iter] = lines.join('\n');
				
				if(hitmap[iter])
				{
					trace('already hit: '+iter);
					breakOn = iter;
					break;
				}
				if(iter == target)
				{
					trace('target hit: '+iter);
					breakOn = iter;
					break;
				}
				if(op is EndInstruction)
				{
					continue;
				}
				hitmap[iter] = 1;
				flow.push(iter);
				var op:IInstruction = instructions[iter];
				var params:Array = [];
				var line:String = '';
				var args:Array = [];
				var tempInt:int;
				var tempInt2:int;
				var tempStr:String;
				var tempStr2:String;
				var tempStr3:String;
				var mn:MultinameToken;
				var rmn:ReadableMultiname;
				var source:String = '';
				var exit:Boolean = false;
				var tempStr4:String;
				var b:Object;
				
				if(showByteCode)
				{
					var description:XML = describeType(op);
					var string:String = '    '
					string += StringUtil.padEnd('#'+iter, '      ');
					/*
					if(offsetLookup && offsetLookup[iter])
					{
					string += '#'+offsetLookup[iter]+'	';
					}
					*/
					
					if(!showDebug && (op is Instruction_debug || op is Instruction_debugfile || op is Instruction_debugline))
					{
						continue;
					}
					else
					{
						string += String(description.@name).replace(/.*Instruction_/, '');
					}
					
					for each(var name:String in description.variable.@name)
					{
						if(name.toLowerCase().indexOf('offset') != -1)
						{
							continue;
						}
						//multiname index
						if(name == 'index' && 
							(
								op is Instruction_callproperty ||
								op is Instruction_callpropvoid ||
								op is Instruction_coerce ||
								op is Instruction_findpropstrict ||
								op is Instruction_getproperty
							))
						{
							var r:ReadableMultiname = new ReadableMultiname();
							this.getReadableMultiname(op['index'], r);
							params.push(this.multinameTypeToString(r));
						}
						//string index
						else if(name == 'index' && (op is Instruction_pushstring))
						{
							params.push('"'+abcFile.cpool.strings[op['index']].utf8+'"');
						}
						else
						{
							var prop:* = op[name];
							if(prop is IInstruction)
							{
								prop = '#'+positionLookup[prop];
							}
							else if(prop is Vector.<IInstruction>)
							{
								var props:Array = [];
								for(tempInt = 0; tempInt < prop.length; tempInt++)
								{
									props.push('#'+positionLookup[prop[tempInt]]);
								}
								prop = props.join(', ');
							}
							params.push(name+': '+prop);
						}
						//props[name] = variable[name];
					}
					string += '  ' + params.join(', ');
					
					
					lines.push(string);
				}
				
				if(showActionScript)
				{
					function branch(target1:int, target2:int):Object
					{
						var tempStr1:String = '';
						var tempStr2:String = '';
						
						var hitmapCopy1:Object = {};
						var hitmapCopy2:Object = {};
						for(var iterHit1:String in hitmap)
						{
							hitmapCopy1[iterHit1] = hitmap[iterHit1];
							hitmapCopy2[iterHit1] = hitmap[iterHit1];
						}
						var r1:Object = instructionsToString(instructions, argumentCount, localCount, target1, hitmapCopy1, positionLookup, true, scope, locals, stack);
						var r2:Object = instructionsToString(instructions, argumentCount, localCount, target2, hitmapCopy2, positionLookup, true, scope, locals, stack);
						
						var isWhile:Boolean = false;
						
						var a1:int = -1;
						
						if(r1.breakOn > 0)
						{
							isWhile = true;
							r2.flow = {};
						}
						
						outer:
						for(var iter4:int = 0; iter4 < r1.flow.length; iter4++)
						{
							for(var iter5:int = 0; iter5 < r2.flow.length; iter5++)
							{
								if(r1.flow[iter4] == r2.flow[iter5])
								{
									a1 = r1.flow[iter4];
									r1.flow.splice(iter4);
									r2.flow.splice(iter5);
									break outer;
								}
							}
						}
						if(showByteCode)
						{
							if(a1 >= 0)
							{
								lines.push('		MERGE @'+a1);
							}
							else
							{
								lines.push('		NO MERGE');
							}
						}
						
						Debug.dump(r1.flow);
						Debug.dump(r2.flow);
						
						for(var iterHit2:uint = 0; iterHit2 < r1.flow.length; iterHit2++)
						{
							hitmap[r1.flow[iterHit2]] = 1;
						}
						
						for(var iterHit3:uint = 0; iterHit3 < r2.flow.length; iterHit3++)
						{
							hitmap[r2.flow[iterHit3]] = 1;
						}
						
						if(a1 >= 0)
						{
							tempStr1 = r1.sourceUntil[a1];
							tempStr2 = r2.sourceUntil[a1];
						}
						else
						{
							tempStr1 = r1.result;
							tempStr2 = r2.result;
						}
						
						trace(tempStr1);
						tempStr1 = StringUtil.indent(tempStr1, '	');
						tempStr2 = StringUtil.indent(tempStr2, '	');
						
						return {flow1: r1.flow, flow2: r2.flow, source1: tempStr1, source2: tempStr2, merge: a1, isWhile: isWhile};
					}
					
					function conditional(sign:String):String
					{
						tempStr4 = stack.pop();
						tempStr3 = stack.pop();
						
						tempInt = positionLookup[Object(op).reference];
						b = branch(tempInt, iter + 1);
						
						var cond:String = b.isWhile ? 'while' : 'if';
						
						tempStr2 = '';
						if(b.flow1.length > 0)
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = cond+'('+tempStr3+' '+sign+' '+tempStr4+')\n{\n'+b.source2+'\n}\nelse\n{\n'+b.source1+'\n}';
							}
						}
						else
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = cond+'('+tempStr3+' '+sign+' '+tempStr4+')\n{\n'+b.source2+'\n}';
							}
						}
						
						source = tempStr2;
						
						if(b.merge > 0)
						{
							iter = b.merge - 1;
						}
						return source;
					}

					if(op is EndInstruction)
					{
					}
					else if(op is Instruction_debug || op is Instruction_debugfile || op is Instruction_debugline)
					{
					}
					else if(op is Instruction_label)
					{
					}
					else if(op is Instruction_hasnext2)
					{
						tempStr = locals.getName(Instruction_hasnext2(op).objectReg);
						stack.push(tempStr+'.hasNext()');
					}
					else if(op is Instruction_lookupswitch)
					{
						tempInt = stack.pop();
						
						if(Instruction_lookupswitch(op).caseReferences.hasOwnProperty(tempInt))
						{
							tempInt2 = positionLookup[Instruction_lookupswitch(op).caseReferences[tempInt]];
						}
						else
						{
							tempInt2 = positionLookup[Instruction_lookupswitch(op).defaultReference];
						}
						
						if(!hitmap[tempInt2])
						{
							iter = tempInt2 - 1;
						}
						else
						{
							break;
						}
					}
					else if(op is Instruction_jump)
					{
						trace('jump!');
						if(stopOnJump)
						{
							trace('not stopping...');
							//break;
						}
						tempInt = positionLookup[Instruction_jump(op).reference];
						if(!hitmap[tempInt] || !stopOnJump)
						{
							iter = tempInt - 1;
						}
						else
						{
							break;
						}
					}
					else if(op is Instruction_ifstrictne)
					{
						trace('strictne jump!');
						tempInt = positionLookup[Instruction_ifstrictne(op).reference];
						var tempStr5:String = stack.pop();
						var tempStr6:String = stack.pop();
						
						var hitmapCopy:Object = {};
						for(var iter3:String in hitmap)
						{
							hitmapCopy[iter] = hitmap[iter];
						}
						tempStr = instructionsToString(instructions, argumentCount, localCount, tempInt, hitmap, positionLookup, true, scope, locals, stack).result;
						tempStr3 = instructionsToString(instructions, argumentCount, localCount, iter + 1, hitmapCopy, positionLookup, true, scope, locals, stack).result;
						trace(tempStr);
						
						for(var iter3:String in hitmapCopy)
						{
							hitmap[iter] = hitmapCopy[iter];
						}
						
						tempStr = StringUtil.indent(tempStr, '	');
						tempStr3 = StringUtil.indent(tempStr3, '	');
						
						tempStr2 = 'if('+tempStr5 + ' !== ' + tempStr6+')\n{\n'+tempStr+'\n}\nelse\n{\n'+tempStr3+'\n}';
						
						source = tempStr2;
					}
					else if(op is Instruction_iftrue)
					{
						tempStr4 = stack.pop();
						
						tempInt = positionLookup[Instruction_iftrue(op).reference];
						b = branch(tempInt, iter + 1);
						
						if(b.flow1.length > 0)
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = 'if('+tempStr4+')\n{\n'+b.source1+'\n}\nelse\n{\n'+b.source2+'\n}';
							}
							else
							{
								tempStr2 = 'if(!'+tempStr4+')\n{\n'+b.source2+'\n}';
							}
						}
						else
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = 'if('+tempStr4+')\n{\n'+b.source1+'\n}';
							}
							else
							{
								tempStr2 = '';
							}
						}
						
						source = tempStr2;

						if(b.merge > 0)
						{
							iter = b.merge - 1;
						}
					}
					else if(op is Instruction_iffalse)
					{
						tempStr4 = stack.pop();
						
						tempInt = positionLookup[Instruction_iffalse(op).reference];
						b = branch(tempInt, iter + 1);
						
						if(b.flow1.length > 0)
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = 'if('+tempStr4+')\n{\n'+b.source2+'\n}\nelse\n{\n'+b.source1+'\n}';
							}
							else
							{
								tempStr2 = 'if(!'+tempStr4+')\n{\n'+b.source1+'\n}';
							}
						}
						else
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = 'if('+tempStr4+')\n{\n'+b.source2+'\n}';
							}
							else
							{
								tempStr2 = '';
							}
						}
						
						source = tempStr2;

						if(b.merge > 0)
						{
							iter = b.merge - 1;
						}
					}
					else if(op is Instruction_iflt)
					{
						tempStr4 = stack.pop();
						tempStr3 = stack.pop();
						
						tempInt = positionLookup[Instruction_iflt(op).reference];
						b = branch(tempInt, iter + 1);
						
						tempStr2 = '';
						if(b.flow1.length > 0)
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = 'if('+tempStr3+' < '+tempStr4+')\n{\n'+b.source1+'\n}\nelse\n{\n'+b.source2+'\n}';
							}
						}
						else
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = 'if('+tempStr3+' < '+tempStr4+')\n{\n'+b.source1+'\n}';
							}
						}
						
						source = tempStr2;

						if(b.merge > 0)
						{
							iter = b.merge - 1;
						}
					}
					else if(op is Instruction_ifnge)
					{
						conditional('>=');
					}
					else if(op is Instruction_ifnle)
					{
						conditional('<=');
					}
					else if(op is Instruction_ifnlt)
					{
						conditional('<');
					}
					else if(op is Instruction_ifngt)
					{
						conditional('>');
					}
					else if(op is Instruction_getlocal0)
					{
						stack.push(locals.getName(0));
					}
					else if(op is Instruction_getlocal1)
					{
						stack.push(locals.getName(1));
					}
					else if(op is Instruction_getlocal2)
					{
						stack.push(locals.getName(2));
					}
					else if(op is Instruction_getlocal3)
					{
						stack.push(locals.getName(3));
					}
					else if(op is Instruction_getlocal)
					{
						stack.push(locals.getName(Instruction_getlocal(op).index));
					}
					else if(op is Instruction_setlocal0)
					{
						locals.setName(0, stack.pop());
					}
					else if(op is Instruction_setlocal1)
					{
						source = locals.getName(1)+' = '+stack.pop()+';';
					}
					else if(op is Instruction_setlocal2)
					{
						source = locals.getName(2)+' = '+stack.pop()+';';
					}
					else if(op is Instruction_setlocal3)
					{
						source = locals.getName(3)+' = '+stack.pop()+';';
					}
					else if(op is Instruction_setlocal)
					{
						locals.setName(Instruction_setlocal(op).index, stack.pop());
					}
					else if(op is Instruction_kill)
					{
						locals.setName(Instruction_kill(op).index, 'undefined');
					}
					else if(op is Instruction_throw)
					{
						source = 'throw '+stack.pop()+';';
					}
					/*
					else if(op is Instruction_newclass)
					{
						source = 'throw '+stack.pop()+';';
					}
					*/
					else if(op is Instruction_add)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						
						stack.push(tempStr2+' + '+tempStr);
					}
					else if(op is Instruction_subtract)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						
						stack.push(tempStr2+' - '+tempStr);
					}
					else if(op is Instruction_multiply)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						
						stack.push(tempStr2+' * '+tempStr);
					}
					else if(op is Instruction_divide)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						
						stack.push(tempStr2+' / '+tempStr);
					}
					else if(op is Instruction_negate)
					{
						tempStr = stack.pop();
						
						stack.push('-'+tempStr);
					}
					else if(op is Instruction_equals)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						
						stack.push('('+tempStr+') == ('+tempStr2+')');
					}
					else if(op is Instruction_not)
					{
						tempStr = stack.pop();
						
						stack.push('!('+tempStr+')');
					}
					else if(op is Instruction_findpropstrict)
					{
						tempInt = Instruction_findpropstrict(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_QName:
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								stack.push(tempStr);
								//stack.push(tempStr);
								//source = 'findprop - '+tempStr;
								break;
						}
					}
					else if(op is Instruction_getproperty)
					{
						tempInt = Instruction_getproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_QName:
								var obj:String = stack.pop();
								
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								if(obj != tempStr)
								{
									tempStr = obj+'.'+tempStr;
								}
								tempStr = tempStr;
								stack.push(tempStr);
								//source = 'getprop - '+tempStr;
								break;
						}
					}
					else if(op is Instruction_getlex)
					{
						tempInt = Instruction_getlex(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_QName:
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								tempStr = tempStr;
								stack.push(tempStr);
								//source = 'getprop - '+tempStr;
								break;
						}
					}
					else if(op is Instruction_callproperty)
					{
						tempInt = Instruction_callproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_QName:
								args = [];
								for(tempInt2 = Instruction_callproperty(op).argCount - 1; tempInt2 >= 0; tempInt2--)
								{
									args.unshift(stack.pop());
								}
								
								tempStr2 = stack.pop();
								
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								if(tempStr2 != tempStr)
								{
									tempStr = tempStr2+'.'+tempStr;
								}
								
								tempStr = tempStr+'('+args.join(', ')+')';
								localCount++;
								stack.push('local'+localCount);
								source = 'var local'+localCount+':* = '+tempStr+';';
								break;
						}
					}
					else if(op is Instruction_callpropvoid)
					{
						tempInt = Instruction_callpropvoid(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_QName:
								args = [];
								for(tempInt2 = Instruction_callpropvoid(op).argCount - 1; tempInt2 >= 0; tempInt2--)
								{
									args.unshift(stack.pop());
								}
								
								tempStr2 = stack.pop();
								
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								if(tempStr2 != tempStr)
								{
									tempStr = tempStr2+'.'+tempStr;
								}
								
								tempStr = tempStr+'('+args.join(', ')+')';
								source = tempStr+';';
								break;
						}
					}
					else if(op is Instruction_constructprop)
					{
						tempInt = Instruction_constructprop(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_QName:
								args = [];
								for(tempInt2 = Instruction_constructprop(op).argCount - 1; tempInt2 >= 0; tempInt2--)
								{
									args.unshift(stack.pop());
								}
								
								tempStr2 = stack.pop();
								
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								if(tempStr2 != tempStr)
								{
									tempStr = tempStr2+'.'+tempStr;
								}
								
								tempStr = tempStr+'('+args.join(', ')+')';
								localCount++;
								stack.push('local'+localCount);
								source = 'var local'+localCount+':* = new '+tempStr+';';
								break;
						}
					}
					else if(op is Instruction_constructsuper)
					{
						tempInt = Instruction_constructsuper(op).argCount;
						
						args = [];
						for(tempInt2 = 0; tempInt2 < tempInt; tempInt2++)
						{
							args.push(stack.pop());
						}
						
						//Not sure why this exists... should always be 'this'
						stack.pop();
						
						source = 'super('+args.join(', ')+');';
					}
					else if(op is Instruction_coerce)
					{
						tempStr = stack.pop();
						
						if(tempStr == 'null' || tempStr == 'undefined')
						{
							stack.push(tempStr);
						}
						else
						{
							tempInt = Instruction_coerce(op).index;
							
							rmn = new ReadableMultiname();
							getReadableMultiname(tempInt, rmn);
							tempStr2 = this.multinameTypeToString(rmn);

							stack.push(tempStr2+'('+tempStr+')');
						}
					}
					else if(op is Instruction_coerce_s)
					{
						tempStr = stack.pop();
						if(tempStr == 'null' || tempStr == 'undefined')
						{
							stack.push(tempStr);
						}
						else
						{
							stack.push('String('+tempStr+')');
						}
					}
					else if(op is Instruction_convert_d)
					{
						stack.push('Number('+stack.pop()+')');
					}
					else if(op is Instruction_kill)
					{
						locals.setName(Instruction_kill(op).index, 'undefined');
					}
					else if(op is Instruction_pushscope)
					{
						scope.push(stack.pop());
					}
					else if(op is Instruction_pushnull)
					{
						stack.push('null');
					}
					else if(op is Instruction_pushbyte)
					{
						stack.push(Instruction_pushbyte(op).byteValue);
					}
					else if(op is Instruction_pushshort)
					{
						stack.push(Instruction_pushshort(op).value);
					}
					else if(op is Instruction_pushdouble)
					{
						stack.push(abcFile.cpool.doubles[Instruction_pushdouble(op).index]);
					}
					else if(op is Instruction_pushstring)
					{
						stack.push('"'+abcFile.cpool.strings[Instruction_pushstring(op).index].utf8+'"');
					}
					else if(op is Instruction_pushtrue)
					{
						stack.push('true');
					}
					else if(op is Instruction_pushfalse)
					{
						stack.push('false');
					}
					else if(op is Instruction_pop)
					{
						stack.pop();
					}
					else if(op is Instruction_newobject)
					{
						var argCount:uint = Instruction_newobject(op).argCount;
						line += '{';
						for(var iter2:int = 0; iter2 < argCount; iter2++)
						{
							var valN:* = stack.pop();
							var nameN:* = stack.pop();
							line += nameN+': '+valN;
						}
						line += '}';
						stack.push(line);
					}
					else if(op is Instruction_returnvalue)
					{
						var str:String = stack.pop();
						source = 'return '+str+';';
						exit = true;
					}
					else if(op is Instruction_returnvoid)
					{
						source = 'return;';
						exit = true;
					}
					
					if(showStack)
					{
						lines.push('				stack: ' + stack.values.join(', '));
						lines.push('				local: ' + locals.names.join(', '));
					}
					
					if(source)
					{
						lines.push(source);
					}
					
					if(exit)
					{
						break;
					}
				}
			}
			return {result: lines.join('\n'), flow: flow, breakOn: breakOn, sourceUntil: sourceUntil};
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
					pieces.push('\n		{\n'+StringUtil.indent(instructionsToString(r.instructions, r.arguments.length, r.localCount).result, '			')+'\n		}');
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
			if(r.namespace == '' || r.namespace == 'http://adobe.com/AS3/2006/builtin')
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
			//properties.push(traitToString(c.traits[iter]));
			for(var iter:String in c.traits)
			{
				var str:String = traitToString(c.traits[iter]);
				if(str != '')
				{
					properties.push(str);
				}
			}
			var result:String = 
'package '+c.className.namespace+'\n' +
'{\n' +
'	public class '+c.className.name+' extends '+multinameTypeToString(c.superName)+'\n' +
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