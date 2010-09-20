package com.swfwire.decompiler.data.swf7.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;

	public class ScriptLimitsTag extends SWFTag
	{
		public var maxRecursionDepth:uint;
		public var scriptTimeoutSeconds:uint;

		public function ScriptLimitsTag(maxRecursionDepth:uint = 0, scriptTimeoutSeconds:uint = 0)
		{
			this.maxRecursionDepth = maxRecursionDepth;
			this.scriptTimeoutSeconds = scriptTimeoutSeconds;
		}
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			maxRecursionDepth = swfcontext.bytes.readUI16();
			scriptTimeoutSeconds = swfcontext.bytes.readUI16();
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			swfBytes.writeUI16(maxRecursionDepth);
			swfBytes.writeUI16(scriptTimeoutSeconds);
		}
		*/
	}
}