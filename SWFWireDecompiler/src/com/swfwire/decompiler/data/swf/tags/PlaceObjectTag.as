package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.records.CXFormRecord;
	import com.swfwire.decompiler.data.swf.records.MatrixRecord;

	public class PlaceObjectTag extends SWFTag
	{
		public var characterId:uint;
		public var depth:uint;
		public var matrix:MatrixRecord;
		public var colorTransform:CXFormRecord;
	}
}