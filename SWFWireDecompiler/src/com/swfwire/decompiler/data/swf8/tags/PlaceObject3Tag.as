package com.swfwire.decompiler.data.swf8.tags
{
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.records.FilterListRecord;
	import com.swfwire.decompiler.data.swf.records.MatrixRecord;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf3.records.CXFormWithAlphaRecord;
	
	public class PlaceObject3Tag extends SWFTag
	{
		public var move:Boolean;
		public var reserved:uint;
		public var depth:uint;
		public var className:String;
		public var characterId:Object;
		public var matrix:MatrixRecord;
		public var colorTransform:CXFormWithAlphaRecord;
		public var ratio:Object;
		public var name:String;
		public var clipDepth:Object;
		public var surfaceFilterList:FilterListRecord;
		public var blendMode:uint;
		public var bitmapCache:uint;
		public var clipActions:ClipActionsRecord;
		
		public function PlaceObject3Tag(move:Boolean = false, reserved:uint = 0, depth:uint = 0, className:String = null, characterId:Object = null, matrix:MatrixRecord = null, colorTransform:CXFormWithAlphaRecord = null, ratio:Object = null, name:String = null, clipDepth:Object = null, surfaceFilterList:FilterListRecord = null, blendMode:uint = 0, bitmapCache:uint = 0, clipActions:ClipActionsRecord = null)
		{
			if(colorTransform == null)
			{
				colorTransform = new CXFormWithAlphaRecord();
			}
			if(surfaceFilterList == null)
			{
				surfaceFilterList = new FilterListRecord();
			}
			if(clipActions == null)
			{
				clipActions = new ClipActionsRecord();
			}
			
			this.move = move;
			this.reserved = reserved;
			this.depth = depth;
			this.className = className;
			this.characterId = characterId;
			this.matrix = matrix;
			this.colorTransform = colorTransform;
			this.ratio = ratio;
			this.name = name;
			this.clipDepth = clipDepth;
			this.surfaceFilterList = surfaceFilterList;
			this.blendMode = blendMode;
			this.bitmapCache = bitmapCache;
			this.clipActions = clipActions;
		}
	}
}
