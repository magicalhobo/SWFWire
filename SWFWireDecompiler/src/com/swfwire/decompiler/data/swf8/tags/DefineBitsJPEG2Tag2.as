package com.swfwire.decompiler.data.swf8.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	
	import flash.utils.ByteArray;
	
	/**
	 * This one supports PNG and GIF89a data
	 */
	public class DefineBitsJPEG2Tag2 extends SWFTag
	{
		private static const PNG_SIGNATURE:Array = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
		private static const GIF_SIGNATURE:Array = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61];
		
		public var characterID:uint;
		public var imageData:ByteArray;

		public function DefineBitsJPEG2Tag2(characterID:uint = 0, imageData:ByteArray = null)
		{
			if(imageData == null)
			{
				imageData = new ByteArray();
			}

			this.characterID = characterID;
			this.imageData = imageData;
		}
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			characterID = swfcontext.bytes.readUI16();
			imageData.clear();
			swfcontext.bytes.readBytes(imageData, 0, header.length - 2);
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			swfBytes.writeUI16(characterID);
			swfBytes.writeBytes(imageData);
		}
		*/
	}
}