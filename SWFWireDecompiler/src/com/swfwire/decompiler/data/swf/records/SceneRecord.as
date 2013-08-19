package com.swfwire.decompiler.data.swf.records
{
	public class SceneRecord
	{
		public var offset:uint;
		public var name:String;
		
		public function SceneRecord(offset:uint = 0, name:String = '')
		{
			this.offset = offset;
			this.name = name;
		}
	}
}