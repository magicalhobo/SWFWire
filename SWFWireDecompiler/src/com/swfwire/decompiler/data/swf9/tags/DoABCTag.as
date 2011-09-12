package com.swfwire.decompiler.data.swf9.tags
{
	import com.swfwire.decompiler.abc.ABCFile;
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	
	public class DoABCTag extends SWFTag
	{
		public var flags:uint;
		public var name:String;
		public var abcFile:ABCFile;

		public function DoABCTag(flags:uint = 0, name:String = '', abcFile:ABCFile = null)
		{
			if(abcFile == null)
			{
				abcFile = new ABCFile();
			}

			this.flags = flags;
			this.name = name;
			this.abcFile = abcFile;
		}
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			var nonABCData:uint = swfcontext.bytes.getBytePosition();
			flags = swfcontext.bytes.readUI32();
			name = swfcontext.bytes.readString();
			nonABCData = header.length - (swfcontext.bytes.getBytePosition() - nonABCData);
			var abcData:ByteArray = new ByteArray();
			swfcontext.bytes.readBytes(abcData, 0, nonABCData);
			
			abcFile = new ABCFile();
			abcFile.read(abcData);
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			swfBytes.writeUI32(flags);
			swfBytes.writeString(name);
			
			var abcData:ByteArray = new ByteArray();
			abcFile.write(abcData);
			swfBytes.writeBytes(abcData);
		}
		*/
	}
}