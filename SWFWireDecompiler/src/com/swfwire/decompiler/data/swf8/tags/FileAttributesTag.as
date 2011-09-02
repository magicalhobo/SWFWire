package com.swfwire.decompiler.data.swf8.tags
{
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class FileAttributesTag extends SWFTag
	{
		public var useDirectBlit:Boolean;
		public var useGPU:Boolean;
		public var hasMetadata:Boolean;
		public var actionScript3:Boolean;
		public var useNetwork:Boolean;

		public function FileAttributesTag(useDirectBlit:Boolean = false, useGPU:Boolean = false, hasMetadata:Boolean = false, actionScript3:Boolean = false, useNetwork:Boolean = false)
		{
			this.useDirectBlit = useDirectBlit;
			this.useGPU = useGPU;
			this.hasMetadata = hasMetadata;
			this.actionScript3 = actionScript3;
			this.useNetwork = useNetwork;
		}
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			swfcontext.bytes.readUB(1);
			useDirectBlit = swfcontext.bytes.readFlag();
			useGPU = swfcontext.bytes.readFlag();
			hasMetadata = swfcontext.bytes.readFlag();
			actionScript3 = swfcontext.bytes.readFlag();
			swfcontext.bytes.readUB(2);
			useNetwork = swfcontext.bytes.readFlag();
			swfcontext.bytes.readUB(24);
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			swfBytes.writeUB(1, 0);
			swfBytes.writeUB(1, useDirectBlit ? 1 : 0);
			swfBytes.writeUB(1, useGPU ? 1 : 0);
			swfBytes.writeUB(1, hasMetadata ? 1 : 0);
			swfBytes.writeUB(1, actionScript3 ? 1 : 0);
			swfBytes.writeUB(2, 0);
			swfBytes.writeUB(1, useNetwork ? 1 : 0);
			swfBytes.writeUB(24, 0);
		}
		*/
	}
}