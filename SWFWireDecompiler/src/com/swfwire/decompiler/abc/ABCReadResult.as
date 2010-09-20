package com.swfwire.decompiler.abc
{
	public class ABCReadResult
	{
		public var abc:ABCFile;
		public var metadata:ABCReaderMetadata;
		
		public function ABCReadResult()
		{
			this.metadata = new ABCReaderMetadata();
		}
	}
}