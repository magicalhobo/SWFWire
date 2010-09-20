package com.swfwire.decompiler
{
	public class SWFNormalizer
	{
		/*
		public function normalize():void
		{
			if(signature != COMPRESSED_SIGNATURE)
			{
				signature != UNCOMPRESSED_SIGNATURE;
			}
			
			var bufferBytes:ByteArray = new ByteArray();
			var bufferSwf:SWFByteArray = new SWFByteArray(bufferBytes);
			
			frameSize.write(bufferSwf);
			var uncompressedSize:uint = 8 + bufferBytes.length + 4;
			var frameCount:uint = 0;
			
			for(var iter:uint = 0; iter < tags.length; iter++)
			{
				bufferSwf.clear();
				var tag:SWFTag = tags[iter];
				tag.write(this, bufferSwf);
				if(!tag.header)
				{
					tag.header = new TagHeaderRecord();
				}
				var tagClass:Class = Object(tag).constructor;
				tag.header.type = getTagId(tagClass);
				if(tag is UnknownTag)
				{
					tag.header.type = UnknownTag(tag).type;
				}
				if(tag is ShowFrameTag)
				{
					frameCount++;
				}
				tag.header.length = bufferBytes.length;
				tag.header.write(bufferSwf);
				uncompressedSize += bufferBytes.length;
			}
			
			this.uncompressedSize = uncompressedSize;
			this.frameCount = frameCount;
		}
		*/
	}
}