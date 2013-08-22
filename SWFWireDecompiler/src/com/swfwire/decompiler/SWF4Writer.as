package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf4.tags.DefineEditTextTag;

	public class SWF4Writer extends SWF3Writer
	{
		public static const TAG_IDS:Object = {
			37: DefineEditTextTag
		};
		
		private static var FILE_VERSION:uint = 4;
		
		public function SWF4Writer()
		{
			version = FILE_VERSION;
			registerTags(TAG_IDS);
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				case DefineEditTextTag:
					writeDefineEditTextTag(context, DefineEditTextTag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeDefineEditTextTag(context:SWFWriterContext, tag:DefineEditTextTag):void
		{
			context.bytes.writeUI16(tag.characterId);
			writeRectangleRecord(context, tag.bounds);
			
			//The spec says a bunch of UB[1]s but it looks more like 2 UI8s
			context.bytes.alignBytes();
			
			var hasText:Boolean = tag.initialText != null;
			var hasTextColor:Boolean = tag.textColor != null;
			var hasMaxLength:Boolean = tag.maxLength > 0;
			var hasFont:Boolean = tag.fontId > 0;
			var hasFontClass:Boolean = tag.fontClass != null;
			
			if(hasFont && hasFontClass)
			{
				context.result.warnings.push('HasFont cannot be true if HasFontClass is true');
			}
			
			context.bytes.writeFlag(hasText);
			context.bytes.writeFlag(tag.wordWrap);
			context.bytes.writeFlag(tag.multiline);
			context.bytes.writeFlag(tag.password);
			context.bytes.writeFlag(tag.readOnly);
			context.bytes.writeFlag(hasTextColor);
			context.bytes.writeFlag(hasMaxLength);
			context.bytes.writeFlag(hasFont);
			context.bytes.writeFlag(hasFontClass);
			context.bytes.writeFlag(tag.autoSize);
			context.bytes.writeFlag(tag.hasLayout);
			context.bytes.writeFlag(tag.noSelect);
			context.bytes.writeFlag(tag.border);
			context.bytes.writeFlag(tag.wasStatic);
			context.bytes.writeFlag(tag.html);
			context.bytes.writeFlag(tag.useOutlines);
			if(hasFont)
			{
				context.bytes.writeUI16(tag.fontId);
			}
			if(hasFontClass)
			{
				context.bytes.writeString(tag.fontClass);
			}
			if(hasFont)
			{
				context.bytes.writeUI16(tag.fontHeight);
			}
			if(hasTextColor)
			{
				writeRGBARecord(context, tag.textColor);
			}
			if(hasMaxLength)
			{
				context.bytes.writeUI16(tag.maxLength);
			}
			if(tag.hasLayout)
			{
				context.bytes.writeUI8(tag.align);
				context.bytes.writeUI16(tag.leftMargin);
				context.bytes.writeUI16(tag.rightMargin);
				context.bytes.writeUI16(tag.indent);
				context.bytes.writeSI16(tag.leading);
			}
			context.bytes.writeString(tag.variableName);
			if(hasText)
			{
				context.bytes.writeString(tag.initialText);
			}
		}
	}
}