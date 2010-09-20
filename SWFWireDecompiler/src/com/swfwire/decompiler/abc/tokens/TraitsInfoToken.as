package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.tokens.traits.*;
	
	public class TraitsInfoToken implements IToken
	{
		public static const ATTRIBUTE_FINAL:uint	 = 1 << 0;
		public static const ATTRIBUTE_OVERRIDE:uint	 = 1 << 1;
		public static const ATTRIBUTE_METADATA:uint	 = 1 << 2;
		
		public static const KIND_TRAIT_SLOT:uint		 = 0;
		public static const KIND_TRAIT_METHOD:uint		 = 1;
		public static const KIND_TRAIT_GETTER:uint		 = 2;
		public static const KIND_TRAIT_SETTER:uint		 = 3;
		public static const KIND_TRAIT_CLASS:uint		 = 4;
		public static const KIND_TRAIT_FUNCTION:uint	 = 5;
		public static const KIND_TRAIT_CONST:uint		 = 6;
		
		private static const filter4:uint = (1 << 4) - 1;
		
		public var name:uint;
		public var kind:uint;
		public var attributes:uint;
		public var data:ITrait;
		public var metadataCount:uint;
		public var metadata:Vector.<uint>;

		public function TraitsInfoToken(name:uint = 0, kind:uint = 0, attributes:uint = 0, data:ITrait = null, metadataCount:uint = 0, metadata:Vector.<uint> = null)
		{
			if(metadata == null)
			{
				metadata = new Vector.<uint>();
			}

			this.name = name;
			this.kind = kind;
			this.attributes = attributes;
			this.data = data;
			this.metadataCount = metadataCount;
			this.metadata = metadata;
		}
		
		public function read(abc:ABCByteArray):void
		{
			var iter:uint;
			
			name = abc.readU30();
			var kindAndAttributes:uint = abc.readU8();
			
			attributes = kindAndAttributes >> 4;
			kind = kindAndAttributes & filter4;
			
			switch(kind)
			{
				case KIND_TRAIT_SLOT:
				case KIND_TRAIT_CONST:
					data = new TraitSlotToken();
					break;
				case KIND_TRAIT_METHOD:
				case KIND_TRAIT_GETTER:
				case KIND_TRAIT_SETTER:
					data = new TraitMethodToken();
					break;
				case KIND_TRAIT_CLASS:
					data = new TraitClassToken();
					break;
				case KIND_TRAIT_FUNCTION:
					data = new TraitFunctionToken();
					break;
				default:
					throw new Error('Invalid trait kind: '+kind);
					break;
			}
			data.read(abc);
			
			if(attributes & ATTRIBUTE_METADATA)
			{
				metadataCount = abc.readU30();
				metadata = new Vector.<uint>(metadataCount);
				for(iter = 0; iter < metadataCount; iter++)
				{
					metadata[iter] = abc.readU30();
				}
			}
		}
		public function write(abc:ABCByteArray):void
		{
			var iter:uint;
			
			abc.writeU30(name);
			
			var kindAndAttributes:uint = 0;
			kindAndAttributes = (attributes << 4) | (kind & filter4);
			
			abc.writeU8(kindAndAttributes);
			
			data.write(abc);
			
			if(attributes & ATTRIBUTE_METADATA)
			{
				abc.writeU30(metadata.length);
				for(iter = 0; iter < metadata.length; iter++)
				{
					abc.writeU30(metadata[iter]);
				}
			}
		}
	}
}