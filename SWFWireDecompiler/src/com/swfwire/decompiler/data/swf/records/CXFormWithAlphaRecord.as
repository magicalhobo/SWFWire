package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class CXFormWithAlphaRecord implements IRecord
	{
		public var hasAddTerms:Boolean;
		public var hasMultTerms:Boolean;
		
		public var nBits:uint;
		
		public var redMultTerm:int;
		public var greenMultTerm:int;
		public var blueMultTerm:int;
		public var alphaMultTerm:int;
		
		public var redAddTerm:int;
		public var greenAddTerm:int;
		public var blueAddTerm:int;
		public var alphaAddTerm:int;
		
		public function read(swf:SWFByteArray):void
		{
			hasAddTerms = swf.readFlag();
			hasMultTerms = swf.readFlag();
			nBits = swf.readUB(4);
			
			if(hasMultTerms)
			{
				redMultTerm = swf.readSB(nBits);
				greenMultTerm = swf.readSB(nBits);
				blueMultTerm = swf.readSB(nBits);
				alphaMultTerm = swf.readSB(nBits);
			}
			
			if(hasAddTerms)
			{
				redAddTerm = swf.readSB(nBits);
				greenAddTerm = swf.readSB(nBits);
				blueAddTerm = swf.readSB(nBits);
				alphaAddTerm = swf.readSB(nBits);
			}
		}
		public function write(swf:SWFByteArray):void
		{
			hasAddTerms = swf.readFlag();
			hasMultTerms = swf.readFlag();
			nBits = swf.readUB(4);
			
			if(hasMultTerms)
			{
				redMultTerm = swf.readSB(nBits);
				greenMultTerm = swf.readSB(nBits);
				blueMultTerm = swf.readSB(nBits);
				alphaMultTerm = swf.readSB(nBits);
			}
			
			if(hasAddTerms)
			{
				redAddTerm = swf.readSB(nBits);
				greenAddTerm = swf.readSB(nBits);
				blueAddTerm = swf.readSB(nBits);
				alphaAddTerm = swf.readSB(nBits);
			}
		}
	}
}