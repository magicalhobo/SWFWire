package com.swfwire.decompiler.utils
{
	import com.swfwire.decompiler.abc.ABCFile;
	import com.swfwire.decompiler.abc.AVM2;
	import com.swfwire.decompiler.abc.LocalRegisters;
	import com.swfwire.decompiler.abc.OperandStack;
	import com.swfwire.decompiler.abc.ScopeStack;
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.*;
	import com.swfwire.decompiler.abc.tokens.cpool.CPoolIndex;
	import com.swfwire.decompiler.abc.tokens.multinames.*;
	import com.swfwire.decompiler.abc.tokens.traits.*;
	import com.swfwire.utils.Debug;
	import com.swfwire.utils.ObjectUtil;
	import com.swfwire.utils.StringUtil;
	
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getTimer;

	public class ABCToActionScript
	{
		private var abcFile:ABCFile;
		private var offsetLookup:Object;
		
		public var showByteCode:Boolean = true;
		public var showActionScript:Boolean = true;
		public var showStack:Boolean = true;
		public var showDebug:Boolean = false;
		public var showBranchInfo:Boolean = false;
		
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
					case MultinameToken.KIND_RTQName:
					case MultinameToken.KIND_RTQNameA:
						var rtqn:MultinameRTQNameToken = multiname.data as MultinameRTQNameToken;
						readable.name = cpool.strings[rtqn.name].utf8;
						break;
					default:
						readable.name = '#'+index+'/'+cpool.multinames.length+'('+multiname.kind+')';
						break;
				}
			}
		}
		
		public function getMethodBody(name:uint, methodId:uint, r:ReadableTrait):void
		{
			r.arguments = new Vector.<ReadableMultiname>();
			r.argumentNames = new Vector.<String>();
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
				
				if(methodInfo.paramNames[iter])
				{
					r.argumentNames[iter] = abcFile.cpool.strings[methodInfo.paramNames[iter].value].utf8;
				}
				else
				{
					r.argumentNames[iter] = 'arg'+iter;
				}

				//args.push('arg'+iter+':'+multinameTypeToString(cpool, paramType));
			}
			
			var bodyId:int = getBodyIdFromMethodId(methodId);
			if(bodyId >= 0)
			{
				var methodBody:MethodBodyInfoToken = abcFile.methodBodies[bodyId];
				r.instructions = methodBody.instructions;
				r.localCount = methodBody.localCount;
				r.slots = {};
				for(var iterTraits:uint = 0; iterTraits < methodBody.traits.length; iterTraits++)
				{
					var trait:TraitsInfoToken = methodBody.traits[iterTraits];
					if(trait.kind == TraitsInfoToken.KIND_TRAIT_SLOT)
					{
						var slotToken:TraitSlotToken = trait.data as TraitSlotToken;
						r.slots[slotToken.slotId] = abcFile.cpool.strings[MultinameQNameToken(abcFile.cpool.multinames[trait.name].data).name].utf8;
					}
				}
			}
			
			r.type = new ReadableMultiname(); 
			getReadableMultiname(methodInfo.returnType, r.type);
		}
		
		public function getReadableTrait(traitInfo:TraitsInfoToken, r:ReadableTrait):void
		{
			r.arguments = new Vector.<ReadableMultiname>();
			r.argumentNames = new Vector.<String>();
			
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
				r.slots = {};
				
				var traitMethod:TraitMethodToken = TraitMethodToken(traitInfo.data);
				var methodInfo:MethodInfoToken = abcFile.methods[traitMethod.methodId];
				for(var iter:uint = 0; iter < methodInfo.paramCount; iter++)
				{
					var paramType:uint = methodInfo.paramTypes[iter];
					var readableArg:ReadableMultiname = new ReadableMultiname();
					getReadableMultiname(paramType, readableArg);
					r.arguments[iter] = readableArg;
					
					if(methodInfo.paramNames[iter])
					{
						r.argumentNames[iter] = abcFile.cpool.strings[methodInfo.paramNames[iter].value].utf8;
					}
					else
					{
						r.argumentNames[iter] = 'arg'+iter;
					}
					//args.push('arg'+iter+':'+multinameTypeToString(cpool, paramType));
				}
				var bodyId:int = getBodyIdFromMethodId(traitMethod.methodId);
				if(bodyId >= 0)
				{
					var methodBody:MethodBodyInfoToken = abcFile.methodBodies[bodyId];
					r.instructions = methodBody.instructions;
					r.localCount = methodBody.localCount;
					for(var iterTraits:uint = 0; iterTraits < methodBody.traits.length; iterTraits++)
					{
						var trait:TraitsInfoToken = methodBody.traits[iterTraits];
						if(trait.kind == TraitsInfoToken.KIND_TRAIT_SLOT)
						{
							var slotToken:TraitSlotToken = trait.data as TraitSlotToken;
							r.slots[slotToken.slotId] = abcFile.cpool.strings[MultinameQNameToken(abcFile.cpool.multinames[trait.name].data).name].utf8;
						}
					}
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
		
		private function instructionsToString(startTime:int,
											  instructions:Vector.<IInstruction>,
											  argumentNames:Vector.<String>,
											  slotNames:Object,
											  localCount:uint,
											  start:uint = 0,
											  cache2:Object = null,
											  hitmap:Object = null, 
											  hitmapWithStack:Object = null, 
											  positionLookup:Dictionary = null,
											  stopOnJump:Boolean = false,
											  scope:ScopeStack = null,
											  locals:LocalRegisters = null,
											  stack:OperandStack = null,
											  target:int = -1,
											  depth:int = 0):Object
		{
			var lines:Array = [];
			
			trace('depth: '+depth+'	'+start);
			
			if(!scope)
			{
				scope = new ScopeStack(0);
			}
			if(!locals)
			{
				locals = new LocalRegisters();
				locals.setName(0, 'this');
				var iterArg:uint;
				var argumentCount:uint = argumentNames.length;
				for(iterArg = 0; iterArg < argumentCount; iterArg++)
				{
					locals.setName(iterArg + 1, argumentNames[iterArg]);
				}
				for(; iterArg < localCount; iterArg++)
				{
					locals.setName(iterArg + 1, 'local'+(iterArg - argumentCount));
				}
			}
			if(!stack)
			{
				stack = new OperandStack();
			}
			var localCount:uint = 0;
			
			if(!hitmap)
			{
				hitmap = {};
			}
			if(!hitmapWithStack)
			{
				hitmapWithStack = {};
			}
			if(!positionLookup)
			{
				positionLookup = new Dictionary();
				for(var iter1:uint = 0; iter1 < instructions.length; iter1++)
				{
					positionLookup[instructions[iter1]] = iter1;
				}
			}
			if(!cache2)
			{
				cache2 = {};
			}
			
			var subflow:Object = {};
			var flow:Array = [];
			var sourceUntil:Object = {};
			var breakOn:int = -1;
			var firstWasNextName:Boolean = false;
			var resultObj2:Object;
			var importantFlow:Array = [];
			
			/*
			if(getTimer() - startTime > 10000)
			{
				trace('Script timed out.');
				return {result: '//ERROR: DECOMPILE TIMEOUT', flow: flow, breakOn: breakOn, sourceUntil: sourceUntil, firstWasNextName: firstWasNextName};
			}
			*/

			for(var iter:uint = start; iter < instructions.length; iter++)
			{
				sourceUntil[iter] = lines.join('\n');
				
				var key:String = iter+':'+stack.values.join('|');
				//trace('for: '+key+' ('+stack.values.length+')');
				
				if(hitmap[iter])
				{
					//trace('hitmap hit: '+iter);
					//lines.push('HITMAP HIT');
					breakOn = iter;
					break;
				}
				/*
				if(cache[key])
				{
					trace('cache hit 13');
					resultObj2 = {result: lines.join('\n'), flow: flow, breakOn: breakOn, sourceUntil: sourceUntil, firstWasNextName: firstWasNextName};
					var cached:Object = cache[key];
					resultObj2.result += '\n--JOINED FROM '+key+'--\n' + cached.result;
					resultObj2.flow = resultObj2.flow.concat(cached.flow);
					for(var iter5:String in cached.sourceUntil)
					{
						resultObj2[iter5] = cached.sourceUntil[iter5];
					}
					resultObj2.breakOn = cached.breakOn;
					break;
				}
				*/
				if(hitmapWithStack[key])
				{
					//trace('hitmapWithStack hit: '+key);
					//lines.push('HITMAPSTACK HIT');
					break;
				}
				if(iter == target)
				{
					//trace('target hit: '+iter);
					breakOn = iter;
					break;
				}
				if(op is EndInstruction)
				{
					continue;
				}
				subflow[iter] = 1;
				hitmap[iter] = 1;
				hitmapWithStack[key] = 1;
				flow.push(key);
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
								op is Instruction_getlex ||
								op is Instruction_callproperty ||
								op is Instruction_callpropvoid ||
								op is Instruction_coerce ||
								op is Instruction_findpropstrict ||
								op is Instruction_getproperty ||
								op is Instruction_setproperty ||
								op is Instruction_findproperty ||
								op is Instruction_initproperty
							))
						{
							var r:ReadableMultiname = new ReadableMultiname();
							this.getReadableMultiname(op['index'], r);
							var mnString:String = this.multinameTypeToString(r);
							if(mnString == '?')
							{
								mnString = '(#'+op['index']+'/'+abcFile.cpool.multinames.length+')';
							}
							params.push(mnString);
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
						for(var iterHit1:String in hitmapWithStack)
						{
							hitmapCopy1[iterHit1] = hitmapWithStack[iterHit1];
							hitmapCopy2[iterHit1] = hitmapWithStack[iterHit1];
						}
						
						var hitmapCopy3:Object = {};
						var hitmapCopy4:Object = {};
						for(var iterHitmap:String in hitmap)
						{
							hitmapCopy3[iterHitmap] = hitmap[iterHitmap];
							hitmapCopy4[iterHitmap] = hitmap[iterHitmap];
						}
						
						var stackCopy1:OperandStack = new OperandStack();
						stackCopy1.values = stack.values.slice();
						var stackCopy2:OperandStack = new OperandStack();
						stackCopy2.values = stack.values.slice();
						
						trace('			branch point: '+iter);
						trace('			start branch from: '+target1);
						var r1:Object = instructionsToString(startTime, instructions, argumentNames, slotNames, localCount, target1, cache2, hitmapCopy3, hitmapCopy1, positionLookup, true, scope, locals, stackCopy1, -1, depth + 1);
						trace('			end branch from: '+target1);
						trace('			start branch from: '+target2);
						var r2:Object = instructionsToString(startTime, instructions, argumentNames, slotNames, localCount, target2, cache2, hitmapCopy4, hitmapCopy2, positionLookup, true, scope, locals, stackCopy2, -1, depth + 1);
						trace('			end branch from: '+target2);
						
						var isWhile:Boolean = false;
						var isForIn:Boolean = false;
						
						var a1:int = -1;
						var a2:String = '';
						
						var newStack:Vector.<Object> = stack.values;
						
						//Debug.dump({flow1: r1.flow, flow2: r2.flow});
						outer:
						for(var iter4:int = 0; iter4 < r1.flow.length; iter4++)
						{
							for(var iter5:int = 0; iter5 < r2.flow.length; iter5++)
							{
								if(r1.flow[iter4] == r2.flow[iter5])
								{
									a2 = r1.flow[iter4];
									var tempStack:Array = a2.split(':');
									a1 = tempStack.shift();
									if(tempStack[0])
									{
										tempStack = tempStack[0].split('|');
										newStack = Vector.<Object>(tempStack);
									}
									else
									{
										newStack = new Vector.<Object>();
									}
									
									r1.flow.splice(iter4);
									r2.flow.splice(iter5);
									break outer;
								}
							}
						}
						
						if(showBranchInfo)
						{
							lines.push('		MERGE @'+a1);
							lines.push('		FLOW1 LENGTH: '+r1.flow.length+', BREAK @'+r1.breakOn);
							lines.push('		FLOW2 LENGTH: '+r2.flow.length+', BREAK @'+r2.breakOn);
						}
						
						if(showBranchInfo)
						{
							if(a1 >= 0)
							{
								lines.push('		MERGE @'+a1);
								lines.push('		FLOW1 LENGTH: '+r1.flow.length+', BREAK @'+r1.breakOn);
								lines.push('		FLOW2 LENGTH: '+r2.flow.length+', BREAK @'+r2.breakOn);
							}
							else
							{
								lines.push('		NO MERGE');
								lines.push('		FLOW1 LENGTH: '+r1.flow.length+', BREAK @'+r1.breakOn);
								lines.push('		FLOW2 LENGTH: '+r2.flow.length+', BREAK @'+r2.breakOn);
							}
						}
						
						if(a1 == -1)
						{
							//if(r1.breakOn >= 0 && (r1.breakOn == a1 || a1 == -1))
							if(r1.breakOn >= 0)
							{
								for(var iterFlow1:String in subflow)
								{
									if(iterFlow1 == r1.breakOn)
									{
										isWhile = true;
										r2.flow = [];
										isForIn = r1.firstWasNextName;
										break;
									}
								}
							}
							//if(r2.breakOn >= 0 && (r2.breakOn == a1 || a1 == -1))
							if(r2.breakOn >= 0)
							{
								for(var iterFlow2:String in subflow)
								{
									if(iterFlow2 == r2.breakOn)
									{
										isWhile = true;
										r1.flow = [];
										isForIn = r2.firstWasNextName;
										break;
									}
								}
							}
						}
						
						//Debug.dump(r1.flow);
						//Debug.dump(r2.flow);
						
						for(var iterHit2:uint = 0; iterHit2 < r1.flow.length; iterHit2++)
						{
							if(r1.flow[iterHit2] == a1)
							{
								break;
							}
							hitmapWithStack[r1.flow[iterHit2]] = 1;
						}
						
						for(var iterHit3:uint = 0; iterHit3 < r2.flow.length; iterHit3++)
						{
							if(r2.flow[iterHit3] == a1)
							{
								break;
							}
							hitmapWithStack[r2.flow[iterHit3]] = 1;
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
						
						//trace(tempStr1);
						tempStr1 = tempStr1 ? StringUtil.indent(tempStr1, '	') : '';
						tempStr2 = tempStr2 ? StringUtil.indent(tempStr2, '	') : '';
						
						tempStr1 = tempStr1 ? tempStr1 : '';
						tempStr2 = tempStr2 ? tempStr2 : '';
						
						var localResult:Object = {flow1: r1.flow, flow2: r2.flow, source1: tempStr1, source2: tempStr2, merge: a1, isWhile: isWhile, isForIn: isForIn, newStack: newStack};
						return localResult;
					}
					
					function conditional(condition:String, inequality:Boolean):String
					{
						if(cache2[key])
						{
							trace('CACHE HIT!');
							trace('	key: '+key);
							var cached:Object = cache2[key];
							iter = cached.iter;
							source = cached.source;
							stack.values = cached.newStack;
							return 'CACHE @'+key+ '\n' + cached.source;
						}
						trace('CACHE MISS! EXECUTING EXPENSIVE BRANCH');
						trace('	key: '+key);
						tempInt = positionLookup[Object(op).reference];
						if(inequality)
						{
							b = branch(tempInt, iter + 1);
						}
						else
						{
							b = branch(iter + 1, tempInt);
						}
						
						stack.values = b.newStack;
						
						var cond:String = b.isWhile ? 'while' : 'if';
						if(b.isWhile && b.isForIn)
						{
							cond = 'forin';
						}
						
						tempStr2 = '';
						if(b.flow1.length > 0)
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = cond+'('+condition+')\n{\n'+b.source2+'\n}\nelse\n{\n'+b.source1+'\n}';
							}
							else
							{
								tempStr2 = cond+'(!('+condition+'))\n{\n'+b.source1+'\n}';
							}
						}
						else
						{
							if(b.flow2.length > 0)
							{
								tempStr2 = cond+'('+condition+')\n{\n'+b.source2+'\n}';
							}
						}
						
						source = tempStr2;
						
						if(b.merge > 0)
						{
							iter = b.merge - 1;
						}
						
						cache2[key] = {source: source, iter: iter, newStack: b.newStack};
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
					else if(op is Instruction_nextname)
					{
						if(lines.length == 0)
						{
							firstWasNextName = true;
						}
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						stack.push('nextname('+tempStr+', '+tempStr2+')');
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
						
						iter = tempInt2 - 1;
					}
					else if(op is Instruction_jump)
					{
						tempInt = positionLookup[Instruction_jump(op).reference];
						iter = tempInt - 1;
					}
					else if(op is Instruction_greaterthan)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						stack.push(tempStr2 + ' > '+ tempStr);
					}
					else if(op is Instruction_greaterequals)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						stack.push(tempStr2 + ' >= '+ tempStr);
					}
					else if(op is Instruction_lessthan)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						stack.push(tempStr2 + ' < '+ tempStr);
					}
					else if(op is Instruction_lessequals)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						stack.push(tempStr2 + ' <= '+ tempStr);
					}
					else if(op is Instruction_ifstrictne)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' !== '+tempStr, false);
					}
					else if(op is Instruction_iftrue)
					{
						tempStr4 = stack.pop();
						conditional(tempStr4, false);
					}
					else if(op is Instruction_iffalse)
					{
						tempStr4 = stack.pop();
						if(tempStr4 == 'false')
						{
							iter = positionLookup[Instruction_iffalse(op).reference] - 1;
						}
						else
						{
							conditional(tempStr4, true);
						}
					}
					else if(op is Instruction_ifeq)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' == '+tempStr, false);
					}
					else if(op is Instruction_ifne)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' != '+tempStr, false);
					}
					else if(op is Instruction_ifgt)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' > '+tempStr, false);
					}
					else if(op is Instruction_iflt)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' < '+tempStr, false);
					}
					else if(op is Instruction_ifge)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' >= '+tempStr, false);
					}
					else if(op is Instruction_ifle)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' <= '+tempStr, false);
					}
					else if(op is Instruction_ifnge)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' >= '+tempStr, true);
					}
					else if(op is Instruction_ifnle)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' <= '+tempStr, true);
					}
					else if(op is Instruction_ifnlt)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' < '+tempStr, true);
					}
					else if(op is Instruction_ifngt)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' > '+tempStr, true);
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
					else if(op is Instruction_getslot)
					{
						stack.push(slotNames[Instruction_getslot(op).slotIndex]);
					}
					else if(op is Instruction_setlocal0)
					{
						source = locals.getName(0)+' = '+stack.pop()+';';
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
						source = locals.getName(Instruction_setlocal(op).index)+' = '+stack.pop()+';';
					}
					else if(op is Instruction_setslot)
					{
						source = slotNames[Instruction_setslot(op).slotIndex]+' = '+stack.pop()+';';
					}
					else if(op is Instruction_kill)
					{
						locals.setValue(Instruction_kill(op).index, 'undefined');
					}
					else if(op is Instruction_dup)
					{
						tempStr = stack.pop();
						stack.push(tempStr);
						stack.push(tempStr);
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
					else if(op is Instruction_increment_i)
					{
						stack.push('int('+stack.pop()+') + 1');
					}
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
					else if(op is Instruction_modulo)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						
						stack.push(tempStr2+' % '+tempStr);
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
					else if(op is Instruction_strictequals)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						
						stack.push('('+tempStr+') === ('+tempStr2+')');
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
							default:
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								stack.push(tempStr);
								//stack.push(tempStr);
								//source = 'findprop - '+tempStr;
								break;
						}
					}
					else if(op is Instruction_findproperty)
					{
						tempInt = Instruction_findproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							default:
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								stack.push(tempStr);
								//source = 'getprop - '+tempStr;
								break;
						}
					}
					else if(op is Instruction_getproperty)
					{
						tempInt = Instruction_getproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						var obj:String = stack.pop();
						switch(mn.kind)
						{
							default:
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								break;
						}
						if(obj != tempStr)
						{
							tempStr = obj+'.'+tempStr;
						}
						stack.push(tempStr);
					}
					else if(op is Instruction_setproperty)
					{
						tempInt = Instruction_setproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							default:
								var value3:String = stack.pop();
								tempStr2 = stack.pop();
								
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								if(tempStr2 != tempStr)
								{
									tempStr = tempStr2+'.'+tempStr;
								}
								tempStr = tempStr;
								source = tempStr+' = '+value3+';';
								break;
						}
					}
					else if(op is Instruction_initproperty)
					{
						tempInt = Instruction_initproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							default:
								var value2:String = stack.pop();
								tempStr2 = stack.pop();
								
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								if(tempStr2 != tempStr)
								{
									tempStr = tempStr2+'.'+tempStr;
								}
								tempStr = tempStr;
								source = tempStr+' = '+value2+';';
								break;
						}
					}
					else if(op is Instruction_getlex)
					{
						tempInt = Instruction_getlex(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							default:
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
							default:
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
								/*
								stack.push('temp'+localCount);
								source = 'var temp'+localCount+':* = '+tempStr+';';
								*/
								stack.push(tempStr);
								break;
						}
					}
					else if(op is Instruction_callpropvoid)
					{
						tempInt = Instruction_callpropvoid(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							default:
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
							default:
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
								/*
								stack.push('temp'+localCount);
								source = 'var temp'+localCount+':* = new '+tempStr+';';
								*/
								stack.push('new '+tempStr);
								
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
					else if(op is Instruction_coerce_a)
					{
					}
					else if(op is Instruction_convert_b)
					{
						stack.push('Boolean('+stack.pop()+')');
					}
					else if(op is Instruction_convert_d)
					{
						stack.push('Number('+stack.pop()+')');
					}
					else if(op is Instruction_convert_i)
					{
						stack.push('int('+stack.pop()+')');
					}
					else if(op is Instruction_convert_u)
					{
						stack.push('uint('+stack.pop()+')');
					}
					else if(op is Instruction_typeof)
					{
						stack.push('typeof('+stack.pop()+')');
					}
					else if(op is Instruction_increment)
					{
						stack.push(stack.pop()+' + 1');
					}
					else if(op is Instruction_pushscope)
					{
						scope.push(stack.pop());
					}
					else if(op is Instruction_popscope)
					{
						scope.push(stack.pop());
					}
					else if(op is Instruction_getscopeobject)
					{
						stack.push(scope.values[scope.values.length - 1 - Instruction_getscopeobject(op).index]);
					}
					else if(op is Instruction_pushnull)
					{
						stack.push('null');
					}
					else if(op is Instruction_pushundefined)
					{
						stack.push('undefined');
					}
					else if(op is Instruction_pushnan)
					{
						stack.push('NaN');
					}
					else if(op is Instruction_pushbyte)
					{
						stack.push(Instruction_pushbyte(op).byteValue);
					}
					else if(op is Instruction_pushshort)
					{
						stack.push(Instruction_pushshort(op).value);
					}
					else if(op is Instruction_pushint)
					{
						stack.push(abcFile.cpool.integers[Instruction_pushint(op).index]);
					}
					else if(op is Instruction_pushuint)
					{
						stack.push(abcFile.cpool.uintegers[Instruction_pushuint(op).index]);
					}
					else if(op is Instruction_pushdouble)
					{
						stack.push(abcFile.cpool.doubles[Instruction_pushdouble(op).index]);
					}
					else if(op is Instruction_pushstring)
					{
						tempStr = abcFile.cpool.strings[Instruction_pushstring(op).index].utf8;
						tempStr = tempStr.replace('\r', '\\r');
						tempStr = tempStr.replace('\n', '\\n');
						stack.push('"'+tempStr+'"');
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
						tempStr = stack.pop();
						source = tempStr+';';
					}
					else if(op is Instruction_newarray)
					{
						var argCountA:uint = Instruction_newarray(op).argCount;
						var props2A:Array = [];
						for(var iter2A:int = 0; iter2A < argCountA; iter2A++)
						{
							var valNA:* = stack.pop();
							props2A.push(valNA);
						}
						props2A.reverse();
						line += '['+props2A.join(', ')+']';
						stack.push(line);
					}
					else if(op is Instruction_newobject)
					{
						var argCount:uint = Instruction_newobject(op).argCount;
						var props2:Array = [];
						for(var iter2:int = 0; iter2 < argCount; iter2++)
						{
							var valN:* = stack.pop();
							var nameN:* = stack.pop();
							props2.push(nameN+': '+valN);
						}
						props2.reverse();
						line += '{'+props2.join(', ')+'}';
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
						if(!(instructions[iter + 1] is EndInstruction))
						{
							source = 'return;';
						}
						else
						{
							source = '//return;';
						}
						exit = true;
					}
					else
					{
						lines.push('		//UNKNOWN OP: '+op);
					}
					
					if(showStack)
					{
						lines.push('				stack: ' + stack.values.join(', ')+'  ('+stack.values.length+')');
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
			var resultObj:Object;
			resultObj = {result: lines.join('\n'), flow: flow, breakOn: breakOn, sourceUntil: sourceUntil, firstWasNextName: firstWasNextName};
			/*
			for(var iter19:String in importantFlow)
			{
				cache[importantFlow[iter19]] = resultObj;
			}
			*/
			return resultObj;
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
					args.push(r.argumentNames[iter] + ':' + multinameTypeToString(r.arguments[iter]));
				}
				pieces.push(r.declaration.name);
				pieces.push('('+args.join(', ')+')');
				pieces.push(':'+multinameTypeToString(r.type));
				
				if(r.instructions && r.instructions.length > 0)
				{
					pieces.push('\n		{\n'+StringUtil.indent(instructionsToString(getTimer(), r.instructions, r.argumentNames, r.slots, r.localCount).result, '			')+'\n		}');
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
			if(r.namespace == '' || r.namespace == 'http://adobe.com/AS3/2006/builtin' || r.namespace == 'private')
			{
				result = r.name;
			}
			else
			{
				//result = r.namespace + '::' + r.name;
				result = r.namespace + '.' + r.name;
			}
			return result;
		}
		
		public function classToString(c:ReadableClass):String
		{
			var properties:Array = [];
			//properties.push(traitToString(c.traits[iter]));
			var runs:uint = 0;
			for(var iter:String in c.traits)
			{
				var str:String = traitToString(c.traits[iter]);
				if(str != '')
				{
					properties.push(str);
					runs++;
					if(runs >= 100)
					{
						break;
					}
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