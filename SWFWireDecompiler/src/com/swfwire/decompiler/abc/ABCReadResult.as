package com.swfwire.decompiler.abc
{
	public class ABCReadResult
	{
		public var abcFile:ABCFile;
		public var metadata:ABCReaderMetadata;
		
		public function ABCReadResult(abcFile:ABCFile = null, metadata:ABCReaderMetadata = null)
		{
			if(!abcFile)
			{
				abcFile = new ABCFile();
			}
			if(!metadata)
			{
				metadata = new ABCReaderMetadata();
			}
			
			this.abcFile = abcFile;
			this.metadata = metadata;
		}
	}
}