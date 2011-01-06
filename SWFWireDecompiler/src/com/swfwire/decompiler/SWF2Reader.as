package com.swfwire.decompiler
{
	import com.swfwire.decompiler.data.swf.*;
	import com.swfwire.decompiler.data.swf.records.*;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf2.records.*;
	import com.swfwire.decompiler.data.swf2.tags.*;
	import com.swfwire.utils.ObjectUtil;
	
	import flash.utils.ByteArray;
	
	public class SWF2Reader extends SWFReader
	{
		private static var FILE_VERSION:uint = 2;
		
		public function SWF2Reader()
		{
			version = FILE_VERSION;
		}
		
		override protected function readTag(context:SWFReaderContext, header:TagHeaderRecord):SWFTag
		{
			var tag:SWFTag;
			if(context.fileVersion < FILE_VERSION)
			{
				tag = super.readTag(context, header);
			}
			else
			{
				switch(header.type)
				{
					/*
					case 17: tag = readDefineButtonSoundTag(context, header);
					case 20: tag = readDefineBitsLosslessTag(context, header);
					case 23: tag = readDefineButtonCxformTag(context, header);
					case 24: tag = readProtectTag(context, header);
					*/
					case 21:
						tag = readDefineBitsJPEG2Tag(context, header);
						break;
					case 22:
						tag = readDefineShape2Tag(context, header);
						break;
					default:
						tag = super.readTag(context, header);
						break;
				}
			}
			return tag;
		}
		
		protected function readDefineBitsJPEG2Tag(context:SWFReaderContext, header:TagHeaderRecord):DefineBitsJPEG2Tag
		{
			var tag:DefineBitsJPEG2Tag = new DefineBitsJPEG2Tag();
			tag.characterID = context.bytes.readUI16();
			tag.imageData = new ByteArray();
			var length:int = header.length - 2;
			if(length > 0)
			{
				context.bytes.readBytes(tag.imageData, 0, length);
			}
			return tag;
		}
		
		protected function readDefineShape2Tag(context:SWFReaderContext, header:TagHeaderRecord):DefineShape2Tag
		{
			var tag:DefineShape2Tag = new DefineShape2Tag();
			tag.shapeId = context.bytes.readUI16();
			tag.shapeBounds = readRectangleRecord(context);
			tag.shapes = readShapeWithStyleRecord2(context);
			return tag;
		}
		
		protected function readFillStyleArrayRecord2(context:SWFReaderContext):FillStyleArrayRecord2
		{
			var record:FillStyleArrayRecord2 = new FillStyleArrayRecord2();
			
			record.count = context.bytes.readUI8();
			if(record.count == 0xFF)
			{
				record.countExtended = context.bytes.readUI16();
			}
			record.fillStyles = new Vector.<FillStyleRecord>(record.count);
			for(var iter:uint = 0; iter < record.count; iter++)
			{
				record.fillStyles[iter] = readFillStyleRecord(context);
			}
			
			return record;
		}
		
		protected function readShapeWithStyleRecord2(context:SWFReaderContext):ShapeWithStyleRecord2
		{
			var record:ShapeWithStyleRecord2 = new ShapeWithStyleRecord2();
			
			record.fillStyles = readFillStyleArrayRecord2(context);
			record.lineStyles = readLineStyleArrayRecord(context);
			var numFillBits:uint = context.bytes.readUB(4);
			var numLineBits:uint = context.bytes.readUB(4);
			record.numFillBits = numFillBits;
			record.numLineBits = numLineBits;
			record.shapeRecords = new Vector.<IShapeRecord>();
			
			while(true)
			{
				var shapeRecord:IShapeRecord = readShapeRecord2(context, numFillBits, numLineBits);
				record.shapeRecords.push(shapeRecord);
				if(shapeRecord is StyleChangeRecord2)
				{
					if(StyleChangeRecord2(shapeRecord).stateNewStyles)
					{
						numFillBits = StyleChangeRecord2(shapeRecord).numFillBits;
						numLineBits = StyleChangeRecord2(shapeRecord).numLineBits;
					}
				}
				if(shapeRecord is EndShapeRecord)
				{
					break;
				}
			}
			
			return record;
		}
		
		protected function readShapeRecord2(context:SWFReaderContext, numFillBits:uint, numLineBits:uint):IShapeRecord
		{
			var record:IShapeRecord;
			var typeFlag:Boolean = context.bytes.readFlag();
			if(!typeFlag)
			{
				var stateNewStyles:Boolean = context.bytes.readFlag();
				var stateLineStyle:Boolean = context.bytes.readFlag();
				var stateFillStyle1:Boolean = context.bytes.readFlag();
				var stateFillStyle0:Boolean = context.bytes.readFlag();
				var stateMoveTo:Boolean = context.bytes.readFlag();
				if(!stateNewStyles &&
					!stateLineStyle &&
					!stateFillStyle1 &&
					!stateFillStyle0 &&
					!stateMoveTo)
				{
					record = new EndShapeRecord();
				}
				else
				{
					record = readStyleChangeRecord2(context,
						stateNewStyles,
						stateLineStyle,
						stateFillStyle1,
						stateFillStyle0,
						stateMoveTo,
						numFillBits,
						numLineBits);
				}
			}
			else
			{
				var straightFlag:Boolean = context.bytes.readFlag();
				if(straightFlag)
				{
					record = readStraightEdgeRecord(context);
				}
				else
				{
					record = readCurvedEdgeRecord(context);
				}
			}
			return record;
		}
		
		protected function readStyleChangeRecord2(context:SWFReaderContext, stateNewStyles:Boolean,
			stateLineStyle:Boolean, stateFillStyle1:Boolean,
			stateFillStyle0:Boolean, stateMoveTo:Boolean, 
			numFillBits:uint, numLineBits:uint):StyleChangeRecord2
		{
			var record:StyleChangeRecord2 = new StyleChangeRecord2();
			record.stateNewStyles = stateNewStyles;
			record.stateLineStyle = stateLineStyle;
			record.stateFillStyle1 = stateFillStyle1;
			record.stateFillStyle0 = stateFillStyle0;
			record.stateMoveTo = stateMoveTo;
			
			if(stateMoveTo)
			{
				record.moveBits = context.bytes.readUB(5);
				record.moveDeltaX = context.bytes.readSB(record.moveBits);
				record.moveDeltaY = context.bytes.readSB(record.moveBits);
			}
			if(stateFillStyle0)
			{
				record.fillStyle0 = context.bytes.readUB(numFillBits);
			}
			if(stateFillStyle1)
			{
				record.fillStyle1 = context.bytes.readUB(numFillBits);
			}
			if(stateLineStyle)
			{
				record.lineStyle = context.bytes.readUB(numLineBits);
			}
			if(stateNewStyles)
			{
				record.fillStyles = readFillStyleArrayRecord2(context);
				record.lineStyles = readLineStyleArrayRecord(context);
				record.numFillBits = context.bytes.readUB(4);
				record.numLineBits = context.bytes.readUB(4);
			}
			return record;
		}
	}
}