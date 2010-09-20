package com.swfwire.decompiler.data.swf8.records
{
	import com.swfwire.decompiler.data.swf.records.FillStyleRecord;
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
	}
}