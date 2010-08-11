package com.swfwire.debugger.utils
{
	import com.swfwire.decompiler.abc.ABCFile;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.abc.instructions.IInstruction;
	import com.swfwire.decompiler.abc.instructions.Instruction_lookupswitch;
	import com.swfwire.decompiler.abc.tokens.MethodBodyInfoToken;
	import com.swfwire.decompiler.abc.tokens.MultinameToken;
	import com.swfwire.decompiler.abc.tokens.NamespaceToken;
	import com.swfwire.decompiler.abc.tokens.StringToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameQNameToken;
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
			for(var iter:uint = 0; iter < abcFile.methodBodyCount; iter++)
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
		
		public function addQName(namespace:int, name:int):int
		{
			var multinames:Vector.<MultinameToken> = abcFile.cpool.multinames;
			
			var index:int = multinames.length;
			multinames.push(new MultinameToken(MultinameToken.KIND_QName, new MultinameQNameToken(namespace, name)));
			
			return index;
		}
	}
}