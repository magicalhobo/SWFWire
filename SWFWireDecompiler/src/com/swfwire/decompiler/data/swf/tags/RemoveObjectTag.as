package com.swfwire.decompiler.data.swf.tags
{
	public class RemoveObjectTag extends SWFTag
	{
		public var characterId:uint;
		public var depth:uint;
		
		public function RemoveObjectTag(characterId:uint = 0, depth:uint = 0)
		{
			this.characterId = characterId;
			this.depth = depth;
		}
	}
}