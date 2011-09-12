package com.swfwire.decompiler.abc
{
	import flash.utils.Dictionary;
	public class LocalRegisters
	{
		public var values:Array = [];
		public var names:Array = [];
		private var prefixtolastvaridx:Dictionary = new Dictionary(true);
		public function setValue(index:uint, value:*):void
		{
			values[index] = value;
		}
		public function getValue(index:uint):*
		{
			return values[index];
		}
		public function setName(index:uint, name:String):void
		{
			names[index] = name;
		}
		public function getName(index:uint):String
		{
			return names[index];
		}
		public function decidenewvarnamewithprefix(name:String):String {
			if (!prefixtolastvaridx.hasOwnProperty(name)) {
				prefixtolastvaridx[name] = 1;
			}
			else {
				prefixtolastvaridx[name] = prefixtolastvaridx[name] + 1;
			}
			return name + prefixtolastvaridx[name];
		}
	}
}