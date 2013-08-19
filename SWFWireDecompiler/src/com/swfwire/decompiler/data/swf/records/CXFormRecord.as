package com.swfwire.decompiler.data.swf.records
{
	public class CXFormRecord
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

		public function CXFormRecord(hasAddTerms:Boolean = false, hasMultTerms:Boolean = false, nBits:uint = 0, redMultTerm:int = 0, greenMultTerm:int = 0, blueMultTerm:int = 0, redAddTerm:int = 0, greenAddTerm:int = 0, blueAddTerm:int = 0)
		{
			this.hasAddTerms = hasAddTerms;
			this.hasMultTerms = hasMultTerms;
			this.nBits = nBits;
			this.redMultTerm = redMultTerm;
			this.greenMultTerm = greenMultTerm;
			this.blueMultTerm = blueMultTerm;
			this.redAddTerm = redAddTerm;
			this.greenAddTerm = greenAddTerm;
			this.blueAddTerm = blueAddTerm;
		}
	}
}