package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf3.records.GradientControlPointRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientRecord2;

	public class SWF3Writer extends SWFWriter
	{
		private static var FILE_VERSION:uint = 3;
		
		public function SWF3Writer()
		{
			version = FILE_VERSION;
		}
		
		protected function writeGradientControlPointRecord2(context:SWFWriterContext, record:GradientControlPointRecord2):void
		{
			context.bytes.writeUI8(record.ratio);
			writeRGBARecord(context, record.color);
		}
		
		protected function writeGradientRecord2(context:SWFWriterContext, record:GradientRecord2):void
		{
			context.bytes.alignBytes();
			
			context.bytes.writeUB(2, record.spreadMode);
			context.bytes.writeUB(2, record.interpolationMode);
			context.bytes.writeUB(4, record.numGradients);
			for(var iter:uint = 0; iter < record.numGradients; iter++)
			{
				writeGradientControlPointRecord2(context, record.gradientRecords[iter]);
			}
		}
	}
}