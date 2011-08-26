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
	}
}