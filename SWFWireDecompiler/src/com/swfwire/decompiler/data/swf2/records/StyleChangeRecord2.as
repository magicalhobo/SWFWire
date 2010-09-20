package com.swfwire.decompiler.data.swf2.records
{
	import com.swfwire.decompiler.data.swf.records.*;

	public class StyleChangeRecord2 implements IShapeRecord
	{
		public var stateNewStyles:Boolean;
		public var stateLineStyle:Boolean;
		public var stateFillStyle1:Boolean;
		public var stateFillStyle0:Boolean;
		public var stateMoveTo:Boolean;
		public var moveBits:uint;
		public var moveDeltaX:int;
		public var moveDeltaY:int;
		public var fillStyle0:uint;
		public var fillStyle1:uint;
		public var lineStyle:uint;
		public var fillStyles:FillStyleArrayRecord2;
		public var lineStyles:LineStyleArrayRecord;
		public var numFillBits:uint;
		public var numLineBits:uint;
	}
}