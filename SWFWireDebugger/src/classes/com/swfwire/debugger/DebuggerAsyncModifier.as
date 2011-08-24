package com.swfwire.debugger
{
	import com.swfwire.debugger.utils.ABCWrapper;
	import com.swfwire.debugger.utils.InstructionLocation;
	import com.swfwire.debugger.utils.InstructionTemplate;
	import com.swfwire.decompiler.AsyncSWFModifier;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.*;
	import com.swfwire.decompiler.abc.tokens.multinames.*;
	import com.swfwire.decompiler.abc.tokens.traits.*;
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.SWFHeader;
	import com.swfwire.decompiler.data.swf.tags.*;
	import com.swfwire.decompiler.data.swf9.tags.*;
	
	import flash.utils.getTimer;

	public class DebuggerAsyncModifier extends AsyncSWFModifier
	{
		private var phase:uint;
		private var currentTagId:uint;
		private var swf:SWF;
		private var metadata:Vector.<ABCReaderMetadata>;
		private var addToStage:Boolean;
		public var foundMainClass:Boolean;
		public var mainClassPackage:String;
		public var mainClassName:String;
		public var backgroundColor:uint;
		
		public function DebuggerAsyncModifier(swf:SWF, metadata:Vector.<ABCReaderMetadata>, addToStage:Boolean = true, timeLimit:uint = 100)
		{
			super(timeLimit);
			
			this.swf = swf;
			this.metadata = metadata;
			this.addToStage = addToStage;
		}
		
		override public function start():Boolean
		{
			if(super.start())
			{
				phase = 1;
				currentTagId = 0;
				return true;
			}
			return false;
		}
		
		override protected function run():Number
		{
			switch(phase)
			{
				case 1:
					phase1();
					phase = 2;
					break;
				case 2:
					phase2();
					phase = 3;
					break;
				case 3:
					phase3();
					break;
			}
			
			return currentTagId/swf.tags.length;
		}
		
		protected function phase1():void
		{
			var start:uint = getTimer();
			
			swf.header.signature = SWFHeader.UNCOMPRESSED_SIGNATURE;
			
			var iTag:uint;
			
			backgroundColor = 0xFFFFFF;
			
			for(iTag = 0; iTag < swf.tags.length; iTag++)
			{
				var bgt:SetBackgroundColorTag = swf.tags[iTag] as SetBackgroundColorTag;
				if(bgt)
				{
					backgroundColor = bgt.backgroundColor.red << 16 | bgt.backgroundColor.green << 8 | bgt.backgroundColor.blue;
				}
			}
		}
		
		protected function phase2():void
		{
			var start:uint = getTimer();
			
			var mainClass:String = '';
			var iTag:uint;
			
			for(iTag = 0; iTag < swf.tags.length; iTag++)
			{
				var sct:SymbolClassTag = swf.tags[iTag] as SymbolClassTag;
				if(sct)
				{
					for(var isym:uint = 0; isym < sct.symbols.length; isym++)
					{
						if(sct.symbols[isym].characterId == 0)
						{
							mainClass = sct.symbols[isym].className;
						}
					}
				}
			}

			trace('main class: '+mainClass);
			
			foundMainClass = false;
			if(mainClass != '')
			{
				foundMainClass = true;
			}
			
			mainClassPackage = '';
			mainClassName = mainClass;
			
			if(mainClass.indexOf('.') >= 0)
			{
				mainClassName = mainClass.substr(mainClass.lastIndexOf('.') + 1);
				mainClassPackage = mainClass.substr(0, mainClass.lastIndexOf('.'));
			}			
		}
		
		protected function update(wrapper:ABCWrapper, abcTag:DoABCTag, ns:String, name:String, newNs:int = -1, newName:int = -1):void
		{
			var index:int = wrapper.getMultinameIndex(ns, name);
			if(index >= 0)
			{
				var qName:MultinameQNameToken = abcTag.abcFile.cpool.multinames[index].data as MultinameQNameToken;
				if(newNs >= 0)
				{
					qName.ns = newNs;
				}
				if(newName >= 0)
				{
					qName.name = newName;
				}
			}
		}
		
		protected function updatePublic(wrapper:ABCWrapper, abcTag:DoABCTag, name:String, newName:int):void
		{
			var nameIndex:int = wrapper.getStringIndex(name);
			if(nameIndex > 0)
			{
				for(var iter:* in abcTag.abcFile.cpool.multinames)
				{
					var qName:MultinameQNameToken = abcTag.abcFile.cpool.multinames[iter].data as MultinameQNameToken;
					if(qName)
					{
						if(qName.name == nameIndex)
						{
							qName.name = newName;
						}
					}
				}
			}
		}
		
		private function createClass(abcTag:DoABCTag, wrapper:ABCWrapper, name:String, superName:String):InstanceToken
		{
			wrapper.addQName(wrapper.addNamespaceFromString(''), wrapper.addString('Test'));
			
			var instance:InstanceToken = new InstanceToken();
			
			var constructorInstructions:Vector.<IInstruction> = Vector.<IInstruction>([
				new Instruction_getlocal0(),
				new Instruction_pushscope(),
				new Instruction_getlocal0(),
				new Instruction_constructsuper(),
				new Instruction_returnvoid()
			]);
			
			createMethod(abcTag, wrapper, instance, 'constructor', constructorInstructions, constructorInstructions.length);
			
			
			return instance;
		}
		
		protected function createMethod(abcTag:DoABCTag, wrapper:ABCWrapper, instance:InstanceToken, 
										name:String, instructions:Vector.<IInstruction>, maxStack:int,
										attributes:uint = 0):void
		{
			var methodQName:int = wrapper.addQName(
				wrapper.addNamespaceFromString(''), 
				wrapper.addString(name));
			
			var methodIndex:uint = abcTag.abcFile.methods.push(
				new MethodInfoToken(0, wrapper.addQName(wrapper.addNamespaceFromString(''), wrapper.addString('Object')))
			) - 1;
			
			var emptyMethod:MethodBodyInfoToken = new MethodBodyInfoToken(methodIndex, maxStack, 1, 0, 1);
			emptyMethod.instructions = instructions;
			
			var methodTrait:TraitsInfoToken = new TraitsInfoToken(methodQName,
				TraitsInfoToken.KIND_TRAIT_METHOD,
				attributes,
				new TraitMethodToken(0, methodIndex));
			
			instance.traits.push(methodTrait);
			
			abcTag.abcFile.methodBodies.push(emptyMethod);
		}
		
		protected function createMethodWithArguments(abcTag:DoABCTag, wrapper:ABCWrapper, instance:InstanceToken, 
										name:String, instructions:Vector.<IInstruction>, maxStack:int, localCount:int,
										args:Vector.<String>):void
		{
			var methodQName:int = wrapper.addQName(
				wrapper.addNamespaceFromString(''), 
				wrapper.addString(name));
			
			var params:Vector.<uint> = new Vector.<uint>();
			
			for(var iter:String in args)
			{
				var pieces:Array = args[iter].split(':', 2);
				params.push(wrapper.addQName(wrapper.addNamespaceFromString(pieces[0]), wrapper.addString(pieces[1])));
			}
			
			var methodIndex:uint = abcTag.abcFile.methods.push(
				new MethodInfoToken(params.length,
					wrapper.addQName(wrapper.addNamespaceFromString(''), wrapper.addString('Object')),
					params
				)
			) - 1;
			
			var emptyMethod:MethodBodyInfoToken = new MethodBodyInfoToken(methodIndex, maxStack, params.length + localCount + 1, 0, 1);
			emptyMethod.instructions = instructions;
			
			var methodTrait:TraitsInfoToken = new TraitsInfoToken(methodQName,
				TraitsInfoToken.KIND_TRAIT_METHOD,
				0,
				new TraitMethodToken(0, methodIndex));
			
			instance.traits.push(methodTrait);
			
			abcTag.abcFile.methodBodies.push(emptyMethod);
		}
		
		protected function phase3():void
		{
			if(currentTagId < swf.tags.length)
			{
				var abcTag:DoABCTag = swf.tags[currentTagId] as DoABCTag;
				if(abcTag)
				{
					var wrapper:ABCWrapper = new ABCWrapper(abcTag.abcFile, metadata[currentTagId]);
					var cpool:ConstantPoolToken = abcTag.abcFile.cpool;
					
					var injectedNamespace:uint = wrapper.addNamespaceFromString('com.swfwire.debugger.injected');
					
					function convert(ns:String, name:String):void
					{
						var index:int = wrapper.getMultinameIndex(ns, name);
						if(index >= 0)
						{
							var qName:MultinameQNameToken = cpool.multinames[index].data as MultinameQNameToken;
							qName.ns = injectedNamespace;
						}
					}
					
					convert('flash.system', 'Security');
					convert('flash.external', 'ExternalInterface');
					convert('flash.net', 'navigateToURL');
					convert('flash.net', 'URLLoader');
					convert('flash.net', 'URLStream');
					convert('flash.net', 'NetConnection');
					convert('flash.display', 'Loader');
					
					if(addToStage)
					{
						var rootInstance:InstanceToken = wrapper.getInstance(wrapper.getMultinameIndex(mainClassPackage, mainClassName));
						if(rootInstance)
						{
							var rootConstructor:MethodBodyInfoToken = wrapper.findMethodBody(rootInstance.iinit);
							
							var globalClassIndex:int = wrapper.addQName(
								wrapper.addNamespaceFromString('com.swfwire.debugger.injected'), 
								wrapper.addString('Globals'));
							
							var stageIndex:int = wrapper.addQName(
								wrapper.addNamespaceFromString(''), 
								wrapper.addString('stage'));
							
							var addChildIndex:int = wrapper.addQName(
								wrapper.addNamespaceFromString(''), 
								wrapper.addString('addChild'));
							
							rootConstructor.instructions.splice(0, 0,
								new Instruction_getlex(globalClassIndex),
								new Instruction_getproperty(stageIndex),
								new Instruction_getlocal0(),
								new Instruction_callpropvoid(addChildIndex, 1));
						}
					}
					
					var start:int;
					
					for(var iterInstance:int = 0; iterInstance < abcTag.abcFile.instances.length; iterInstance++)
					{
						start = getTimer();
						
						var thisInstance:InstanceToken = abcTag.abcFile.instances[iterInstance];
						if(thisInstance.flags & InstanceToken.FLAG_CLASS_INTERFACE)
						{
							continue;
						}
						
						var enumerateMethodsInstructions:Vector.<IInstruction> = new Vector.<IInstruction>();
						var enumeratePropertiesInstructions:Vector.<IInstruction> = new Vector.<IInstruction>();
						
						var hits:Object = {};
						
						for(var iterMainTraits:* in thisInstance.traits)
						{
							var traitsInfo:TraitsInfoToken = thisInstance.traits[iterMainTraits];
							var qname:MultinameQNameToken;
							if(traitsInfo.kind == TraitsInfoToken.KIND_TRAIT_METHOD)
							{
								qname = cpool.multinames[traitsInfo.name].data as MultinameQNameToken;
								enumerateMethodsInstructions.push(new Instruction_pushstring(qname.name));
								enumerateMethodsInstructions.push(new Instruction_getlocal0);
								enumerateMethodsInstructions.push(new Instruction_getproperty(traitsInfo.name));
							}
							else if(traitsInfo.kind == TraitsInfoToken.KIND_TRAIT_SLOT ||
									traitsInfo.kind == TraitsInfoToken.KIND_TRAIT_GETTER ||
									traitsInfo.kind == TraitsInfoToken.KIND_TRAIT_SETTER)
							{
								qname = cpool.multinames[traitsInfo.name].data as MultinameQNameToken;
								var kind:uint = cpool.namespaces[qname.ns].kind;
								if(kind == NamespaceToken.KIND_Namespace ||
								   kind == NamespaceToken.KIND_PrivateNs ||
								   kind == NamespaceToken.KIND_ProtectedNamespace ||
								   kind == NamespaceToken.KIND_PackageInternalNs)
								{
									if(!hits[qname.name])
									{
										hits[qname.name] = true;
										enumeratePropertiesInstructions.push(new Instruction_pushstring(qname.name));
										enumeratePropertiesInstructions.push(new Instruction_getlocal0);
										enumeratePropertiesInstructions.push(new Instruction_getproperty(traitsInfo.name));
									}
								}
							}
						}
						
						var uniqueID:String = wrapper.getQNameString(thisInstance.name, '::');
						
						enumerateMethodsInstructions.push(new Instruction_newobject(enumerateMethodsInstructions.length * 1 / 3));
						enumerateMethodsInstructions.push(new Instruction_returnvalue());
						createMethod(abcTag, wrapper, thisInstance, 'swfWire_enumerateMethods_'+uniqueID, enumerateMethodsInstructions, enumerateMethodsInstructions.length);

						enumeratePropertiesInstructions.push(new Instruction_newobject(enumeratePropertiesInstructions.length * 1 / 3));
						enumeratePropertiesInstructions.push(new Instruction_returnvalue());
						createMethod(abcTag, wrapper, thisInstance, 'swfWire_enumerateProperties_'+uniqueID, enumeratePropertiesInstructions, enumeratePropertiesInstructions.length);

						var instanceNamespace:String = wrapper.getQNameString(thisInstance.name, ':');
						var instanceNamespaceIndex:int = wrapper.addString(instanceNamespace);
						
						var instanceNSSet:NamespaceSetToken = new NamespaceSetToken();
						instanceNSSet.namespaces.push(cpool.namespaces.length);
						cpool.namespaces.push(new NamespaceToken(NamespaceToken.KIND_PrivateNs, instanceNamespaceIndex));
						cpool.namespaces.push(new NamespaceToken(NamespaceToken.KIND_ProtectedNamespace, instanceNamespaceIndex));
						
						for(var iterNS:int = 1; iterNS < cpool.namespaces.length; iterNS++)
						{
							instanceNSSet.namespaces.push(iterNS);
						}
						instanceNSSet.count = instanceNSSet.namespaces.length;
						var instanceNSSetIndex:int = cpool.nsSets.length;
						cpool.nsSets.push(instanceNSSet);
						
						var wildcardMultiname:MultinameToken = new MultinameToken(MultinameToken.KIND_MultinameL, new MultinameMultinameLToken(instanceNSSetIndex));
						var wildcardMultinameIndex:int = cpool.multinames.length;
						cpool.multinames.push(wildcardMultiname);
						
						var setPropertyInstructions:Vector.<IInstruction> = new Vector.<IInstruction>();
						setPropertyInstructions.push(new Instruction_getlocal0());
						setPropertyInstructions.push(new Instruction_getlocal1());
						setPropertyInstructions.push(new Instruction_getlocal2());
						setPropertyInstructions.push(new Instruction_setproperty(wildcardMultinameIndex));
						setPropertyInstructions.push(new Instruction_pushtrue());
						setPropertyInstructions.push(new Instruction_returnvalue());
						createMethodWithArguments(abcTag,
							wrapper,
							thisInstance, 
							'swfWire_setProperty_'+uniqueID,
							setPropertyInstructions,
							setPropertyInstructions.length,
							0,
							Vector.<String>([':String', ':Object']));
						
						var getPropertyInstructions:Vector.<IInstruction> = new Vector.<IInstruction>();
						getPropertyInstructions.push(new Instruction_getlocal0());
						getPropertyInstructions.push(new Instruction_getlocal1());
						getPropertyInstructions.push(new Instruction_getproperty(wildcardMultinameIndex));
						getPropertyInstructions.push(new Instruction_returnvalue());
						createMethodWithArguments(abcTag,
							wrapper,
							thisInstance, 
							'swfWire_getProperty_'+uniqueID,
							getPropertyInstructions,
							getPropertyInstructions.length,
							0,
							Vector.<String>([':String']));
						
						trace('Creating property accessors took '+(getTimer() - start)+'ms');
					}
					
					if(true)
					{
						var l:*;
						const minScopeDepth:uint = 0;
						
						var loggerClassIndex:int = wrapper.addQName(
							wrapper.addNamespaceFromString('com.swfwire.debugger.injected'), 
							wrapper.addString('Logger'));
						
						var emptyNS:int = wrapper.addNamespaceFromString('');
						
						var enterFunctionIndex:int = wrapper.addQName(emptyNS, wrapper.addString('enterFunction'));
						var exitFunctionIndex:int = wrapper.addQName(emptyNS, wrapper.addString('exitFunction'));
						var newObjectIndex:int = wrapper.addQName(emptyNS, wrapper.addString('newObject'));
						
						start = getTimer();
						
						var traceIndex:int = wrapper.getMultinameIndex('', 'trace');
						if(traceIndex >= 0)
						{
							l = wrapper.findInstruction(new InstructionTemplate(Instruction_findpropstrict, {index: traceIndex}));
							
							for(var iter:* in l)
							{
								abcTag.abcFile.methodBodies[l[iter].methodBody].maxStack += 1;
							}
							
							wrapper.replaceInstruction2(l, function(z:*, a:Vector.<IInstruction>):Vector.<IInstruction>
							{
								var b:Vector.<IInstruction> = new Vector.<IInstruction>();
								b.push(new Instruction_getlex(loggerClassIndex));
								wrapper.redirectReferences(z.methodBody, a[0], b[0]);
								return b;
							});
							
							var methodIndex:int = wrapper.addQName(emptyNS, wrapper.addString('log'));
							
							l = wrapper.findInstruction(new InstructionTemplate(Instruction_callpropvoid, {index: traceIndex}));
							wrapper.replaceInstruction2(l, function(z:*, a:Vector.<IInstruction>):Vector.<IInstruction>
							{
								var b:Vector.<IInstruction> = new Vector.<IInstruction>();
								b.push(new Instruction_callpropvoid(methodIndex, Object(a[0]).argCount));
								wrapper.redirectReferences(z.methodBody, a[0], b[0]);
								return b;
							});
							
							l = wrapper.findInstruction(new InstructionTemplate(Instruction_callproperty, {index: traceIndex}));
							wrapper.replaceInstruction2(l, function(z:*, a:Vector.<IInstruction>):Vector.<IInstruction>
							{
								var b:Vector.<IInstruction> = new Vector.<IInstruction>();
								b.push(new Instruction_callproperty(methodIndex, Object(a[0]).argCount));
								wrapper.redirectReferences(z.methodBody, a[0], b[0]);
								return b;
							});
						}
						
						trace('Alterting trace statements took '+(getTimer() - start)+'ms');
						
						var nameFromMethodId:Object = {};
						
						function qnameToString(instance:String, index:uint):String
						{
							var result:String = '<Not a QName>';
							var mq:MultinameQNameToken = cpool.multinames[index].data as MultinameQNameToken;
							if(mq)
							{
								var ns:String = cpool.strings[cpool.namespaces[mq.ns].name].utf8;
								if(ns == instance)
								{
									ns = '';
								}
								if(ns != '')
								{
									ns = ns + ':';
								}
								result = ns + cpool.strings[mq.name].utf8;
							}
							return result;
						}
						
						start = getTimer();
						
						for(var i11:int = 0; i11 < abcTag.abcFile.instances.length; i11++)
						{
							var inst2:InstanceToken = abcTag.abcFile.instances[i11];
							
							var instName:String = qnameToString('', inst2.name);
							
							nameFromMethodId[inst2.iinit] = instName;
							for(var i12:int = 0; i12 < inst2.traits.length; i12++)
							{
								var name:String = qnameToString(instName, inst2.traits[i12].name);
								var tmt:TraitMethodToken = inst2.traits[i12].data as TraitMethodToken;
								switch(inst2.traits[i12].kind)
								{
									case TraitsInfoToken.KIND_TRAIT_GETTER:
										name = 'get '+name;
										break;
									case TraitsInfoToken.KIND_TRAIT_SETTER:
										name = 'set '+name;
										break;
								}
								if(tmt)
								{
									nameFromMethodId[tmt.methodId] = instName+'/'+name;
								}
							}
						}
						
						for(var i13:int = 0; i13 < abcTag.abcFile.classes.length; i13++)
						{
							var classInfo:ClassInfoToken = abcTag.abcFile.classes[i13];
							var inst3:InstanceToken = abcTag.abcFile.instances[i13];
							
							var className:String = qnameToString('', inst3.name);
							
							nameFromMethodId[classInfo.cinit] = className+'$cinit';
							
							for(var i14:int = 0; i14 < classInfo.traits.length; i14++)
							{
								var name2:String = qnameToString('', classInfo.traits[i14].name);
								var tmt2:TraitMethodToken = classInfo.traits[i14].data as TraitMethodToken;
								switch(classInfo.traits[i14].kind)
								{
									case TraitsInfoToken.KIND_TRAIT_GETTER:
										name = 'get '+name;
										break;
									case TraitsInfoToken.KIND_TRAIT_SETTER:
										name = 'set '+name;
										break;
								}
								if(tmt2)
								{
									nameFromMethodId[tmt2.methodId] = className+'$/'+name2;
								}
							}
						}
						
						for(var i20:int = 0; i20 < abcTag.abcFile.scripts.length; i20++)
						{
							var scriptInfo:ScriptInfoToken = abcTag.abcFile.scripts[i20];
							
							nameFromMethodId[scriptInfo.init] = 'global$init';
						}
						
						l = wrapper.findInstruction(new InstructionTemplate(Instruction_newfunction, {}));
						
						for(var i15:int = 0; i15 < l.length; i15++)
						{
							var mb2:MethodBodyInfoToken = abcTag.abcFile.methodBodies[l[i15].methodBody];
							var newfinst:Instruction_newfunction = mb2.instructions[l[i15].id] as Instruction_newfunction;
							var anonMethodName:String = nameFromMethodId[mb2.method];
							if(anonMethodName)
							{
								anonMethodName = anonMethodName+'/<anonymous>';
							}
							else
							{
								anonMethodName = '<anonymous>';
							}
							nameFromMethodId[newfinst.index] = anonMethodName;
						}
						
						trace('Determining method names took '+(getTimer() - start)+'ms');
						
						start = getTimer();
						
						l = new Vector.<InstructionLocation>;
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_construct, {})));
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_constructprop, {})));
						
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_newobject, {})));
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_newarray, {})));
						
						trace('Finding newobject calls took '+(getTimer() - start)+'ms');
						
						start = getTimer();
						
						for(var iter7:* in l)
						{
							abcTag.abcFile.methodBodies[l[iter7].methodBody].maxStack += 1;
						}
						
						wrapper.replaceInstruction2(l, function(z:InstructionLocation, a:Vector.<IInstruction>):Vector.<IInstruction>
						{
							var mb:MethodBodyInfoToken = abcTag.abcFile.methodBodies[z.methodBody];
							if(mb.initScopeDepth >= minScopeDepth)
							{
								a.push(new Instruction_dup());
								a.push(new Instruction_getlex(loggerClassIndex));
								a.push(new Instruction_swap());
								a.push(new Instruction_callpropvoid(newObjectIndex, 1));
							}
							wrapper.redirectReferences(z.methodBody, a[a.length - 1], a[0]);
							return a;
						});
						
						trace('Replacing newobject calls took '+(getTimer() - start)+'ms');

						start = getTimer();
						
						for(var i9:int = 0; i9 < abcTag.abcFile.methodBodies.length; i9++)
						{
							var mb:MethodBodyInfoToken = abcTag.abcFile.methodBodies[i9];
							
							if(!nameFromMethodId[mb.method])
							{
								//trace('Couldn\'t find a method name for '+mb.method);
							}
							
							if(mb.initScopeDepth >= minScopeDepth)
							{
								var j9:* = abcTag.abcFile.methodBodies[i9].instructions;
								
								var paramCount:uint = abcTag.abcFile.methods[mb.method].paramCount;
								
								abcTag.abcFile.methodBodies[i9].maxScopeDepth += 1;
								
								j9.unshift(new Instruction_popscope());
								j9.unshift(new Instruction_callpropvoid(enterFunctionIndex, 3));
								
								if(paramCount > 0)
								{
									abcTag.abcFile.methodBodies[i9].maxStack += paramCount * 2 + 3;
									j9.unshift(new Instruction_newobject(paramCount));
									
									for(var i10:int = paramCount - 1; i10 >= 0; i10--)
									{
										var method:MethodInfoToken = abcTag.abcFile.methods[mb.method];
										var paramName:ParamInfoToken;
										if(method.paramNames.length > i10)
										{
											paramName = method.paramNames[i10];
										}
										j9.unshift(new Instruction_getlocal(i10 + 1));
										if(paramName && paramName.value > 0)
										{
											j9.unshift(new Instruction_pushstring(paramName.value));
										}
										else
										{
											j9.unshift(new Instruction_pushstring(wrapper.addString('param'+i10)));
										}
									}
								}
								else
								{
									abcTag.abcFile.methodBodies[i9].maxStack += 4;
									j9.unshift(new Instruction_pushnull());
								}
								
								j9.unshift(new Instruction_getlocal0());
								
								var methodId:int = wrapper.addString(currentTagId+'.'+String(i9));
								var methodName:String = nameFromMethodId[mb.method];
								if(methodName)
								{
									methodId =  wrapper.addString(methodName);
								}
								j9.unshift(new Instruction_pushstring(methodId));
								j9.unshift(new Instruction_getlex(loggerClassIndex));
								j9.unshift(new Instruction_pushscope());
								j9.unshift(new Instruction_getlocal0());
							}
						}
						
						trace('Adding entermethod calls took '+(getTimer() - start)+'ms');
						
						start = getTimer();
						
						l = wrapper.findInstruction(new InstructionTemplate(Instruction_returnvoid, {}));
						
						for(var iter6:* in l)
						{
							abcTag.abcFile.methodBodies[l[iter6].methodBody].maxStack += 1;
						}
						
						wrapper.replaceInstruction2(l, function(z:InstructionLocation, a:Vector.<IInstruction>):Vector.<IInstruction>
						{
							var mb:MethodBodyInfoToken = abcTag.abcFile.methodBodies[z.methodBody];
							if(mb.initScopeDepth >= minScopeDepth)
							{
								a.unshift(new Instruction_callpropvoid(exitFunctionIndex, 1));
								
								var methodId:int =  wrapper.addString(currentTagId+'.'+z.methodBody);
								var methodName:String = nameFromMethodId[mb.method];
								if(methodName)
								{
									methodId =  wrapper.addString(methodName);
								}
								a.unshift(new Instruction_pushstring(methodId));
								
								a.unshift(new Instruction_getlex(loggerClassIndex));
							}
							wrapper.redirectReferences(z.methodBody, a[a.length - 1], a[0]);
							return a;
						});
						
						l = wrapper.findInstruction(new InstructionTemplate(Instruction_returnvalue, {}));
						
						for(iter6 in l)
						{
							abcTag.abcFile.methodBodies[l[iter6].methodBody].maxStack += 1;
						}
						
						wrapper.replaceInstruction2(l, function(z:InstructionLocation, a:Vector.<IInstruction>):Vector.<IInstruction>
						{
							var mb:MethodBodyInfoToken = abcTag.abcFile.methodBodies[z.methodBody];
							if(mb.initScopeDepth >= minScopeDepth)
							{
								a.unshift(new Instruction_callpropvoid(exitFunctionIndex, 2));
								a.unshift(new Instruction_swap());
								
								var methodId:int =  wrapper.addString(currentTagId+'.'+z.methodBody);
								var methodName:String = nameFromMethodId[mb.method];
								if(methodName)
								{
									methodId =  wrapper.addString(methodName);
								}
								a.unshift(new Instruction_pushstring(methodId));
								
								a.unshift(new Instruction_swap());
								a.unshift(new Instruction_getlex(loggerClassIndex));
								a.unshift(new Instruction_dup());
							}
							wrapper.redirectReferences(z.methodBody, a[a.length - 1], a[0]);
							return a;
						});
						
						trace('Adding exitmethod calls took '+(getTimer() - start)+'ms');
					}
				}
				currentTagId++;
			}
			else
			{
				finish();
			}
		}
	}
}