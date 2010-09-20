package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf10.tags.*;
	import com.swfwire.decompiler.SWF9Reader;
	import com.swfwire.utils.ObjectUtil;

	public class SWF10Reader extends SWF9Reader
	{
		private static var FILE_VERSION:uint = 10;
		
		public function SWF10Reader()
		{
			version = FILE_VERSION;
		}
		
		override protected function readTag(context:SWFReaderContext, header:TagHeaderRecord):SWFTag
		{
			var tag:SWFTag;
			if(context.fileVersion < FILE_VERSION)
			{
				tag = super.readTag(context, header);
			}
			else
			{
				switch(header.type)
				{
					/*
					case 83: tag = readDefineShape4Tag(context, header);
					case 90: tag = readDefineBitsJPEG4Tag(context, header);
					case 91: tag = readDefineFont4Tag(context, header);
					*/
					case 41:
						tag = readProductInfoTag(context, header);
						break;
					default:
						tag = super.readTag(context, header);
						break;
				}
			}
			return tag;
		}
		
		protected function readProductInfoTag(context:SWFReaderContext, header:TagHeaderRecord):ProductInfoTag
		{
			var tag:ProductInfoTag = new ProductInfoTag();
			tag.product = context.bytes.readUI32();
			tag.edition = context.bytes.readUI32();
			tag.majorVersion = context.bytes.readUI8();
			tag.minorVersion = context.bytes.readUI8();
			tag.buildLow = context.bytes.readUI32();
			tag.buildHigh = context.bytes.readUI32();
			tag.compileDateLow = context.bytes.readUI32();
			tag.compileDateHigh = context.bytes.readUI32();
			return tag;
		}
	}
}