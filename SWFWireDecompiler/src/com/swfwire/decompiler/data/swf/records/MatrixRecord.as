package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.data.swf.structures.MatrixRotateStructure;
	import com.swfwire.decompiler.data.swf.structures.MatrixScaleStructure;
	import com.swfwire.decompiler.data.swf.structures.MatrixTranslateStructure;
	
	public class MatrixRecord implements IRecord
	{
		public var scale:MatrixScaleStructure;
		public var rotate:MatrixRotateStructure;
		public var translate:MatrixTranslateStructure;
		
		public function MatrixRecord(scale:MatrixScaleStructure = null, rotate:MatrixRotateStructure = null,
									 translate:MatrixTranslateStructure = null)
		{
			this.scale = scale;
			this.rotate = rotate;
			this.translate = translate;
		}
	}
}