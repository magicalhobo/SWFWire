package com.swfwire.decompiler.data.swf3.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.CXFormWithAlphaRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.records.MatrixRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class PlaceObject2Tag extends SWFTag
	{
		public var move:Boolean;
		public var depth:uint;
		public var characterId:Object;
		public var matrix:MatrixRecord;
		public var colorTransform:CXFormWithAlphaRecord;
		public var ratio:Object;
		public var name:String;
		public var clipDepth:Object;
		public var clipActions:ClipActionsRecord;
	}
}