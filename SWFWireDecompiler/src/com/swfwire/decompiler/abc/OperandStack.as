package com.swfwire.decompiler.abc
{
	
	public class OperandStack
	{
		protected var values:Vector.<int> = new Vector.<int>();
		protected static var distinctvalue:Vector.<String> = new Vector.<String>();
		public static var stacks:Array;
		public var childs:Array = [];
		private static var idseq:int;
		protected var parent:int = -1;
		protected var id:int = -1;
		
		public static function init():void
		{
			idseq = 0;
			stacks = new Array();
		}
		
		public function OperandStack()
		{
		}
		
		private static function buildstack2(id:int):OperandStack
		{
			var ret:OperandStack = new OperandStack();
			ret.id = id;
			return ret;
		}
		
		protected static function assignid(obj:OperandStack):void
		{
			var oldid:int = obj.id;
			obj.id = idseq++;
		}
		
		public static function assignop(id:int, op:OperandStack):void
		{
			stacks[id] = op;
		}
		
		public static function buildstack():OperandStack
		{
			var ret:OperandStack = new OperandStack();
			assignid(ret);
			var cloned:OperandStack = ret.clone();
			if (cloned === null)
				throw new Error("error");
			assignop(ret.id, cloned);
			return ret;
		}
		
		public function clone(deep:Boolean = false):OperandStack
		{
			var ret:OperandStack = buildstack2(this.id);
			ret.parent = parent;
			if (deep)
			{
				ret.values = values.slice();
				ret.childs = childs.slice();
			}
			else
			{
				ret.values = values;
				ret.childs = childs;
			}
			return ret;
		}
		
		public function copyfrom(obj:OperandStack):void
		{
			id = obj.id;
			parent = obj.parent;
			values = obj.values;
			childs = obj.childs;
		}

		private function fork():OperandStack
		{
			var ret:OperandStack = clone(true);
			assignid(ret);
			return ret;
		}
		
		public function push(value:String):void
		{
			var refidx:int = distinctvalue.indexOf(value);
			if ((refidx != -1) && childs.hasOwnProperty(refidx))
			{
				copyfrom(stacks[childs[refidx]]);
			}
			else
			{
				var altered:OperandStack = fork();
				altered.childs = [];
				altered.parent = id;
				if (refidx == -1)
				{
					refidx = distinctvalue.length;
					distinctvalue.push(value);
				}
				stacks[altered.parent].childs[refidx] = altered.id;
				altered.values.push(refidx);
				assignop(altered.id, altered);
				copyfrom(altered);
			}
		}
		
		public function get length():int
		{
			return values.length;
		}
		
		public function getvalue(idx:int):String
		{
			return distinctvalue[values[idx]];
		}
		
		public function pop():String
		{
			var ret:String = null;
			
			if (parent == -1)
			{
				throw new Error("underflow");
			}
			else
			{
				ret = distinctvalue[values[values.length - 1]];
				copyfrom(stacks[parent]);
			}
			return ret;
		}
		
		public function toString():String
		{
			return String(id);
		}
		
		public function get getid():int
		{
			return id;
		}
		
		public function childinfo(refidx:int):String
		{
			return [id, '{', stackinfo, '}', '[', refidx, ']', '=', childs[refidx], '{', stacks[childs[refidx]].stackinfo, '}',].join(" ");
		}
		
		public function get stackinfo():String
		{
			return values.map((function(a:int):String { return distinctvalue[a]; } )).join(' ') + ['(', values.length, ')'].join('');
		}
	}
}