package com.swfwire.decompiler.data.swf.records
{
	import com.swfwire.decompiler.SWFReader;
	import com.swfwire.decompiler.SWFByteArray;
	
	public class CXFormRecord implements IRecord
	{
		public var hasAddTerms:Boolean;
		public var hasMultTerms:Boolean;
		public var nBits:uint;
		public var redMultTerm:int;
		public var greenMultTerm:int;
		public var blueMultTerm:int;
		public var redAddTerm:int;
		public var greenAddTerm:int;
		public var blueAddTerm:int;
		
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
			}
			
			if(hasAddTerms)
			{
				redAddTerm = swf.readSB(nBits);
				greenAddTerm = swf.readSB(nBits);
				blueAddTerm = swf.readSB(nBits);
			}
		}
		public function write(swf:SWFByteArray):void
		{
			swf.writeUB(1, hasAddTerms ? 1 : 0);
			swf.writeUB(1, hasMultTerms ? 1 : 0);
			
			throw new Error('This needs to really calculate the nBits!');
			swf.writeUB(4, nBits);
			
			if(hasMultTerms)
			{
				swf.writeSB(nBits, redMultTerm);
				swf.writeSB(nBits, greenMultTerm);
				swf.writeSB(nBits, blueMultTerm);
			}
			
			if(hasAddTerms)
			{
				swf.writeSB(nBits, redAddTerm);
				swf.writeSB(nBits, greenAddTerm);
				swf.writeSB(nBits, blueAddTerm);
			}
		}
	}
}