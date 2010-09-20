package com.swfwire.decompiler.data.swf4.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.RGBARecord;
	import com.swfwire.decompiler.data.swf.records.RectangleRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class DefineEditTextTag extends SWFTag
	{
		public var characterId:uint;
		public var bounds:RectangleRecord;
		public var hasText:Boolean;
		public var wordWrap:Boolean;
		public var multiline:Boolean;
		public var password:Boolean;
		public var readOnly:Boolean;
		public var hasTextColor:Boolean;
		public var hasMaxLength:Boolean;
		public var hasFont:Boolean;
		public var hasFontClass:Boolean;
		public var autoSize:Boolean;
		public var hasLayout:Boolean;
		public var noSelect:Boolean;
		public var border:Boolean;
		public var wasStatic:Boolean;
		public var html:Boolean;
		public var useOutlines:Boolean;
		public var fontId:uint;
		public var fontClass:String;
		public var fontHeight:uint;
		public var textColor:RGBARecord;
		public var maxLength:uint;
		public var align:uint;
		public var leftMargin:uint;
		public var rightMargin:uint;
		public var indent:uint;
		public var leading:int;
		public var variableName:String;
		public var initialText:String;
	}
}