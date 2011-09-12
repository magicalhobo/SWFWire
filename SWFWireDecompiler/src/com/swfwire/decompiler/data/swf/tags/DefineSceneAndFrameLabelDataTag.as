package com.swfwire.decompiler.data.swf.tags
{
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.SWFByteArray;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.records.FrameLabelRecord;
	import com.swfwire.decompiler.data.swf.records.SceneRecord;
	
	public class DefineSceneAndFrameLabelDataTag extends SWFTag
	{
		public var scenes:Vector.<SceneRecord>;
		public var frameLabels:Vector.<FrameLabelRecord>;

		public function DefineSceneAndFrameLabelDataTag(scenes:Vector.<SceneRecord> = null, frameLabels:Vector.<FrameLabelRecord> = null)
		{
			if(scenes == null)
			{
				scenes = new Vector.<SceneRecord>();
			}
			if(frameLabels == null)
			{
				frameLabels = new Vector.<FrameLabelRecord>();
			}

			this.scenes = scenes;
			this.frameLabels = frameLabels;
			
		}
		/*
		override public function read(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.read(swf, swfBytes);

			var iter:uint;
			
			var sceneCount:uint = swfcontext.bytes.readEncodedUI32();
			scenes.length = sceneCount;
			for(iter = 0; iter < sceneCount; iter++)
			{
				var scene:SceneRecord = new SceneRecord();
				scene.read(swfBytes);
				scenes[iter] = scene;
			}
			var frameLabelCount:uint = swfcontext.bytes.readEncodedUI32();
			frameLabels.length = frameLabelCount;
			for(iter = 0; iter < frameLabelCount; iter++)
			{
				var frameLabel:FrameLabelRecord = new FrameLabelRecord();
				frameLabel.read(swfBytes);
				frameLabels[iter] = frameLabel;
			}
		}
		override public function write(swf:SWF, swfBytes:SWFByteArray):void
		{
			super.write(swf, swfBytes);

			var iter:uint;
			
			swfBytes.writeUI32(scenes.length);
			for(iter = 0; iter < scenes.length; iter++)
			{
				scenes[iter].write(swfBytes);
			}
			swfBytes.writeUI32(frameLabels.length);
			for(iter = 0; iter < frameLabels.length; iter++)
			{
				frameLabels[iter].write(swfBytes);
			}
		}
		*/
	}
}