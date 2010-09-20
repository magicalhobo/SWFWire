package com.swfwire.decompiler.data.swf8.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.RectangleRecord;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	public class DefineScalingGridTag extends SWFTag
	{
		public var characterId:uint;
		public var splitter:RectangleRecord;

		public function DefineScalingGridTag(characterId:uint = 0, splitter:RectangleRecord = null)
		{
			if(splitter == null)
			{
				splitter = new RectangleRecord();
			}

			this.characterId = characterId;
			this.splitter = splitter;
		}
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			characterId = swfcontext.bytes.readUI16();
			splitter.read(swfBytes);
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			swfBytes.writeUI16(characterId);
			splitter.write(swfBytes);
		}
		*/
	}
}