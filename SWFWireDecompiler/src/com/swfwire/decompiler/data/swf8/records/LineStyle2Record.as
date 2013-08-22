package com.swfwire.decompiler.data.swf8.records
{
	import com.swfwire.decompiler.data.swf.records.RGBARecord;
	import com.swfwire.decompiler.data.swf3.records.FillStyleRecord2;

	public class LineStyle2Record
	{
		public var width:uint;
		public var startCapStyle:uint;
		public var joinStyle:uint;
		public var hasFillFlag:Boolean;
		public var noHScaleFlag:Boolean;
		public var noVScaleFlag:Boolean;
		public var pixelHintingFlag:Boolean;
		public var reserved:uint;
		public var noClose:Boolean;
		public var endCapStyle:uint;
		public var miterLimitFactor:Number;
		public var color:RGBARecord;
		public var fillType:FillStyleRecord2;
		
		
		public function LineStyle2Record(width:uint = 0, startCapStyle:uint = 0, joinStyle:uint = 0, hasFillFlag:Boolean = false,
										 noHScaleFlag:Boolean = false, noVScaleFlag:Boolean = false, pixelHintingFlag:Boolean = false,
										 reserved:uint = 0, noClose:Boolean = false, endCapStyle:uint = 0, miterLimitFactor:Number = NaN,
										 color:RGBARecord = null, fillType:FillStyleRecord2 = null)
		{
			this.width = width;
			this.startCapStyle = startCapStyle;
			this.joinStyle = joinStyle;
			this.hasFillFlag = hasFillFlag;
			this.noHScaleFlag = noHScaleFlag;
			this.noVScaleFlag = noVScaleFlag;
			this.pixelHintingFlag = pixelHintingFlag;
			this.reserved = reserved;
			this.noClose = noClose;
			this.endCapStyle = endCapStyle;
			this.miterLimitFactor = miterLimitFactor;
			this.color = color;
			this.fillType = fillType;
		}
	}
}