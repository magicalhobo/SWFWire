package com.swfwire.decompiler.data.swf8.tags
{
	import com.swfwire.decompiler.data.swf.records.RectangleRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf8.records.ShapeWithStyleRecord4;
	
	public class DefineShape4Tag extends SWFTag
	{
		public var shapeId:uint;
		public var shapeBounds:RectangleRecord;
		public var edgeBounds:RectangleRecord;
		public var reserved:uint;
		public var usesFillWindingRule:Boolean;
		public var usesNonScalingStrokes:Boolean;
		public var usesScalingStrokes:Boolean;
		public var shapes:ShapeWithStyleRecord4;
	}
}