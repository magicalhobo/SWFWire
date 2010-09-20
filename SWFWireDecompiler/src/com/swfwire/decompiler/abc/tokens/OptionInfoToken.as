package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class OptionInfoToken implements IToken
	{
		public var optionCount:uint;
		public var options:Vector.<OptionDetailToken>;

		public function OptionInfoToken(optionCount:uint = 0, options:Vector.<OptionDetailToken> = null)
		{
			if(options == null)
			{
				options = new Vector.<OptionDetailToken>();
			}

			this.optionCount = optionCount;
			this.options = options;
		}
		
		public function read(abc:ABCByteArray):void
		{
			optionCount = abc.readU30();
			options = new Vector.<OptionDetailToken>(optionCount);
			for(var iter:uint = 0; iter < optionCount; iter++)
			{
				var option:OptionDetailToken = new OptionDetailToken();
				option.read(abc);
				options[iter] = option;
			}
		}
		public function write(abc:ABCByteArray):void
		{
			abc.writeU30(options.length);
			for(var iter:uint = 0; iter < options.length; iter++)
			{
				options[iter].write(abc);
			}
		}
	}
}