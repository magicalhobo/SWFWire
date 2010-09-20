package com.swfwire.decompiler
{
	import com.swfwire.decompiler.abc.ABCWriteResult;
	import com.swfwire.decompiler.abc.ABCWriter;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf9.tags.DoABCTag;
	
	import flash.utils.ByteArray;

	public class SWF9Writer extends SWFWriter
	{
		public function SWF9Writer()
		{
			
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case DoABCTag:
					writeDoABCTag(context, DoABCTag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeDoABCTag(context:SWFWriterContext, tag:DoABCTag):void
		{
			context.bytes.writeUI32(tag.flags);
			context.bytes.writeString(tag.name);
			
			var abcWriter:ABCWriter = new ABCWriter();
			var writeResult:ABCWriteResult = abcWriter.write(tag.abcFile);
			
			context.bytes.writeBytes(writeResult.bytes);
		}
	}
}