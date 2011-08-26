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
	}
}