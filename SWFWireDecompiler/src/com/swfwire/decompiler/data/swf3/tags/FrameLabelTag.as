package com.swfwire.decompiler.data.swf3.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.utils.ByteArrayUtil;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	public class FrameLabelTag extends SWFTag
	{
		public var name:String;

		public function FrameLabelTag(name:String = '')
		{
			this.name = name;
		}
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			name = swfcontext.bytes.readString();
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			swfBytes.writeString(name);
		}
		*/
	}
}