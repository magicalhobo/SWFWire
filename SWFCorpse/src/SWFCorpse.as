package
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	import org.osmf.display.ScaleMode;
	
	import packagename.ClassName;
	
	public class SWFCorpse extends Sprite
	{
		internal namespace custom = "http://magicalhobo.com/custom";
		
		public static var publicStaticVar:Boolean;
		protected static var protectedStaticVar:Boolean;
		private static var privateStaticVar:Boolean;
		internal static var internalStaticVar:Boolean;
		custom static var customStaticVar:Boolean;
		
		public function playground():*
		{
			switch(this)
			{
				case 'a':
					return new DisplayObject;
					break;
				default:
					return this;
					break;
			}
		}
		
		public static function testInfiniteFor():void
		{
			for(;;)
			{
				trace('infinity!');
			}
		}
		public static function testInfiniteWhile(arg:Boolean):void
		{
			while(arg)
			{
				trace('infinity!');
			}
		}
		
		public static function testIfTrue(arg:Boolean):void
		{
			if(arg)
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
		
		public static function testSwitch(myArg:uint):void
		{
			switch(myArg)
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
		
		protected function clickHandler(ev:MouseEvent):void
		{
			var rand:Number = Math.random();
			switch(ev.type)
			{
				case MouseEvent.CLICK:
					trace('event was a click');
					break;
				default:
					trace('event was something else');
					break;
			}
		}
		
		private function testAnonymousFunction():void
		{
			function myAnonymousFunction():String
			{
				return 'called';
			}
			myAnonymousFunction();
		}
		
		private function loadCompleteHandler(ev:Event):void
		{
			var ul:URLLoader = ev.currentTarget as URLLoader;
			trace('load complete: '+ul.bytesLoaded);
		}
		
		public function SWFCorpse(param1:Object = null)
		{
			trace('Starting constructor');
			trace('stage: '+stage);
			
			var ur:URLRequest = new URLRequest('http://www.google.com/images/logos/ps_logo2a_cp.png');
			var ul:URLLoader = new URLLoader();
			ul.addEventListener(Event.COMPLETE, loadCompleteHandler);
			ul.load(ur);
			
			trace('FlashVars: ');
			for(var iter:String in loaderInfo.parameters)
			{
				trace('	'+iter+': '+loaderInfo.parameters[iter]);
			}
			trace('---------');
			
			Security.allowDomain('swfwire.com');
			/*
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			trace('Stage is: '+stage.stageWidth+'x'+stage.stageHeight);
			*/
			
			publicMethod('test');
			protectedMethod('test');
			privateMethod('test');
			
			testExternalInterface();
			testAnonymousFunction();
			testTryCatchFinally();
			
			custom::customMethod(null);
			ClassName.staticMethod();
			var t:ClassName = new ClassName();
			t.method();
			
			var shape:Sprite = new Sprite();
			shape.graphics.beginFill(0xFF0000);
			shape.graphics.drawRect(0, 0, 100, 100);
			shape.graphics.endFill();
			addChild(shape);
			shape.addEventListener(MouseEvent.CLICK, clickHandler);
			shape.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			
			trace('Ending constructor');
		}
	}
}