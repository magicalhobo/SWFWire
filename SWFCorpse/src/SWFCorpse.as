package
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.NetConnection;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.osmf.display.ScaleMode;
	
	import packagename.ClassName;
	
	public class SWFCorpse extends Sprite
	{
		/*
		public function testSpeed():void
		{
			trace('1');
			if(1 || 2 || 3 || 4 || 5)
			{
				trace('1 - 5');
			}
			trace('2');
			if(1 && 2 && 3 && 4 && 5)
			{
				trace('1 and 5');
			}
			trace('1');
			if(1 || 2)
			{
				trace('1 - 5');
			}
			trace('3');
		}
		*/
		/*
		public function testIntMath():void
		{
			var a:int = 1;
			var b:int = 1;
			var c:int;
			a++;
			++a;
			a += 1;
			b--;
			--b;
			b -= 1;
		
			c = a + b;
			c = a - b;
			c = a * b;
			c = a / b;
			c = a % b;
			
			c = 1 + 1;
			c = 1 - 1;
			c = 1 * 1;
			c = 1 / 1;
			c = 1 % 1;
		}
		
		public function testBitwise():void
		{
			var n:Number = 0;
			n |= 1;
			n &= 1;
			n <<= 1;
			n >>= 1;
			n >>>= 1;
			n = 1 << 2;
			n = 1 >> 2;
			n = 1 >>> 2;
			n = n ^ 1;
			n = ~n;
		}
		
		public function testIfElse():void
		{
			trace('start');
			if('1')
			{
				trace('1');
			}
			else if('2')
			{
				trace('2');
			}
			else if('3')
			{
				trace('3');
			}
			else
			{
				trace('none');
			}
			trace('end');
		}
		
		public function testSwitch():void
		{
			trace('start');
			switch('condition')
			{
				case '1':
					trace('1');
					break;
				case '2':
					trace('2');
					break;
				case '3':
					trace('3');
					break;
			}
			trace('end');
		}
		
		public function testLogical():void
		{
			trace('1');
			if(1 || 2)
			{
				trace('1 or 2');
			}
			trace('2');
			if(1 && 2)
			{
				trace('1 and 2');
			}
			trace('3');
		}
		
		/*
		public function testTernary():void
		{
			trace('1');
			var result:String = 'condition' ? 'yes' : 'no';
			trace('2');
		}
		/*
		public function testMemberWithNamespace():void
		{
			trace('1');
			mynamespace::test;
			mynamespace::test = 'set';
			trace('2');
		}
		
		/*
		public function testConditionCache():void
		{
			if('1')
			{
				if('1')
				{
					trace('definitely 1');
				}
			}
			else
			{
				if('1')
				{
					trace('impossible');
				}
				trace('not 1');
			}
		}
		
		public function testNameResolution():void
		{
			var a:String = mynamespace::test;
			
			(packagename.mynamespace)::test;
		}
		*/
		/*
		internal namespace custom = "http://magicalhobo.com/custom";
		
		public static var publicStaticVar:Boolean;
		protected static var protectedStaticVar:Boolean;
		private static var privateStaticVar:Boolean;
		internal static var internalStaticVar:Boolean;
		custom static var customStaticVar:Boolean;
		*/

		public static function testStrangeLoops():void
		{
			var o:Object = {foo: 'bar', hello: 'world', one: 'one', two: 'two'};
			 
			var v:Array = [];
			for each(v[v.length] in o);
			trace(v);
			 
			var k:Array = [];
			for(k[k.length] in o);
			trace(k);
		}

		public static function testFor():void
		{
			for(var i:uint = 0; i < 10; i++)
			{
				trace(i);
			}
		}
		
		public static function testForIn():void
		{
			var a:Object = {};
			for(var i:String in a)
			{
				trace(i);
			}
		}
		
		public static function testForEachIn():void
		{
			var a:Object = {};
			for each(var i:* in a)
			{
				trace(i);
			}
		}
		
		public static function testInfiniteFor():void
		{
			for(;;)
			{
				trace('infinity!');
			}
		}
		
		public static function testInfiniteWhile():void
		{
			while(true)
			{
				trace('infinity!');
			}
		}
		
		public static function testIfTrue():void
		{
			if(true)
			{
				trace('not infinity!');
			}
		}
		
		public static function testIfElse():void
		{
			if(1)
			{
				trace('1');
			}
			else
			{
				trace('2');
			}
		}
		
		public static function testIfElseIf():void
		{
			if(1)
			{
				trace('1');
			}
			else if(2)
			{
				trace('2');
			}
			else
			{
				trace('3');
			}
		}
		/*
		public static function testSwitch(myArg:uint):void
		{
			switch(1)
			{
				case 1:
					trace('1');
					break;
				case 2:
					trace('2');
					break;
			}
		}
		
		public static function testExternalInterface():void
		{
			ExternalInterface.call('test');
		}
		
		public static function returnBoolean():Boolean
		{
			return true;
		}
		
		public static function returnByte():Number
		{
			return 1;
		}
		
		public static function returnNumber():Number
		{
			return 1000.0001;
		}
		
		public static function returnString():String
		{
			return 'string';;
		}
		
		public static function returnObject():Object
		{
			return {name: 'value'};
		}
		
		public static function returnClosure():Object
		{
			return function():void
			{
				trace('closure');
			}
		}
		
		public static function testThrowError():void
		{
			throw new Error();
		}
		
		public static function testTryFinally():void
		{
			try
			{
				testThrowError();
			}
			finally
			{
				trace('finally!');
			}
		}
		
		public static function testTryCatchFinally():void
		{
			try
			{
				testThrowError();
			}
			catch(e:Error)
			{
				trace('caught: '+e);
			}
			finally
			{
				trace('finally!');
			}
		}
		/*
		public static function publicStaticMethod(param1:String):Boolean
		{
			return true;
		}
		
		protected static function protectedStaticMethod(param1:Number):Boolean
		{
			return true;
		}
		
		private static function privateStaticMethod(param1:Object):Boolean
		{
			return true;
		}
		
		internal static function internalStaticMethod(param1:Object):Boolean
		{
			return true;
		}
		
		custom static function customStaticMethod(param1:Object):Boolean
		{
			return true;
		}
		*/
		/*
		
		public var publicVar:String = 'publicVar';
		protected var protectedVar:String = 'protectedVar';
		private var privateVar:String = 'privateVar';
		internal var internalVar:String = 'internalVar';
		custom var customVar:String = 'customVar';
		
		public function publicMethod(param1:String):Boolean
		{
			return true;
		}
		
		protected function protectedMethod(param1:String):Boolean
		{
			return true;
		}
		
		private function privateMethod(param1:Object):Boolean
		{
			return true;
		}
		
		internal function internalMethod(param1:Object):Boolean
		{
			return true;
		}
		
		custom function customMethod(param1:Object):Boolean
		{
			return true;
		}
		*/
	}
}