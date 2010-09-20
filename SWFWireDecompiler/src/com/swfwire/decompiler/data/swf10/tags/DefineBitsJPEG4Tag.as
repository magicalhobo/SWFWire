package com.swfwire.decompiler.data.swf10.tags
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	import flash.utils.ByteArray;
	
	public class DefineBitsJPEG4Tag extends SWFTag
	{
		public var characterID:uint;
		public var alphaDataOffset:uint;
		public var deblockParam:uint;
		public var imageData:ByteArray;
		public var bitmapAlphaData:ByteArray;
	}
}