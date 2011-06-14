package com.swfwire.debugger
{
	import com.swfwire.debugger.utils.ABCWrapper;
	import com.swfwire.debugger.utils.InstructionLocation;
	import com.swfwire.debugger.utils.InstructionTemplate;
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

	[Event(type="com.swfwire.debugger.events.AsyncSWFModifierEvent", name="run")]
	[Event(type="com.swfwire.debugger.events.AsyncSWFModifierEvent", name="complete")]
	
	public class DebuggerAsyncModifier extends AsyncSWFModifier
	{
		private var phase:uint;
		private var iTag:uint;
		private var swf:SWF;
		private var metadata:Vector.<ABCReaderMetadata>;
		private var deferConstructor:Boolean;
		public var foundMainClass:Boolean;
		public var mainClassPackage:String;
		public var mainClassName:String;
		public var backgroundColor:uint;
		
		public function DebuggerAsyncModifier(swf:SWF, metadata:Vector.<ABCReaderMetadata>, deferConstructor:Boolean = true, timeLimit:uint = 100)
		{
			super(timeLimit);
			
			this.swf = swf;
			this.metadata = metadata;
			this.deferConstructor = deferConstructor;
		}
		
		override public function start():Boolean
		{
			if(super.start())
			{
				phase = 1;
				iTag = 0;
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
			
			return iTag/swf.tags.length;
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
			/*
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
			*/
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
			if(iTag < swf.tags.length)
			{
				var abcTag:DoABCTag = swf.tags[iTag] as DoABCTag;
				if(abcTag)
				{
					var wrapper:ABCWrapper = new ABCWrapper(abcTag.abcFile, metadata[iTag]);
					
					var injectedNamespace:uint = wrapper.addNamespaceFromString('com.swfwire.debugger.injected');
					
					var cpool:ConstantPoolToken = abcTag.abcFile.cpool;
					
					function convert(ns:String, name:String):void
					{
						var index:int = wrapper.getMultinameIndex(ns, name);
						if(index >= 0)
						{
							var qName:MultinameQNameToken = cpool.multinames[index].data as MultinameQNameToken;
							qName.ns = injectedNamespace;
						}
					}
					
					var securityIndex:int = wrapper.getMultinameIndex('flash.system', 'Security');
					if(securityIndex >= 0)
					{
						var securityQName:MultinameQNameToken = cpool.multinames[securityIndex].data as MultinameQNameToken;
						securityQName.ns = injectedNamespace;
					}
					var externalInterfaceIndex:int = wrapper.getMultinameIndex('flash.external', 'ExternalInterface');
					if(externalInterfaceIndex >= 0)
					{
						var externalInterfaceQName:MultinameQNameToken = cpool.multinames[externalInterfaceIndex].data as MultinameQNameToken;
						externalInterfaceQName.ns = injectedNamespace;
					}
					
					var navigateToURLIndex:int = wrapper.getMultinameIndex('flash.net', 'navigateToURL');
					if(navigateToURLIndex >= 0)
					{
						var navigateToURLQName:MultinameQNameToken = cpool.multinames[navigateToURLIndex].data as MultinameQNameToken;
						navigateToURLQName.ns = injectedNamespace;
					}
					
					var urlLoaderIndex:int = wrapper.getMultinameIndex('flash.net', 'URLLoader');
					if(urlLoaderIndex >= 0)
					{
						var urlLoaderQName:MultinameQNameToken = cpool.multinames[urlLoaderIndex].data as MultinameQNameToken;
						urlLoaderQName.ns = injectedNamespace;
					}
					
					var urlStreamIndex:int = wrapper.getMultinameIndex('flash.net', 'URLStream');
					if(urlStreamIndex >= 0)
					{
						var urlStreamQName:MultinameQNameToken = cpool.multinames[urlStreamIndex].data as MultinameQNameToken;
						urlStreamQName.ns = injectedNamespace;
					}
					
					var netConnectionIndex:int = wrapper.getMultinameIndex('flash.net', 'NetConnection');
					if(netConnectionIndex >= 0)
					{
						var netConnectionQName:MultinameQNameToken = cpool.multinames[netConnectionIndex].data as MultinameQNameToken;
						netConnectionQName.ns = injectedNamespace;
					}
					
					//convert('flash.net', 'Socket');
					//convert('flash.net', 'ServerSocket');
					//convert('flash.events', 'ServerSocketConnectEvent');
					
					var loaderIndex:int = wrapper.getMultinameIndex('flash.display', 'Loader');
					if(loaderIndex >= 0)
					{
						var loaderQName:MultinameQNameToken = cpool.multinames[loaderIndex].data as MultinameQNameToken;
						loaderQName.ns = injectedNamespace;
					}
					
					/*
					update(wrapper, abcTag, 'flash.display', 'Loader', injectedNamespace, -1);
					update(wrapper, abcTag, 'flash.display', 'Sprite', injectedNamespace, wrapper.addString('SWFWire_Sprite'));
					update(wrapper, abcTag, 'flash.display', 'MovieClip', injectedNamespace, wrapper.addString('SWFWire_MovieClip'));
					
					//update(wrapper, abcTag, '', 'loaderInfo', -1, wrapper.addString('swfWire_loaderInfo'));
					update(wrapper, abcTag, 'flash.display', 'LoaderInfo', injectedNamespace, wrapper.addString('SWFWire_LoaderInfo'));

					//update(wrapper, abcTag, '', 'stage', -1, wrapper.addString('swfWire_stage'));
					update(wrapper, abcTag, 'flash.display', 'Stage', injectedNamespace, wrapper.addString('SWFWire_Stage'));

					updatePublic(wrapper, abcTag, 'loaderInfo', wrapper.addString('swfWire_loaderInfo'));
					updatePublic(wrapper, abcTag, 'stage', wrapper.addString('swfWire_stage'));
					*/
					var mainIndex:int = wrapper.getMultinameIndex(mainClassPackage, mainClassName);
					var mainInst:InstanceToken = null;
					
					if(mainIndex >= 0)
					{
						for(var i:uint = 0; i < abcTag.abcFile.instances.length; i++)
						{
							var inst:InstanceToken = abcTag.abcFile.instances[i];
							if(inst.name == mainIndex)
							{
								mainInst = inst;
								break;
							}
						}
					}
					
					if(false && mainInst && deferConstructor)
					{
						var mainMB:MethodBodyInfoToken = wrapper.findMethodBody(mainInst.iinit);
						
						//Create method deferredConstructor on main class
						var defcmni:int = wrapper.addQName(
							wrapper.addNamespaceFromString(''), 
							wrapper.addString('deferredConstructor'));
						
						var mainTrait:TraitsInfoToken = new TraitsInfoToken(defcmni,
							TraitsInfoToken.KIND_TRAIT_METHOD,
							0,
							new TraitMethodToken(0, mainInst.iinit));
						
						mainInst.traits.push(mainTrait);
						
						var defcmi:uint = abcTag.abcFile.methods.push(new MethodInfoToken()) - 1;
						
						var emptyMethod:MethodBodyInfoToken = new MethodBodyInfoToken(
							defcmi, 1, 1, mainMB.initScopeDepth, mainMB.initScopeDepth + 1);
						emptyMethod.instructions = wrapper.getEmptyConstructorInstructions();
						
						abcTag.abcFile.methodBodies.push(emptyMethod);
						
						mainInst.iinit = defcmi;
					}
					if(true && mainInst)
					{
						var mainMB:MethodBodyInfoToken = wrapper.findMethodBody(mainInst.iinit);
						
						var globalClassIndex:int = wrapper.addQName(
							wrapper.addNamespaceFromString('com.swfwire.debugger.injected'), 
							wrapper.addString('Globals'));
						
						var stageIndex:int = wrapper.addQName(
							wrapper.addNamespaceFromString(''), 
							wrapper.addString('stage'));
						
						var addChildIndex:int = wrapper.addQName(
							wrapper.addNamespaceFromString(''), 
							wrapper.addString('addChild'));
						
						mainMB.instructions.splice(0, 0,
							new Instruction_getlex(globalClassIndex),
							new Instruction_getproperty(stageIndex),
							new Instruction_getlocal0(),
							new Instruction_callpropvoid(addChildIndex, 1));
					}
					
					function getUniqueID(multinameIndex:int):String
					{
						var qname:MultinameQNameToken = cpool.multinames[multinameIndex].data as MultinameQNameToken;
						var ns:String = cpool.strings[cpool.namespaces[qname.ns].name].utf8;
						var name:String = cpool.strings[qname.name].utf8;
						
						var uniqueID:String = ns ? ns+'::'+name : name;
						
						return uniqueID;
					}
					
					//createClass();
					
					for(var iterInstance:int = 0; iterInstance < abcTag.abcFile.instances.length; iterInstance++)
					{
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
						
						var uniqueID:String = getUniqueID(thisInstance.name);
						
						enumerateMethodsInstructions.push(new Instruction_newobject(enumerateMethodsInstructions.length * 1 / 3));
						enumerateMethodsInstructions.push(new Instruction_returnvalue());
						createMethod(abcTag, wrapper, thisInstance, 'swfWire_enumerateMethods_'+uniqueID, enumerateMethodsInstructions, enumerateMethodsInstructions.length);

						enumeratePropertiesInstructions.push(new Instruction_newobject(enumeratePropertiesInstructions.length * 1 / 3));
						enumeratePropertiesInstructions.push(new Instruction_returnvalue());
						createMethod(abcTag, wrapper, thisInstance, 'swfWire_enumerateProperties_'+uniqueID, enumeratePropertiesInstructions, enumeratePropertiesInstructions.length);

						var wildcardNSSet:NamespaceSetToken = new NamespaceSetToken();
						for(var iterNS:int = 1; iterNS < cpool.namespaces.length; iterNS++)
						{
							wildcardNSSet.namespaces.push(iterNS);
						}
						wildcardNSSet.count = wildcardNSSet.namespaces.length;
						var wildcardNSSetIndex:int = cpool.nsSets.length;
						cpool.nsSets.push(wildcardNSSet);
						
						var wildcardMultiname:MultinameToken = new MultinameToken(MultinameToken.KIND_MultinameL, new MultinameMultinameLToken(wildcardNSSetIndex));
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
						
						/*
						var getPropertyInstructions:Vector.<IInstruction> = new Vector.<IInstruction>();
						getPropertyInstructions.push(new Instruction_newobject(getPropertyInstructions.length * 1 / 3));
						getPropertyInstructions.push(new Instruction_returnvalue());
						createMethodWithArguments(abcTag,
							wrapper,
							thisInstance, 
							'swfWire_getProperty',
							getPropertyInstructions,
							getPropertyInstructions.length,
							Vector.<String>([':String']));
						*/
					}
					
					//Debug.log('test', 'after', mainInst.traits);
					
					//mainInst.iinit--;
					
					if(true)
					{
						var cp:ConstantPoolToken = cpool;
						var l:*;
						const minScopeDepth:uint = 3;
						
						var loggerClassIndex:int = wrapper.addQName(
							wrapper.addNamespaceFromString('com.swfwire.debugger.injected'), 
							wrapper.addString('Logger'));
						
						var emptyNS:int = wrapper.addNamespaceFromString('');
						
						var enterFunctionIndex:int = wrapper.addQName(emptyNS, wrapper.addString('enterFunction'));
						var exitFunctionIndex:int = wrapper.addQName(emptyNS, wrapper.addString('exitFunction'));
						var newObjectIndex:int = wrapper.addQName(emptyNS, wrapper.addString('newObject'));
						
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
						
						var nameFromMethodId:Object = {};
						
						function qnameToString(instance:String, index:uint):String
						{
							var result:String = '<Not a QName>';
							var mq:MultinameQNameToken = cp.multinames[index].data as MultinameQNameToken;
							if(mq)
							{
								var ns:String = cp.strings[cp.namespaces[mq.ns].name].utf8;
								if(ns == instance)
								{
									ns = '';
								}
								if(ns != '')
								{
									ns = ns + ':';
								}
								result = ns + cp.strings[mq.name].utf8;
							}
							return result;
						}
						
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
						
						l = new Vector.<InstructionLocation>;
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_construct, {})));
						//l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_constructsuper, {})));
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_constructprop, {})));
						
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_newclass, {})));
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_newobject, {})));
						l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_newarray, {})));
						//l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_newactivation, {})));
						
						//l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_dxns, {})));
						//l = l.concat(wrapper.findInstruction(new InstructionTemplate(Instruction_dxnslate, {})));
						
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
								
								
								j9.unshift(new Instruction_callpropvoid(enterFunctionIndex, 3));
								
								if(paramCount > 0)
								{
									abcTag.abcFile.methodBodies[i9].maxStack += paramCount * 2 + 3;
									j9.unshift(new Instruction_newobject(paramCount));
									
									for(var i10:int = paramCount - 1; i10 >= 0; i10--)
									{
										var paramName:ParamInfoToken = abcTag.abcFile.methods[mb.method].paramNames[i10];
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
								
								var methodId:int = wrapper.addString(iTag+'.'+String(i9));
								var methodName:String = nameFromMethodId[mb.method];
								if(methodName)
								{
									methodId =  wrapper.addString(methodName);
								}
								j9.unshift(new Instruction_pushstring(methodId));
								j9.unshift(new Instruction_getlex(loggerClassIndex));
							}
						}
						
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
								
								var methodId:int =  wrapper.addString(iTag+'.'+z.methodBody);
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
								
								var methodId:int =  wrapper.addString(iTag+'.'+z.methodBody);
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
					}
				}
				iTag++;
			}
			else
			{
				finish();
			}
		}
	}
}