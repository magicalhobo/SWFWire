package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.structures.MatrixRotateStructure;
	import com.swfwire.decompiler.data.swf.structures.MatrixScaleStructure;
	import com.swfwire.decompiler.data.swf.structures.MatrixTranslateStructure;
	
	public class MatrixRecord implements IRecord
	{
		public var scale:MatrixScaleStructure;
		public var rotate:MatrixRotateStructure;
		public var translate:MatrixTranslateStructure;
		
		public function read(swf:SWFByteArray):void
		{
			var hasScale:Boolean = swf.readFlag();
			if(hasScale)
			{
				var nScaleBits:uint = swf.readUB(5);
				
				if(!scale)
				{
					scale = new MatrixScaleStructure();
				}
				scale.x = swf.readFB(nScaleBits);
				scale.y = swf.readFB(nScaleBits);
			}
			else
			{
				scale = null;
			}
			
			var hasRotate:Boolean = swf.readFlag();
			if(hasRotate)
			{
				var nRotateBits:uint = swf.readUB(5);
				
				if(!rotate)
				{
					rotate = new MatrixRotateStructure();
				}
				rotate.skew0 = swf.readFB(nRotateBits);
				rotate.skew1 = swf.readFB(nRotateBits);
			}
			else
			{
				rotate = null;
			}
			
			var nTranslateBits:uint = swf.readUB(5);
			if(!translate)
			{
				translate = new MatrixTranslateStructure();
			}
			translate.x = swf.readFB(nTranslateBits);
			translate.y = swf.readFB(nTranslateBits);
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUB(1, scale ? 1 : 0);
			if(scale)
			{
				var nScaleBits:uint = Math.ceil(Math.log(Math.max(scale.x, scale.y)) * Math.LOG2E);
				swf.writeUB(5, nScaleBits);
				swf.writeFB(nScaleBits, scale.x);
				swf.writeFB(nScaleBits, scale.y);
			}
			
			swf.writeUB(1, rotate ? 1 : 0);
			if(rotate)
			{
				var nRotateBits:uint = Math.ceil(Math.log(Math.max(rotate.skew0, rotate.skew1)) * Math.LOG2E);
				swf.writeUB(5, nRotateBits);
				swf.writeFB(nRotateBits, rotate.skew0);
				swf.writeFB(nRotateBits, rotate.skew1);
			}
			
			var nTranslateBits:uint = Math.ceil(Math.log(Math.max(translate.x, translate.y)) * Math.LOG2E);
			swf.writeUB(5, nTranslateBits);
			swf.writeFB(nTranslateBits, translate.x);
			swf.writeFB(nTranslateBits, translate.y);
		}
	}
}