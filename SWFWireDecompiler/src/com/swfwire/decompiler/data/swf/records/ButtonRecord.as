package com.swfwire.decompiler.data.swf.records
{
	public class ButtonRecord
	{
		public var reserved:uint;
		public var stateHitTest:Boolean;
		public var stateDown:Boolean;
		public var stateOver:Boolean;
		public var stateUp:Boolean;
		public var characterId:uint;
		public var placeDepth:uint;
		public var placeMatrix:MatrixRecord;
		
		public function ButtonRecord(reserved:uint = 0, stateHitTest:Boolean = false, stateDown:Boolean = false, stateOver:Boolean = false, stateUp:Boolean = false, characterId:uint = 0, placeDepth:uint = 0, placeMatrix:MatrixRecord = null)
		{
			if(placeMatrix == null)
			{
				placeMatrix = new MatrixRecord();
			}
			
			this.reserved = reserved;
			this.stateHitTest = stateHitTest;
			this.stateDown = stateDown;
			this.stateOver = stateOver;
			this.stateUp = stateUp;
			this.characterId = characterId;
			this.placeDepth = placeDepth;
			this.placeMatrix = placeMatrix;
		}
	}
}