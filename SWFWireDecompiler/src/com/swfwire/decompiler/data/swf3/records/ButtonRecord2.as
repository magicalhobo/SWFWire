package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.data.swf.records.FilterListRecord;
	import com.swfwire.decompiler.data.swf.records.MatrixRecord;
	
	public class ButtonRecord2
	{
		public var reserved:uint;
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
		
		public function ButtonRecord2(reserved:uint = 0, stateHitTest:Boolean = false, stateDown:Boolean = false, stateOver:Boolean = false, stateUp:Boolean = false, characterId:uint = 0, placeDepth:uint = 0, placeMatrix:MatrixRecord = null, colorTransform:CXFormWithAlphaRecord = null, filterList:FilterListRecord = null, blendMode:uint = 0)
		{
			if(placeMatrix == null)
			{
				placeMatrix = new MatrixRecord();
			}
			if(colorTransform == null)
			{
				colorTransform = new CXFormWithAlphaRecord();
			}
			if(filterList == null)
			{
				filterList = new FilterListRecord();
			}
			
			this.reserved = reserved;
			this.stateHitTest = stateHitTest;
			this.stateDown = stateDown;
			this.stateOver = stateOver;
			this.stateUp = stateUp;
			this.characterId = characterId;
			this.placeDepth = placeDepth;
			this.placeMatrix = placeMatrix;
			this.colorTransform = colorTransform;
			this.filterList = filterList;
			this.blendMode = blendMode;
		}
	}
}
