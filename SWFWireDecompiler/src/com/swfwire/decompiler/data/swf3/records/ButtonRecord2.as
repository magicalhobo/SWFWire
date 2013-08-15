package com.swfwire.decompiler.data.swf3.records
{
	import com.swfwire.decompiler.data.swf.records.*;

	public class ButtonRecord2 extends ButtonRecord
	{
		public var colorTransform:CXFormWithAlphaRecord;
		public var filterList:FilterListRecord;
		public var blendMode:uint;
		
		public function ButtonRecord2(record:ButtonRecord)
		{
			reserved = record.reserved;
			buttonHasBlendMode = record.buttonHasBlendMode;
			buttonHasFilterList = record.buttonHasFilterList;
			stateHitTest = record.stateHitTest;
			stateDown = record.stateDown;
			stateOver = record.stateOver;
			stateUp = record.stateUp;
			characterId = record.characterId;
			placeDepth = record.placeDepth;
			placeMatrix = record.placeMatrix;
		}
	}
}