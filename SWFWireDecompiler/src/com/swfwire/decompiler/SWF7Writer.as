package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf7.tags.*;
	
	public class SWF7Writer extends SWF6Writer
	{
		public static const TAG_IDS:Object = {
			60: DefineVideoStreamTag,
			66: SetTabIndexTag,
			65: ScriptLimitsTag
		};
		
		private static var FILE_VERSION:uint = 7;
		
		public function SWF7Writer()
		{
			version = FILE_VERSION;
			registerTags(TAG_IDS);
		}
		
		override protected function writeTag(context:SWFWriterContext, tag:SWFTag):void
		{
			switch(Object(tag).constructor)
			{
				/*
				case 60:
					tag = writeDefineVideoStreamTag(context);
					break;
				case 66:
					tag = writeSetTabIndexTag(context);
					break;
				*/
				case ScriptLimitsTag:
					writeScriptLimitsTag(context, ScriptLimitsTag(tag));
					break;
				default:
					super.writeTag(context, tag);
					break;
			}
		}
		
		protected function writeScriptLimitsTag(context:SWFWriterContext, tag:ScriptLimitsTag):void
		{
			context.bytes.writeUI16(tag.maxRecursionDepth);
			context.bytes.writeUI16(tag.scriptTimeoutSeconds);
		}
	}
}