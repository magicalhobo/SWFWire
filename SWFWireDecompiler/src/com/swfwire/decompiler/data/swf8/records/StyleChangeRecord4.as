package com.swfwire.decompiler.data.swf8.records
{
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf3.records.FillStyleArrayRecord3;

	public class StyleChangeRecord4 implements IShapeRecord
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
		public var fillStyles:FillStyleArrayRecord3;
		public var lineStyles:LineStyle2ArrayRecord;
		public var numFillBits:uint;
		public var numLineBits:uint;

		public function StyleChangeRecord4(stateNewStyles:Boolean = false, stateLineStyle:Boolean = false, stateFillStyle1:Boolean = false,
										   stateFillStyle0:Boolean = false, stateMoveTo:Boolean = false, moveBits:uint = 0, moveDeltaX:int = 0,
										   moveDeltaY:int = 0, fillStyle0:uint = 0, fillStyle1:uint = 0, lineStyle:uint = 0,
										   fillStyles:FillStyleArrayRecord3 = null, lineStyles:LineStyle2ArrayRecord = null,
										   numFillBits:uint = 0, numLineBits:uint = 0)
		{
			this.stateNewStyles = stateNewStyles;
			this.stateLineStyle = stateLineStyle;
			this.stateFillStyle1 = stateFillStyle1;
			this.stateFillStyle0 = stateFillStyle0;
			this.stateMoveTo = stateMoveTo;
			this.moveBits = moveBits;
			this.moveDeltaX = moveDeltaX;
			this.moveDeltaY = moveDeltaY;
			this.fillStyle0 = fillStyle0;
			this.fillStyle1 = fillStyle1;
			this.lineStyle = lineStyle;
			this.fillStyles = fillStyles;
			this.lineStyles = lineStyles;
			this.numFillBits = numFillBits;
			this.numLineBits = numLineBits;
		}
	}
}