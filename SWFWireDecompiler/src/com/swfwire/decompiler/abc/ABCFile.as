package com.swfwire.decompiler.abc
{
	import com.swfwire.decompiler.abc.tokens.*;

	public class ABCFile
	{
		public var minorVersion:uint;
		public var majorVersion:uint;
		public var cpool:ConstantPoolToken;
		public var methodCount:uint;
		public var methods:Vector.<MethodInfoToken>;
		public var metadataCount:uint;
		public var metadata:Vector.<MetadataInfoToken>;
		public var classCount:uint;
		public var instances:Vector.<InstanceToken>;
		public var classes:Vector.<ClassInfoToken>;
		public var scriptCount:uint;
		public var scripts:Vector.<ScriptInfoToken>;
		public var methodBodyCount:uint;
		public var methodBodies:Vector.<MethodBodyInfoToken>;
	}
}