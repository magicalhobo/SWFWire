package com.swfwire.decompiler.data.swf.records
{
	public class CurvedEdgeRecord implements IShapeRecord
	{
		public var controlDeltaX:int;
		public var controlDeltaY:int;
		public var anchorDeltaX:int;
		public var anchorDeltaY:int;

		public function CurvedEdgeRecord(controlDeltaX:int = 0, controlDeltaY:int = 0, anchorDeltaX:int = 0, anchorDeltaY:int = 0)
		{
			this.controlDeltaX = controlDeltaX;
			this.controlDeltaY = controlDeltaY;
			this.anchorDeltaX = anchorDeltaX;
			this.anchorDeltaY = anchorDeltaY;
		}
	}
}