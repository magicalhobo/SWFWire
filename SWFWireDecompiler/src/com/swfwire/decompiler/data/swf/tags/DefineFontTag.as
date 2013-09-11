package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.records.ShapeRecord;

	public class DefineFontTag extends SWFTag
	{
		public var fontId:uint;
		public var offsetTable:Vector.<uint>;
		public var glyphShapeTable:Vector.<ShapeRecord>;
		
		public function DefineFontTag(fontId:uint = 0, offsetTable:Vector.<uint> = null, glyphShapeTable:Vector.<ShapeRecord> = null)
		{
			if(offsetTable == null)
			{
				offsetTable = new Vector.<uint>();
			}
			if(glyphShapeTable == null)
			{
				glyphShapeTable = new Vector.<ShapeRecord>();
			}
			
			this.fontId = fontId;
			this.offsetTable = offsetTable;
			this.glyphShapeTable = glyphShapeTable;
		}
	}
}