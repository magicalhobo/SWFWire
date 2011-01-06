package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf10.tags.*;

	public class SWF10Writer extends SWF9Writer
	{
		private static var FILE_VERSION:uint = 10;
		
		public function SWF10Writer()
		{
			version = FILE_VERSION;
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case ProductInfoTag:
					writeProductInfoTag(context, ProductInfoTag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeProductInfoTag(context:SWFWriterContext, tag:ProductInfoTag):void
		{
			context.bytes.writeUI32(tag.product);
			context.bytes.writeUI32(tag.edition);
			context.bytes.writeUI8(tag.majorVersion);
			context.bytes.writeUI8(tag.minorVersion);
			context.bytes.writeUI32(tag.buildLow);
			context.bytes.writeUI32(tag.buildHigh);
			context.bytes.writeUI32(tag.compileDateLow);
			context.bytes.writeUI32(tag.compileDateHigh);
		}
	}
}