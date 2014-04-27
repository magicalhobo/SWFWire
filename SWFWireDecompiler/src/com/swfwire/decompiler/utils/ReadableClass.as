package com.swfwire.decompiler.utils
{
	public class ReadableClass
	{
		public static const CLASS:String = 'class';
		public static const INTERFACE:String = 'interface';
		
		public var className:ReadableMultiname;
		public var superName:ReadableMultiname;
		public var traits:Array;
		public var interfaces:Array;
		public var type:String;
	}
}