package com.swfwire.decompiler.abc.tokens.traits
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class TraitSlotToken implements ITrait
	{
		public var slotId:uint;
		public var typeName:uint;
		public var vIndex:uint;
		public var vKind:uint;

		public function TraitSlotToken(slotId:uint = 0, typeName:uint = 0, vIndex:uint = 0, vKind:uint = 0)
		{
			this.slotId = slotId;
			this.typeName = typeName;
			this.vIndex = vIndex;
			this.vKind = vKind;
		}
		
		public function read(abc:ABCByteArray):void
		{
			slotId = abc.readU30();
			typeName = abc.readU30();
			vIndex = abc.readU30();
			if(vIndex)
			{
				vKind = abc.readU8();
			}
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(slotId);
			abc.writeU30(typeName);
			abc.writeU30(vIndex);
			if(vIndex)
			{
				abc.writeU8(vKind);
			}
		}
	}
}