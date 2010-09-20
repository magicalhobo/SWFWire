package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.SWF3Reader;
	import com.swfwire.decompiler.data.swf4.tags.*;
	import com.swfwire.utils.ObjectUtil;
	
	public class SWF4Reader extends SWF3Reader
	{
		private static var FILE_VERSION:uint = 4;
		
		public function SWF4Reader()
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
					case 37:
						tag = readDefineEditTextTag(context, header);
						break;
					default:
						tag = super.readTag(context, header);
						break;
				}
			}
			return tag;
		}
		
		protected function readDefineEditTextTag(context:SWFReaderContext, header:TagHeaderRecord):DefineEditTextTag
		{
			var tag:DefineEditTextTag = new DefineEditTextTag();

			tag.characterId = context.bytes.readUI16();
			tag.bounds = readRectangleRecord(context);
			
			//The spec says a bunch of UB[1]s but it looks more like 2 UI8s
			context.bytes.alignBytes();
			
			tag.hasText = context.bytes.readFlag();
			tag.wordWrap = context.bytes.readFlag();
			tag.multiline = context.bytes.readFlag();
			tag.password = context.bytes.readFlag();
			tag.readOnly = context.bytes.readFlag();
			tag.hasTextColor = context.bytes.readFlag();
			tag.hasMaxLength = context.bytes.readFlag();
			tag.hasFont = context.bytes.readFlag();
			tag.hasFontClass = context.bytes.readFlag();
			tag.autoSize = context.bytes.readFlag();
			tag.hasLayout = context.bytes.readFlag();
			tag.noSelect = context.bytes.readFlag();
			tag.border = context.bytes.readFlag();
			tag.wasStatic = context.bytes.readFlag();
			tag.html = context.bytes.readFlag();
			tag.useOutlines = context.bytes.readFlag();
			if(tag.hasFont)
			{
				tag.fontId = context.bytes.readUI16();
			}
			if(tag.hasFontClass)
			{
				tag.fontClass = context.bytes.readString();
			}
			if(tag.hasFont)
			{
				tag.fontHeight = context.bytes.readUI16();
			}
			if(tag.hasTextColor)
			{
				tag.textColor = readRGBARecord(context);
			}
			if(tag.hasMaxLength)
			{
				tag.maxLength = context.bytes.readUI16();
			}
			if(tag.hasLayout)
			{
				tag.align = context.bytes.readUI8();
				tag.leftMargin = context.bytes.readUI16();
				tag.rightMargin = context.bytes.readUI16();
				tag.indent = context.bytes.readUI16();
				tag.leading = context.bytes.readSI16();
			}
			tag.variableName = context.bytes.readString();
			if(tag.hasText)
			{
				tag.initialText = context.bytes.readString();
			}
			
			return tag;
		}
	}
}