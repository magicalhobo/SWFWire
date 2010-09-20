package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.data.swf.records.*;

	public class ButtonRecord2
	{
		public var reserved:uint;
		public var hasBlendMode:Boolean;
		public var hasFilterList:Boolean;
		public var stateHitTest:Boolean;
		public var stateDown:Boolean;
		public var stateOver:Boolean;
		public var stateUp:Boolean;
		public var characterId:uint;
		public var placeDepth:uint;
		public var placeMatrix:MatrixRecord;
		public var colorTransform:CXFormWithAlphaRecord;
		public var filterList:FilterListRecord;
		public var blendMode:uint;
	}
}