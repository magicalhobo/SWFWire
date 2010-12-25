package com.swfwire.decompiler.data.swf.records
{
	public class StraightEdgeRecord implements IShapeRecord
	{
		public var generalLineFlag:Boolean;
		public var vertLineFlag:Boolean;
		public var deltaX:int;
		public var deltaY:int;

		public function StraightEdgeRecord(generalLineFlag:Boolean = false, vertLineFlag:Boolean = false, deltaX:int = 0, deltaY:int = 0)
		{
			this.generalLineFlag = generalLineFlag;
			this.vertLineFlag = vertLineFlag;
			this.deltaX = deltaX;
			this.deltaY = deltaY;
		}
	}
}