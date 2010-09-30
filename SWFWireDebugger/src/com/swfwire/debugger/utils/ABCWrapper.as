package com.swfwire.debugger.utils
{
	import com.swfwire.decompiler.abc.ABCFile;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.ConstantPoolToken;
	import com.swfwire.decompiler.abc.tokens.InstanceToken;
	import com.swfwire.decompiler.abc.tokens.MethodBodyInfoToken;
	import com.swfwire.decompiler.abc.tokens.MethodInfoToken;
	import com.swfwire.decompiler.abc.tokens.MultinameToken;
	import com.swfwire.decompiler.abc.tokens.NamespaceToken;
	import com.swfwire.decompiler.abc.tokens.StringToken;
	import com.swfwire.decompiler.abc.tokens.TraitsInfoToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameQNameToken;
	import com.swfwire.decompiler.abc.tokens.traits.TraitMethodToken;
	import com.swfwire.utils.Debug;
	
	import flash.utils.Dictionary;

	public class ABCWrapper
	{
		private var abcFile:ABCFile;
		private var metadata:ABCReaderMetadata;
		
		private var stringLookup:Object;
		private var qnameLookup:Object;
		private var pointers:Dictionary;
		
		public function ABCWrapper(abcFile:ABCFile, metadata:ABCReaderMetadata)
		{
			this.abcFile = abcFile;
			this.metadata = metadata;
			
			this.pointers = new Dictionary(true);
			
			updateCache();
			registerPointers();
		}
		
		protected function updateCache():void
		{
			var iter:String;
			var key:String;
			
			stringLookup = {};
			qnameLookup = {};
			
			var strings:Vector.<StringToken> = abcFile.cpool.strings;
			var namespaces:Vector.<NamespaceToken> = abcFile.cpool.namespaces;
			var multinames:Vector.<MultinameToken> = abcFile.cpool.multinames;
			
			for(iter in strings)
			{
				key = '_'+strings[iter].utf8;
				if(!stringLookup[key])
				{
					stringLookup[key] = [];
				}
				stringLookup[key].push(iter);
			}
			
			for(iter in multinames)
			{
				var qname:MultinameQNameToken = multinames[iter].data as MultinameQNameToken;
				if(qname)
				{
					key = strings[namespaces[qname.ns].name].utf8 + '::' + strings[qname.name].utf8;
					if(!qnameLookup[key])
					{
						qnameLookup[key] = [];
					}
					qnameLookup[key].push(iter);
				}
			}
		}
		
		protected function registerPointers():void
		{
			for(var iter:uint = 0; iter < abcFile.methodBodyCount; iter++)
			{
				var body:MethodBodyInfoToken = abcFile.methodBodies[iter];
				for(var iter2:uint = 0; iter2 < body.instructions.length; iter2++)
				{
					var instruction:IInstruction = body.instructions[iter2];
					if(instruction is Instruction_lookupswitch)
					{
						var lookup:Instruction_lookupswitch = instruction as Instruction_lookupswitch;
						var address:int = metadata.offsetFromId[iter2] - lookup.defaultOffset;
						var instructionId:uint = metadata.idFromOffset[address];
						var referencedInstruction:IInstruction;
						var info:Object = {};
						if(instructionId)
						{
							referencedInstruction = body.instructions[instructionId];
							if(referencedInstruction)
							{
								info['default']= referencedInstruction;
							}
						}
						for(var iter3:uint = 0; iter3 < lookup.caseOffsets.length; iter3++)
						{
							address = metadata.offsetFromId[iter2] - lookup.caseOffsets[iter3];
							instructionId = metadata.idFromOffset[address];
							if(instructionId)
							{
								referencedInstruction = body.instructions[instructionId];
								if(referencedInstruction)
								{
									info['case_'+iter3] = referencedInstruction;
								}
							}
						}
						pointers[instruction] = info;
					}
				}
			}
		}
		
		protected function resetPointers():void
		{
			
		}
		
		public function findMethodBody(methodIndex:int):MethodBodyInfoToken
		{
			var result:MethodBodyInfoToken;
			for(var iter:* in abcFile.methodBodies)
			{
				var mb:MethodBodyInfoToken = abcFile.methodBodies[iter];
				if(mb.method == methodIndex)
				{
					result = mb;
					break;
				}
			}
			return result;
		}
		
		public function getStringIndex(string:String):int
		{
			var index:int = -1;
			var matches:Array = stringLookup['_'+string];
			if(matches)
			{
				for(var iter:uint = 0; iter < matches.length; iter++)
				{
					if(matches[iter] > 0)
					{
						index = matches[iter];
						break;
					}
				}
			}
			return index;
		}
		
		public function addString(string:String):int
		{
			var index:int = getStringIndex(string);
			if(index < 0)
			{
				index = abcFile.cpool.strings.length;
				abcFile.cpool.strings.push(new StringToken(string));
			}
			return index;
		}
		
		public function addNamespaceFromString(string:String):int
		{
			var nameIndex:int = addString(string);
			
			var index:int = abcFile.cpool.namespaces.length;
			abcFile.cpool.namespaces.push(new NamespaceToken(NamespaceToken.KIND_PackageNamespace, nameIndex));
			
			/*
			var index:int = 1;//getNamespaceIndex(kind, stringIndex);
			
			var namespaces:Vector.<NamespaceToken> = abcFile.cpool.namespaces;
			if(index == -1)
			{
				index = namespaces.length;
				namespaces.push(new NamespaceToken(kind, stringIndex));
			}
			*/
			
			return index;
		}
		
		public function setStringAt(index:uint, string:String):void
		{
			abcFile.cpool.strings[index] = new StringToken(string);
		}
		
		public function replaceInstructions(search:Vector.<IInstruction>, replace:Vector.<IInstruction>):void
		{
			for(var iter:uint = 0; iter < abcFile.methodBodyCount; iter++)
			{
				/*
				var body:MethodBodyInfoToken = abcFile.methodBodies[iter];
				for(var instruction:IInstruction in body.instructions)
				{
					if()
					{
						
					}
				}
				*/
			}
		}
		
		public function findInstruction(template:InstructionTemplate):Vector.<InstructionLocation>
		{
			var locations:Vector.<InstructionLocation> = new Vector.<InstructionLocation>();
			for(var iter:uint = 0; iter < abcFile.methodBodies.length; iter++)
			{
				var body:MethodBodyInfoToken = abcFile.methodBodies[iter];
				for(var iter2:uint = 0; iter2 < body.instructions.length; iter2++)
				{
					var instruction:IInstruction = body.instructions[iter2];
					if(instruction is template.type)
					{
						var success:Boolean = true;
						for(var prop:String in template.properties)
						{
							if(instruction[prop] != template.properties[prop])
							{
								success = false;
								break;
							}
						}
						if(success)
						{
							locations.push(new InstructionLocation(iter, iter2));
						}
					}
				}
			}
			return locations;
		}
		
		public function replaceInstruction2(locations:Vector.<InstructionLocation>, callback:Function):void
		{
			/*
			function(a:Vector.<Instruction_findpropstrict>):Vector.<IInstruction>
			{
				var b:Vector.<IInstruction> = new Vector.<IInstruction>();
				b.push(new Instruction_getlex(a[0].index));
				return b;
			});
			*/
			locations.sort(function(a:InstructionLocation, b:InstructionLocation):int
			{
				if(a.methodBody < b.methodBody)
				{
					return -1;
				}
				if(a.methodBody > b.methodBody)
				{
					return 1;
				}
				if(a.id < b.id)
				{
					return -1;
				}
				if(a.id > b.id)
				{
					return 1;
				}
				return 0;
			});
			
			for(var i:int = locations.length - 1; i >= 0; i--)
			{
				var location:InstructionLocation = locations[i];
				var search:Vector.<IInstruction> = abcFile.methodBodies[location.methodBody].instructions.slice(location.id, location.id + 1);
				var result:Vector.<IInstruction> = callback(location, search);
				var args:Array = [location.id, 1];
				for(var iter:* in result)
				{
					args.push(result[iter]);
				}
				abcFile.methodBodies[location.methodBody].instructions.splice.apply(null, args);//(location.id, 1, callback(search));
			}
		}
		
		public function redirectReferences(methodBody:int, from:IInstruction, to:IInstruction):void
		{
			var instructions:Vector.<IInstruction> = abcFile.methodBodies[methodBody].instructions;
			for(var i:int = 0; i < instructions.length; i++)
			{
				var op:IInstruction = instructions[i];
				switch(Object(op).constructor)
				{
					case Instruction_ifeq:
						var op_ifeq:Instruction_ifeq = op as Instruction_ifeq;
						if(op_ifeq.reference == from)
						{
							op_ifeq.reference = to;
						}
						break;
					case Instruction_iffalse:
						var op_iffalse:Instruction_iffalse = op as Instruction_iffalse;
						if(op_iffalse.reference == from)
						{
							op_iffalse.reference = to;
						}
						break;
					case Instruction_ifge:
						var op_ifge:Instruction_ifge = op as Instruction_ifge;
						if(op_ifge.reference == from)
						{
							op_ifge.reference = to;
						}
						break;
					case Instruction_ifgt:
						var op_ifgt:Instruction_ifgt = op as Instruction_ifgt;
						if(op_ifgt.reference == from)
						{
							op_ifgt.reference = to;
						}
						break;
					case Instruction_ifle:
						var op_ifle:Instruction_ifle = op as Instruction_ifle;
						if(op_ifle.reference == from)
						{
							op_ifle.reference = to;
						}
						break;
					case Instruction_iflt:
						var op_iflt:Instruction_iflt = op as Instruction_iflt;
						if(op_iflt.reference == from)
						{
							op_iflt.reference = to;
						}
						break;
					case Instruction_ifnge:
						var op_ifnge:Instruction_ifnge = op as Instruction_ifnge;
						if(op_ifnge.reference == from)
						{
							op_ifnge.reference = to;
						}
						break;
					case Instruction_ifngt:
						var op_ifngt:Instruction_ifngt = op as Instruction_ifngt;
						if(op_ifngt.reference == from)
						{
							op_ifngt.reference = to;
						}
						break;
					case Instruction_ifnle:
						var op_ifnle:Instruction_ifnle = op as Instruction_ifnle;
						if(op_ifnle.reference == from)
						{
							op_ifnle.reference = to;
						}
						break;
					case Instruction_ifnlt:
						var op_ifnlt:Instruction_ifnlt = op as Instruction_ifnlt;
						if(op_ifnlt.reference == from)
						{
							op_ifnlt.reference = to;
						}
						break;
					case Instruction_ifne:
						var op_ifne:Instruction_ifne = op as Instruction_ifne;
						if(op_ifne.reference == from)
						{
							op_ifne.reference = to;
						}
						break;
					case Instruction_ifstricteq:
						var op_ifstricteq:Instruction_ifstricteq = op as Instruction_ifstricteq;
						if(op_ifstricteq.reference == from)
						{
							op_ifstricteq.reference = to;
						}
						break;
					case Instruction_ifstrictne:
						var op_ifstrictne:Instruction_ifstrictne = op as Instruction_ifstrictne;
						if(op_ifstrictne.reference == from)
						{
							op_ifstrictne.reference = to;
						}
						break;
					case Instruction_iftrue:
						var op_iftrue:Instruction_iftrue = op as Instruction_iftrue;
						if(op_iftrue.reference == from)
						{
							op_iftrue.reference = to;
						}
						break;
					case Instruction_jump:
						var op_jump:Instruction_jump = op as Instruction_jump;
						if(op_jump.reference == from)
						{
							op_jump.reference = to;
						}
						break;
					case Instruction_lookupswitch:
						var op_lookup:Instruction_lookupswitch = op as Instruction_lookupswitch;
						if(op_lookup.defaultReference == from)
						{
							op_lookup.defaultReference = to;
						}
						for(var iter:uint = 0; iter < op_lookup.caseReferences.length; iter++)
						{
							if(op_lookup.caseReferences[iter] == from)
							{
								op_lookup.caseReferences[iter] = to;
							}
						}
						break;
				}
			}
		}
		
		public function getMultinameIndex(ns:String, name:String):int
		{
			var index:int = -1;
			var matches:Array = qnameLookup[ns+'::'+name];
			if(matches)
			{
				index = matches[0];
			}
			return index;
		}
		
		public function getEmptyConstructorInstructions():Vector.<IInstruction>
		{
			return Vector.<IInstruction>([
				new Instruction_getlocal0(),
				new Instruction_pushscope(),
				new Instruction_getlocal0(),
				new Instruction_constructsuper(),
				new Instruction_returnvoid()]);
		}
		
		public function getEmptyMethodInstructions():Vector.<IInstruction>
		{
			return Vector.<IInstruction>([
				new Instruction_getlocal0(),
				new Instruction_pushscope(),
				new Instruction_returnvoid()]);
		}
		
		public function getMethodBody(packageName:String, className:String, name:String):MethodBodyInfoToken
		{
			var result:MethodBodyInfoToken;
			var cpool:ConstantPoolToken = abcFile.cpool;
			
			outer:
			for(var i:uint = 0; i < abcFile.instances.length; i++)
			{
				var inst:InstanceToken = abcFile.instances[i];
				var imn:MultinameQNameToken = cpool.multinames[inst.name].data as MultinameQNameToken;
				
				if(cpool.strings[cpool.namespaces[imn.ns].name].utf8 == packageName && cpool.strings[imn.name].utf8 == className)
				{
					for(var i2:uint = 0; i2 < inst.traits.length; i2++)
					{
						var t:TraitsInfoToken = inst.traits[i2];
						if(t.kind == TraitsInfoToken.KIND_TRAIT_METHOD)
						{
							var mn:MultinameQNameToken = cpool.multinames[t.name].data as MultinameQNameToken;
							if(cpool.strings[cpool.namespaces[mn.ns].name].utf8 == '' && cpool.strings[mn.name].utf8 == name)
							{
								var m:TraitMethodToken = t.data as TraitMethodToken;
								result = findMethodBody(m.methodId);
								break outer;
							}
						}
					}
				}
			}
			
			return result;
		}

		public function addQName(namespace:int, name:int):int
		{
			var multinames:Vector.<MultinameToken> = abcFile.cpool.multinames;
			
			var index:int = multinames.length;
			multinames.push(new MultinameToken(MultinameToken.KIND_QName, new MultinameQNameToken(namespace, name)));
			
			return index;
		}
	}
}