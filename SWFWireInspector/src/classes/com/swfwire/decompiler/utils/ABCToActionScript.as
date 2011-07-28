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
		
		public function ABCToActionScript(abcFile:ABCFile, offsetLookup:Object = null, customNamespaces:Object = null)
		{
			this.abcFile = abcFile;
			this.offsetLookup = offsetLookup;
			
			methodLookupCache = new Array();
			for(var iter:uint = 0; iter < abcFile.methodBodyCount; iter++)
			{
				methodLookupCache[abcFile.methodBodies[iter].method] = iter;
			}
			
			if(!customNamespaces)
			{
				customNamespaces = {};
			}
			
			this.customNamespaces = customNamespaces;
		}
		
		public function getReadableMultinameRuntime(index:uint, readable:ReadableMultiname, stack:OperandStack):void
		{
			var cpool:ConstantPoolToken = abcFile.cpool;
			
			var multiname:MultinameToken = cpool.multinames[index];
			
			switch(multiname.kind)
			{
				case MultinameToken.KIND_RTQName:
				case MultinameToken.KIND_RTQNameA:
					var rtqn:MultinameRTQNameToken = multiname.data as MultinameRTQNameToken;
					readable.namespace = stack.pop();
					readable.name = cpool.strings[rtqn.name].utf8;
					break;
				case MultinameToken.KIND_MultinameL:
				case MultinameToken.KIND_MultinameLA:
					readable.namespace = '';
					readable.name = stack.pop();
					break;
				default:
					getReadableMultiname(index, readable);
					break;
			}
		}
		
		public function getReadableMultiname(index:uint, readable:ReadableMultiname):void
		{
			var cpool:ConstantPoolToken = abcFile.cpool;
			
			var multiname:MultinameToken = cpool.multinames[index];
			readable.namespace = '';
			readable.name = '?';
			var isAttribute:Boolean = false;
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
					case MultinameToken.KIND_Multiname:
					case MultinameToken.KIND_MultinameA:
						var mm:MultinameMultinameToken = multiname.data as MultinameMultinameToken;
						readable.namespace = '';
						readable.name = cpool.strings[mm.name].utf8;
						break;
					case MultinameToken.KIND_TypeName:
						var tn:MultinameTypeNameToken = multiname.data as MultinameTypeNameToken;
						var mq1:MultinameQNameToken = cpool.multinames[tn.name].data as MultinameQNameToken;
						var mq2:MultinameQNameToken = cpool.multinames[tn.subType].data as MultinameQNameToken;
						var rSub:ReadableMultiname = new ReadableMultiname();
						getReadableMultiname(tn.subType, rSub);
						readable.name = cpool.strings[mq1.name].utf8 + '.<' + multinameTypeToString(rSub) + '>';
						break;
					default:
						readable.name = '#'+index+'/'+cpool.multinames.length+'('+multiname.kind.toString(16)+')';
						break;
				}
				if(multiname.kind == MultinameToken.KIND_MultinameA)
				{
					readable.name = '@'+readable.name;
				}
			}
		}
		
		public function getReadableClass(index:uint, rc:ReadableClass):void
		{
			var classInfo:ClassInfoToken = abcFile.classes[index];
			var instance:InstanceToken = abcFile.instances[index];
			
			rc.type = instance.flags & InstanceToken.FLAG_CLASS_INTERFACE ? ReadableClass.INTERFACE : ReadableClass.CLASS;
			rc.className = new ReadableMultiname();
			getReadableMultiname(instance.name, rc.className);
			rc.superName = new ReadableMultiname();
			getReadableMultiname(instance.superName, rc.superName);
			rc.traits = new Array();
			rc.interfaces = new Array();
			
			var iter2:uint;
			var trait:TraitsInfoToken;
			var r:ReadableTrait;
			/*
			r = new ReadableTrait();
			translator.getMethodBody(instance.name, classInfo.cinit, r);
			rc.traits.push(r);
			*/
			r = new ReadableTrait();
			getMethodBody(instance.name, instance.iinit, r);
			r.type.name = '';
			r.declaration.namespace = 'public';
			rc.traits.push(r);
			
			for(iter2 = 0; iter2 < classInfo.traitCount; iter2++)
			{
				trait = classInfo.traits[iter2];
				r = new ReadableTrait();
				r.isStatic = true;
				getReadableTrait(trait, r);
				rc.traits.push(r);
			}
			
			for(iter2 = 0; iter2 < instance.traitCount; iter2++)
			{
				trait = instance.traits[iter2];
				r = new ReadableTrait();
				getReadableTrait(trait, r);
				rc.traits.push(r);
			}
			
			for(iter2 = 0; iter2 < instance.interfaceCount; iter2++)
			{
				rc.interfaces.push(instance.interfaces[iter2]);
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
			if(traitInfo.kind == TraitsInfoToken.KIND_TRAIT_CLASS)
			{
				r.traitType = ReadableTrait.TYPE_CLASS;
				r.classInfo = new ReadableClass();
				var traitClass:TraitClassToken = traitInfo.data as TraitClassToken;
				getReadableClass(traitClass.classId, r.classInfo);
			}
			else if(traitInfo.kind == TraitsInfoToken.KIND_TRAIT_SLOT)
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
				r.declaration.name = 'set '+r.declaration.name;
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
		
		private function instructionsToString(methodName:String,
											  startTime:int,
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
											  depth:int = 0,
											  definedLocals:Object = null):Object
		{
			var lines:Array = [];
			
			trace('depth: '+depth+'	'+start);
			
			if(!scope)
			{
				scope = new ScopeStack(0);
			}
			if(!definedLocals)
			{
				definedLocals = {};
			}
			if(!locals)
			{
				locals = new LocalRegisters();
				locals.setName(0, 'this');
				locals.setValue(0, 'this');
				var iterArg:uint;
				var argumentCount:uint = argumentNames.length;
				for(iterArg = 0; iterArg < argumentCount; iterArg++)
				{
					locals.setName(iterArg + 1, argumentNames[iterArg]);
					locals.setValue(iterArg + 1, argumentNames[iterArg]);
					definedLocals[iterArg + 1] = false;
				}
				for(; iterArg < localCount; iterArg++)
				{
					locals.setName(iterArg + 1, 'local'+(iterArg - argumentCount));
					locals.setValue(iterArg + 1, 'null');
					definedLocals[iterArg + 1] = false;
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
			var firstWasNextValue:Boolean = false;
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
				var tempArr:Array;
				var tempStr:String;
				var tempStr2:String;
				var tempStr3:String;
				var mn:MultinameToken;
				var rmn:ReadableMultiname;
				var source:String = '';
				var exit:Boolean = false;
				var tempStr4:String;
				var b:Object;
				var i:int;
				
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
						var r1:Object = instructionsToString(methodName, startTime, instructions, argumentNames, slotNames, localCount, target1, cache2, hitmapCopy3, hitmapCopy1, positionLookup, true, scope, locals, stackCopy1, -1, depth + 1, definedLocals);
						trace('			end branch from: '+target1);
						trace('			start branch from: '+target2);
						var r2:Object = instructionsToString(methodName, startTime, instructions, argumentNames, slotNames, localCount, target2, cache2, hitmapCopy4, hitmapCopy2, positionLookup, true, scope, locals, stackCopy2, -1, depth + 1, definedLocals);
						trace('			end branch from: '+target2);
						
						var isWhile:Boolean = false;
						var isForIn:Boolean = false;
						var isForEachIn:Boolean = false;
						
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
										isForEachIn = r1.firstWasNextValue;
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
										isForEachIn = r2.firstWasNextValue;
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
						
						var localResult:Object = {flow1: r1.flow, flow2: r2.flow, source1: tempStr1, source2: tempStr2, merge: a1, isWhile: isWhile, isForIn: isForIn, isForEachIn: isForEachIn, newStack: newStack};
						return localResult;
					}
					
					function conditional(condition:String, inequality:Boolean):String
					{
						var key2:String = iter+':'+stack.values.join('|');
						var cached:Object;
						if(cache2[key2])
						{
							trace('CACHE HIT!');
							trace('	key: '+key2);
							cached = cache2[key2];
							//return 'CACHE @'+key2+ '\n' + cached.source;
							b = cached.b;
						}
						else
						{
							trace('CACHE MISS! EXECUTING EXPENSIVE BRANCH');
							trace('	key: '+key2);
							tempInt = positionLookup[Object(op).reference];
							if(inequality)
							{
								b = branch(tempInt, iter + 1);
							}
							else
							{
								b = branch(iter + 1, tempInt);
							}
						}
						
						stack.values = b.newStack;
						
						var cond:String = b.isWhile ? 'while' : 'if';
						if(b.isWhile && b.isForIn)
						{
							cond = 'forin';
						}
						if(b.isWhile && b.isForEachIn)
						{
							cond = 'foreachin';
						}
						
						if(condition.substr(0, 5) == '<dup>')
						{
							condition = condition.substr(5);
						}
						
						var coercion:RegExp = /^Boolean\((.*)\)$/i;
						var result:Array = condition.match(coercion);
						if(result)
						{
							condition = result[1];
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
						
						if(showBranchInfo)
						{
							source = '//'+key2+'\n'+source;
						}
						
						if(cached)
						{
							if(showBranchInfo)
							{
								source = '[CACHED]\n'+source;
							}
						}
						else
						{
							cache2[key2] = {b: b};
						}
						return source;
					}
					
					function localAssign(id:int):void
					{
						var tempStr:String = stack.pop();
						var coercion:RegExp = /^([\w.]+)\((.*)\)$/i;
						var result:Array = tempStr.match(coercion);
						tempStr2 = result ? result[1] : '';
						tempStr3 = result ? result[2] : tempStr;
						
						if(!definedLocals[id] && tempStr2)
						{
							tempStr4 = tempStr2.split('.').pop();
							tempStr4 = tempStr4.substr(0, 1).toLowerCase() + tempStr4.substr(1);
							
							var tempLocal:String = tempStr4;
							var iterTempLocal:uint = 1;
							
							tempStr4 = tempLocal + '1';
							
							while(true)
							{
								var collision:Boolean = false;
								for(var iter:uint = 0; iter < locals.names.length; iter++)
								{
									if(locals.getName(iter) == tempStr4)
									{
										collision = true;
										break;
									}
								}
								if(!collision)
								{
									break;
								}
								iterTempLocal++;
								tempStr4 = tempLocal + iterTempLocal;
							}
							
							locals.setName(id, tempStr4);
						}
							
						var dec:String = locals.getName(id);
						var name:String = dec;
						
						if(!definedLocals[id])
						{
							dec = 'var '+dec;
							if(tempStr2)
							{
								dec = dec+':'+tempStr2;
							}
							definedLocals[id] = true;
						}

						if(tempStr3 != '<activation>' && tempStr3 != name)
						{
							source = dec+' = '+tempStr3+';';
						}
						locals.setValue(id, tempStr3);
					}
					
					function wrapInParenthesis(code:String):String
					{
						var alpha:RegExp = /^[\w.]+$/i;
						if(!alpha.test(code))
						{
							var stringLiteral:RegExp = /^"[^"]*"$/i;
							if(!stringLiteral.test(code))
							{
								code = '('+code+')';
							}
						}
						return code;
					}
					
					function coerce(type:String):void
					{
						var operand:String = stack.pop();
						var dup:Boolean = operand.substr(0, 5) == '<dup>';
						if(dup)
						{
							operand = operand.substr(5);
						}
						var matches:Array = operand.match(new RegExp('^'+type+'(.*)$'))
						if(!matches)
						{
							operand = type+'('+operand+')';
						}
						if(dup)
						{
							operand = '<dup>'+operand;
						}
						stack.push(operand);
					}

					if(op is EndInstruction)
					{
					}
					else if(op is Instruction_debug || op is Instruction_debugfile || op is Instruction_debugline)
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
					else if(op is Instruction_nextvalue)
					{
						if(lines.length == 0)
						{
							firstWasNextValue = true;
						}
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						stack.push('nextvalue('+tempStr+', '+tempStr2+')');
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
					else if(op is Instruction_ifstricteq)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' === '+tempStr, false);
					}
					else if(op is Instruction_ifne)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' != '+tempStr, false);
					}
					else if(op is Instruction_ifstrictne)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						conditional(tempStr2+' !== '+tempStr, false);
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
						//stack.push(locals.getValue(0));
					}
					else if(op is Instruction_getlocal1)
					{
						stack.push(locals.getName(1));
						//stack.push(locals.getValue(1));
					}
					else if(op is Instruction_getlocal2)
					{
						stack.push(locals.getName(2));
						//stack.push(locals.getValue(2));
					}
					else if(op is Instruction_getlocal3)
					{
						stack.push(locals.getName(3));
						//stack.push(locals.getValue(3));
					}
					else if(op is Instruction_getlocal)
					{
						stack.push(locals.getName(Instruction_getlocal(op).index));
						//stack.push(locals.getValue(Instruction_getlocal(op).index));
					}
					else if(op is Instruction_getslot)
					{
						tempStr = stack.pop();
						stack.push(slotNames[Instruction_getslot(op).slotIndex]);
					}
					else if(op is Instruction_setlocal0)
					{
						localAssign(0);
					}
					else if(op is Instruction_setlocal1)
					{
						localAssign(1);
					}
					else if(op is Instruction_setlocal2)
					{
						localAssign(2);
					}
					else if(op is Instruction_setlocal3)
					{
						localAssign(3);
					}
					else if(op is Instruction_setlocal)
					{
						localAssign(Instruction_setlocal(op).index);
					}
					else if(op is Instruction_setslot)
					{
						tempStr = stack.pop();
						tempStr3 = stack.pop();
						var matches:Array = tempStr.match(/([\w]+)\((.*)\)/s);
						tempStr2 = '*';
						if(matches)
						{
							tempStr = matches[2];
							tempStr2 = matches[1];
						}
						tempStr4 = slotNames[Instruction_setslot(op).slotIndex];
						if(tempStr4 != tempStr)
						{
							source = 'var '+tempStr4+':'+tempStr2+' = '+tempStr+';';
						}
						//source = slotNames[Instruction_setslot(op).slotIndex]+' = '+tempStr+';';
					}
					else if(op is Instruction_kill)
					{
						locals.setValue(Instruction_kill(op).index, 'undefined');
					}
					else if(op is Instruction_dup)
					{
						tempStr = stack.pop();
						if(tempStr.substr(0, 5) == '<dup>')
						{
							stack.push(tempStr);
						}
						else
						{
							stack.push('<dup>'+tempStr);
						}
						stack.push(tempStr);
					}
					else if(op is Instruction_swap)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						stack.push(tempStr);
						stack.push(tempStr2);
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
					else if(op is Instruction_decrement_i)
					{
						stack.push('int('+stack.pop()+') - 1');
					}
					else if(op is Instruction_add)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' + '+tempStr);
					}
					else if(op is Instruction_subtract)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' - '+tempStr);
					}
					else if(op is Instruction_multiply)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' * '+tempStr);
					}
					else if(op is Instruction_divide)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' / '+tempStr);
					}
					else if(op is Instruction_modulo)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' % '+tempStr);
					}
					else if(op is Instruction_negate)
					{
						tempStr = wrapInParenthesis(stack.pop());
						stack.push('-'+tempStr);
					}
					else if(op is Instruction_bitand)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' & '+tempStr);
					}
					else if(op is Instruction_bitor)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' | '+tempStr);
					}
					else if(op is Instruction_bitxor)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' ^ '+tempStr);
					}
					else if(op is Instruction_bitnot)
					{
						tempStr = wrapInParenthesis(stack.pop());
						stack.push('~'+tempStr);
					}
					else if(op is Instruction_lshift)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' << '+tempStr);
					}
					else if(op is Instruction_rshift)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' >> '+tempStr);
					}
					else if(op is Instruction_urshift)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr2+' >>> '+tempStr);
					}
					else if(op is Instruction_equals)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr+' == '+tempStr2);
					}
					else if(op is Instruction_strictequals)
					{
						tempStr = wrapInParenthesis(stack.pop());
						tempStr2 = wrapInParenthesis(stack.pop());
						stack.push(tempStr+' === '+tempStr2);
					}
					else if(op is Instruction_not)
					{
						tempStr = wrapInParenthesis(stack.pop());
						stack.push('!'+tempStr);
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
					else if(op is Instruction_getsuper)
					{
						tempInt = Instruction_getsuper(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						var obj:String = stack.pop();
						switch(mn.kind)
						{
							case MultinameToken.KIND_RTQNameL:
							case MultinameToken.KIND_RTQNameLA:
							case MultinameToken.KIND_MultinameL:
							case MultinameToken.KIND_MultinameLA:
								tempStr = stack.pop();
								tempStr = 'super['+obj+']';
								break;
							default:
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								if(obj != tempStr)
								{
									tempStr = 'super.'+tempStr;
								}
								break;
						}
						stack.push(tempStr);
					}
					else if(op is Instruction_setsuper)
					{
						tempInt = Instruction_setsuper(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_RTQNameL:
							case MultinameToken.KIND_RTQNameLA:
							case MultinameToken.KIND_MultinameL:
							case MultinameToken.KIND_MultinameLA:
								tempStr = stack.pop();
								tempStr2 = stack.pop();
								tempStr3 = stack.pop();
								source = 'super['+tempStr2+'] = '+tempStr+';';
								break;
							default:
								var value3:String = stack.pop();
								tempStr2 = stack.pop();
								
								rmn = new ReadableMultiname();
								getReadableMultiname(tempInt, rmn);
								tempStr = this.multinameTypeToString(rmn);
								
								if(tempStr2 != tempStr)
								{
									tempStr = 'super.'+tempStr;
								}
								tempStr = tempStr;
								source = tempStr+' = '+value3+';';
								break;
						}
					}
					else if(op is Instruction_getproperty)
					{
						tempInt = Instruction_getproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_RTQNameL:
							case MultinameToken.KIND_RTQNameLA:
							case MultinameToken.KIND_MultinameL:
							case MultinameToken.KIND_MultinameLA:
								tempStr2 = stack.pop();
								tempStr = stack.pop();
								tempStr = tempStr+'['+tempStr2+']';
								break;
							default:
								rmn = new ReadableMultiname();
								getReadableMultinameRuntime(tempInt, rmn, stack);
								tempStr2 = stack.pop();
								tempStr = this.multinameTypeToString(rmn);
								if(tempStr2 != tempStr)
								{
									tempStr = tempStr2+'.'+tempStr;
								}
								break;
						}
						stack.push(tempStr);
					}
					else if(op is Instruction_setproperty)
					{
						tempInt = Instruction_setproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_RTQNameL:
							case MultinameToken.KIND_RTQNameLA:
							case MultinameToken.KIND_MultinameL:
							case MultinameToken.KIND_MultinameLA:
								tempStr = stack.pop();
								tempStr2 = stack.pop();
								tempStr3 = stack.pop();
								source = tempStr3+'['+tempStr2+'] = '+tempStr+';';
								break;
							default:
								tempStr4 = stack.pop();
								
								rmn = new ReadableMultiname();
								getReadableMultinameRuntime(tempInt, rmn, stack);
								tempStr = this.multinameTypeToString(rmn);
								
								tempStr2 = stack.pop();
								
								if(tempStr2 != tempStr)
								{
									tempStr = tempStr2+'.'+tempStr;
								}
								tempStr = tempStr;
								source = tempStr+' = '+tempStr4+';';
								break;
						}
					}
					else if(op is Instruction_initproperty)
					{
						tempInt = Instruction_initproperty(op).index;
						mn = abcFile.cpool.multinames[tempInt];
						switch(mn.kind)
						{
							case MultinameToken.KIND_RTQNameL:
							case MultinameToken.KIND_RTQNameLA:
							case MultinameToken.KIND_MultinameL:
							case MultinameToken.KIND_MultinameLA:
								tempStr = stack.pop();
								tempStr2 = stack.pop();
								tempStr3 = stack.pop();
								source = tempStr3+'['+tempStr2+'] = '+tempStr+';';
								break;
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
					else if(op is Instruction_getdescendants)
					{
						tempInt = Instruction_getdescendants(op).index;
						mn = abcFile.cpool.multinames[tempInt];

						rmn = new ReadableMultiname();
						getReadableMultinameRuntime(tempInt, rmn, stack);
						tempStr2 = stack.pop();
						tempStr = this.multinameTypeToString(rmn);
						tempStr = tempStr2+'..'+tempStr;
						
						stack.push(tempStr);
					}
					else if(op is Instruction_call)
					{
						args = [];
						for(tempInt2 = Instruction_call(op).argCount - 1; tempInt2 >= 0; tempInt2--)
						{
							args.unshift(stack.pop());
						}
								
						tempStr2 = stack.pop();
						tempStr3 = stack.pop();
						
						if(tempStr2 == '<global>' || tempStr2 == 'null')
						{
							tempStr = tempStr3+'('+args.join(', ')+')';
						}
						else
						{
							args.unshift(tempStr2);
							tempStr = tempStr3+'.call('+args.join(', ')+')';
						}
						stack.push(tempStr);
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
					else if(op is Instruction_callsuper)
					{
						args = [];
						for(tempInt2 = Instruction_callsuper(op).argCount - 1; tempInt2 >= 0; tempInt2--)
						{
							args.unshift(stack.pop());
						}
						
						tempStr = 'super.'+methodName+'('+args.join(', ')+')';
						source = tempStr+';';
					}
					else if(op is Instruction_callsupervoid)
					{
						source = 'super();';
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
						
						tempInt = Instruction_coerce(op).index;
						
						rmn = new ReadableMultiname();
						getReadableMultiname(tempInt, rmn);
						tempStr2 = this.multinameTypeToString(rmn);

						stack.push(tempStr2+'('+tempStr+')');
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
						coerce('Boolean');
					}
					else if(op is Instruction_convert_d)
					{
						coerce('Number');
					}
					else if(op is Instruction_convert_i)
					{
						coerce('int');
					}
					else if(op is Instruction_convert_u)
					{
						coerce('uint');
					}
					else if(op is Instruction_applytype)
					{
						tempArr = [];
						for(i = 0; i < Instruction_applytype(op).argCount; i++)
						{
							tempArr.push(stack.pop());
						}
						tempArr.reverse();
						tempStr2 = tempArr.join(', ');
						tempStr = stack.pop();
						stack.push(tempStr+'.<'+tempStr2+'>');
					}
					else if(op is Instruction_astypelate)
					{
						tempStr = stack.pop();
						tempStr2 = stack.pop();
						stack.push(tempStr+'('+tempStr2+')');
					}
					else if(op is Instruction_construct)
					{
						tempArr = [];
						for(i = 0; i < Instruction_construct(op).argCount; i++)
						{
							tempArr.push(stack.pop());
						}
						tempArr.reverse();
						tempStr2 = tempArr.join(', ');
						tempStr = stack.pop();
						stack.push('new '+tempStr+'('+tempStr2+')');
					}
					else if(op is Instruction_typeof)
					{
						stack.push('typeof('+stack.pop()+')');
					}
					else if(op is Instruction_increment)
					{
						stack.push(stack.pop()+' + 1');
					}
					else if(op is Instruction_decrement)
					{
						stack.push(stack.pop()+' - 1');
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
					else if(op is Instruction_getglobalscope)
					{
						stack.push('<global>');
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
						tempStr = tempStr.replace(/\r/g, '\\r');
						tempStr = tempStr.replace(/\n/g, '\\n');
						tempStr = tempStr.replace(/'/g, '\\\'');
						stack.push('\''+tempStr+'\'');
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
						if(tempStr != '<wasdeleted>')
						{
							if(tempStr && tempStr.substr(0, 5) != '<dup>')
							{
								source = tempStr+';';
							}
						}
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
					else if(op is Instruction_newactivation)
					{
						stack.push('<activation>');
					}
					else if(op is Instruction_newfunction)
					{
						var r2:ReadableTrait = new ReadableTrait();
						getMethodBody(0, Instruction_newfunction(op).index, r2);
						stack.push(traitToString(r2, false, false, false, 0));
					}
					else if(op is Instruction_deleteproperty)
					{
						tempStr2 = stack.pop();
						rmn = new ReadableMultiname();
						getReadableMultinameRuntime(Instruction_deleteproperty(op).index, rmn, stack);
						tempStr = this.multinameTypeToString(rmn);
						source = 'delete '+tempStr+'['+tempStr2+'];';
						stack.push('<wasdeleted>');
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
						exit = true;
					}
					else if(op is Instruction_label)
					{
					}
					else if(op is Instruction_checkfilter)
					{
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
			resultObj = {result: lines.join('\n'), flow: flow, breakOn: breakOn, sourceUntil: sourceUntil, firstWasNextName: firstWasNextName,
				firstWasNextValue: firstWasNextValue};
			/*
			for(var iter19:String in importantFlow)
			{
				cache[importantFlow[iter19]] = resultObj;
			}
			*/
			return resultObj;
		}
		
		public function scriptTraitToString(r:ReadableTrait):String
		{
			var result:String = '';
			if(r.traitType == ReadableTrait.TYPE_CLASS)
			{
				result = classToString(r.classInfo);
			}
			else if(r.traitType == ReadableTrait.TYPE_NAMESPACE)
			{
				result = 
'package '+r.declaration.namespace+'\n'+
'{\n' +
'	public namespace '+r.declaration.name+' = '+r.initializer+';\n' +
'}';
			}
			return result;
		}
		
		public function traitToString(r:ReadableTrait, showMethodBody:Boolean = true, showNamespace:Boolean = true, showName:Boolean = true, methodIndents:int = 2):String
		{
			var pieces:Array = [];
			if(showNamespace)
			{
				var ns:String = customNamespaces.hasOwnProperty(r.declaration.namespace) ? customNamespaces[r.declaration.namespace] : r.declaration.namespace;
				pieces.push(ns+' ');
			}
			if(r.traitType == ReadableTrait.TYPE_METHOD)
			{
				if(r.isStatic)
				{
					pieces.push('static ');
				}
			}
			else if(r.traitType == ReadableTrait.TYPE_CLASS)
			{
				pieces.push(classToString(r.classInfo));
			}
			else if(r.traitType == ReadableTrait.TYPE_NAMESPACE)
			{
				pieces.push('namespace ');
				pieces.push(r.declaration.name);
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
				if(showName)
				{
					pieces.push('function ');
					pieces.push(r.declaration.name);
				}
				else
				{
					pieces.push('function');
				}
				pieces.push('('+args.join(', ')+')');
				
				var type:String = multinameTypeToString(r.type);
				if(type != '')
				{
					pieces.push(':'+type);
				}
				
				if(showMethodBody)
				{
					if(r.instructions && r.instructions.length > 0)
					{
						var indent:String = StringUtil.repeat('\t', methodIndents);
						pieces.push('\n'+indent+'{\n'+StringUtil.indent(instructionsToString(r.declaration.name, getTimer(), r.instructions, r.argumentNames, r.slots, r.localCount).result, indent+'	')+'\n'+indent+'}');
					}
					else
					{
						pieces.push(' {}');
					}
				}
				else
				{
					pieces.push(';');
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
		
		public function multinameTypeToString(r:ReadableMultiname, seperator:String = '::'):String
		{
			var result:String = '';
			if(customNamespaces[r.namespace])
			{
				r.namespace = customNamespaces[r.namespace];
			}
			if(r.namespace == '' || r.namespace == 'http://adobe.com/AS3/2006/builtin' || r.namespace == 'private' || r.namespace == 'protected' || r.namespace == 'internal')
			{
				result = r.name;
			}
			else
			{
				result = r.namespace + seperator + r.name;
			}
			return result;
		}
		
		public function classToString(c:ReadableClass):String
		{
			var properties:Array = [];
			
			var type:String = c.type;
			var isClass:Boolean = type == ReadableClass.CLASS;
			
			for(var iter:String in c.traits)
			{
				var rt:ReadableTrait = c.traits[iter]; 
				if(rt.traitType == ReadableTrait.TYPE_NAMESPACE)
				{
					var uri:String = rt.initializer.replace(/^"(.*)"$/, '$1');
					trace(uri);
					customNamespaces[uri] = multinameTypeToString(rt.declaration);
				}
			}
			
			for(var iter3:String in c.traits)
			{
				var rt2:ReadableTrait = c.traits[iter3];
				if(!isClass)
				{
					if(rt2.declaration.name == c.className.name && rt2.declaration.namespace == 'public')
					{
						continue;
					}
				}
				var str:String = traitToString(rt2, isClass, isClass);
				if(str != '')
				{
					properties.push(str);
				}
			}
			
			function startsWith(str:String, substr:String):Boolean
			{
				return str.substr(0, substr.length) == substr; 
			}
			
			function getRanking(str:String):int
			{
				var offset:int = 0;
				if(startsWith(str, 'public'))
				{
					offset = 3;
				}
				else if(startsWith(str, 'protected'))
				{
					offset = 2;
				}
				else if(startsWith(str, 'private'))
				{
					offset = 1;
				}
				
				str = str.substr(str.indexOf(' ') + 1);
				
				var typeOrder:Array = [
					'static const',
					'static var',
					'static function',
					'function '+c.className.name,
					'const',
					'var',
					'function get',
					'function set',
					'function',
				];
				
				for(var iter:int = 0; iter < typeOrder.length; iter++)
				{
					if(startsWith(str, typeOrder[iter]))
					{
						return (typeOrder.length - iter) * 4 + offset;
					}
				}
				return 0;
			}
			
			properties.sort(function(a:String, b:String):int
			{
				if(a == b)
				{
					return 0;
				}
				var aRank:int = getRanking(a);
				var bRank:int = getRanking(b);
				if(aRank == bRank)
				{
					return a.toLowerCase() < b.toLowerCase() ? -1 : 1;
				}
				return aRank < bRank ? 1 : -1;
			});
			
			var interfaces:Array = [];
			
			for(var iter2:uint = 0; iter2 < c.interfaces.length; iter2++)
			{
				var r:ReadableMultiname = new ReadableMultiname();
				getReadableMultiname(c.interfaces[iter2], r);
				interfaces.push(multinameTypeToString(r, '.'));
			}
			
			var interfaceString:String = '';
			
			if(interfaces.length > 0)
			{
				interfaceString = ' implements '+interfaces.join(', ');
			}
			
			var inheritanceString:String = '';
			var superName:String = multinameTypeToString(c.superName, '.');
			if(superName != '*' && superName != '' && superName != 'Object')
			{
				inheritanceString = ' extends '+superName;
			}
			
			var result:String = 
'package '+c.className.namespace+'\n' +
'{\n' +
'	public '+type+' '+c.className.name+inheritanceString+interfaceString+'\n' +
'	{\n' +
'		' + properties.join('\n		') + '\n' +
'	}\n' +
'}';
			return result;
		}
	}
}