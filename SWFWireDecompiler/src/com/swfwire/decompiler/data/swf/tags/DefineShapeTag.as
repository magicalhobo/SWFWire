package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.records.RectangleRecord;
	import com.swfwire.decompiler.data.swf.records.ShapeWithStyleRecord;
	
	public class DefineShapeTag extends SWFTag
	{
		public var shapeId:uint;
		public var shapeBounds:RectangleRecord;
		public var shapes:ShapeWithStyleRecord;
	}
}