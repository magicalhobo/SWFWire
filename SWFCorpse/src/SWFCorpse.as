package
{
	import com.swfwire.utils.ObjectUtil;
	
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
	import packagename.IEmpty;
	import packagename.mynamespace;
	
	public class SWFCorpse extends Sprite implements IEmpty
	{
		public function notEmptyAnyMore(bitches:*):void
		{
			return;
		}
		/*
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
		
		public static function testFor():void
		{
			for(var i:uint = 0; i < 10; i++)
			{
				nothing();
			}
		}
		
		public static function testForIn():void
		{
			var b:Object = {};
			for(var i:String in b)
			{
				nothing();
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
		
		private static function nothing():void
		{
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
		*/
		/*
		public static var delegates:Object;
		public static function check(... args):*
		{
			var vec:Vector.<Object> = new Vector.<Object>;
			return;
		}
		
		public static function create(target:Object, handlerFunction:Function, shouldAppend:Boolean = true, ... args) : Function
		{
			var oTarget:Object;
			var oFunction:Function;
			var oAppend:Boolean = true;
			var oArgs:Array;
			var f:Function;
			var oParams:Array;
			var i:int;
			var d:Dictionary;
			
			var loc1:*;
			oTarget = target;
			oFunction = handlerFunction;
			oAppend = shouldAppend;
			
			f = check(oTarget, oFunction, oAppend, oArgs); //check() returns null if conditions not satisfied
			if(f != null) {
				return f;
			}
			
			oParams = new Array();
			
			while((i = 0) < oArgs.length) {
				oParams.push(oArgs[i++]);
			}
			
			d = new Dictionary(true);
			d["oTarget"] = oTarget;
			d["oParams"] = oParams;
			d["oFunction"] = oFunction;
			d["appendParams"] = oAppend;
			d["dFunction"] = function():* {
				var loc1:* = arguments.callee.delegate;
				
				return loc1["oFunction"].apply(loc1["oTarget"], loc1["appendParams"] ? (arguments.concat(loc1["oParams"])) : (loc1["oParams"]));
			}
			
			d["dFunction"].delegate = d;
			delegates.push(d); //delegates is a field variable -- class variable
			return d["dFunction"];
			
		}
		
		private var i:int = 55;
		private var j:int = 6;
		private var k:int = 1;
		
		public function decrement():void
		{
			trace("i-- is as follows");
			i--;
			trace("i-- complete");
			trace("--j is as follows");
			--j;
			trace("Other syntax for testing:\n i = i - 1");
			i = i - 1;
			trace("j -= 1");
			j -= 1;
			trace("subtracting i from a variable that is 1");
			i -= k;
			
			
		}
		*/
		
		public var vec:Vector.<DisplayObject>;
		
		override public function get x():Number
		{
			return super.x;
		}
		
		override public function set x(value:Number):void
		{
			//pass
			super.x = value;
		}
		
		private namespace irock = "http://magicalhobo.com";
		
		irock static var wtf2:String = 'omg';
		
		irock var wtf:String = "hell yes";
		
		mynamespace var test:String = 'hell yes2';
		
		public function SWFCorpse(obj:Object = null)
		{
			var n:Boolean = 1 == 1 || 2 == 2;
			
			if(1)
			{
				boolean = true;
			}
			else
			{
				var boolean:Boolean = false;
			}
			
			trace(boolean);
			
			if(obj == 1 || obj == 2 || obj == 3)
			{
				trace('1 or 2');
			}
			trace('3');
			
			
			/*
			vec = new Vector.<DisplayObject>();
			
			var a:Number = 1 | 2 & 3;
			var b:Number = 0;
			b |= 1;
			b &= 1;
			b <<= 1;
			b >>= 1;
			b >>>= 1;
			b = 1 << 2;
			b = 1 >> 2;
			b = 1 >>> 2;
			b = b ^ 1;
			b = ~b;
			
			if(obj.prop === 1)
			{
				trace('hell strict yes');
			}
			
			/*
			if(obj.prop == 1 || obj.prop == 2)
			{
				trace('if 1');
			}
			else
			{
				trace('else 1');
			}
			
			if(obj.prop == 1 || obj.prop == 2)
			{
				trace('if 2');
			}
			else
			{
				trace('else 2');
			}
			
			getTimer();
			getTimer();
			getTimer();
			
			/*
			for(var iter:String in loaderInfo.parameters)
			{
				trace(iter+': '+loaderInfo.parameters[iter]);
			}
			trace('Starting constructor');
			trace('stage: '+stage);
			
			var ur:URLRequest = new URLRequest('http://www.google.com/images/logos/ps_logo2a_cp.png');
			var ul:URLLoader = new URLLoader();
			ul.addEventListener(Event.COMPLETE, loadCompleteHandler);
			ul.load(ur);
			
			var nc:NetConnection = new NetConnection();
			nc.connect('rtmp://localhost');
			
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
			* /
			
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
			*/
		}
	}
}