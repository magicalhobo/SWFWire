package com.swfwire.decompiler.abc.tokens.traits
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class TraitClassToken implements ITrait
	{
		public var slotId:uint;
		public var classId:uint;

		public function TraitClassToken(slotId:uint = 0, classId:uint = 0)
		{
			this.slotId = slotId;
			this.classId = classId;
		}
		
		public function read(abc:ABCByteArray):void
		{
			slotId = abc.readU30();
			classId = abc.readU30();
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(slotId);
			abc.writeU30(classId);
		}
	}
}