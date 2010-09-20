package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.CXFormRecord;
	import com.swfwire.decompiler.data.swf.records.MatrixRecord;

	public class PlaceObjectTag extends SWFTag
	{
		public var characterId:uint;
		public var depth:uint;
		public var matrix:MatrixRecord;
		public var colorTransform:CXFormRecord;
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			var originalPosition:uint = swfcontext.bytes.getBytePosition();
			characterId = swfcontext.bytes.readUI16();
			depth = swfcontext.bytes.readUI16();
			matrix = new MatrixRecord();
			matrix.read(swfBytes);
			if(header.length > (swfcontext.bytes.getBytePosition() - originalPosition))
			{
				colorTransform = new CXFormRecord();
				colorTransform.read(swfBytes);
			}
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			swfBytes.writeUI16(characterId);
			swfBytes.writeUI16(depth);
			matrix.write(swfBytes);
			if(colorTransform)
			{
				colorTransform.write(swfBytes);
			}
		}
		*/
	}
}