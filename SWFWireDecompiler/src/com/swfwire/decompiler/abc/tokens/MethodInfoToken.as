package com.swfwire.decompiler.abc.tokens
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	
	public class MethodInfoToken implements IToken
	{
		public static const FLAG_NEED_ARGUMENTS:uint	 = 1 << 0;
		public static const FLAG_NEED_ACTIVATION:uint	 = 1 << 1;
		public static const FLAG_NEED_REST:uint			 = 1 << 2;
		public static const FLAG_HAS_OPTIONAL:uint		 = 1 << 3;
		public static const FLAG_SET_DXNS:uint			 = 1 << 6;
		public static const FLAG_HAS_PARAM_NAMES:uint	 = 1 << 7;
		
		public var paramCount:uint;
		public var returnType:uint;
		public var paramTypes:Vector.<uint>;
		public var name:uint;
		public var flags:uint;
		public var options:OptionInfoToken;
		public var paramNames:Vector.<ParamInfoToken>;

		public function MethodInfoToken(paramCount:uint = 0, returnType:uint = 0, paramTypes:Vector.<uint> = null, name:uint = 0, flags:uint = 0, options:OptionInfoToken = null, paramNames:Vector.<ParamInfoToken> = null)
		{
			if(paramTypes == null)
			{
				paramTypes = new Vector.<uint>();
			}
			if(options == null)
			{
				options = new OptionInfoToken();
			}
			if(paramNames == null)
			{
				paramNames = new Vector.<ParamInfoToken>();
			}

			this.paramCount = paramCount;
			this.returnType = returnType;
			this.paramTypes = paramTypes;
			this.name = name;
			this.flags = flags;
			this.options = options;
			this.paramNames = paramNames;
		}
		
		public function read(abc:ABCByteArray):void
		{
			var iter:uint;
			
			paramCount = abc.readU30();
			returnType = abc.readU30();
			paramTypes = new Vector.<uint>(paramCount);
			for(iter = 0; iter < paramCount; iter++)
			{
				paramTypes[iter] = abc.readU30();
			}
			name = abc.readU30();
			flags = abc.readU8();
			options = new OptionInfoToken();
			if(flags & FLAG_HAS_OPTIONAL)
			{
				options.read(abc);
			}
			paramNames = new Vector.<ParamInfoToken>(paramCount);
			if(flags & FLAG_HAS_PARAM_NAMES)
			{
				for(iter = 0; iter < paramCount; iter++)
				{
					var paramName:ParamInfoToken = new ParamInfoToken();
					paramName.read(abc);
					paramNames[iter] = paramName;
				}
			}
		}
		public function write(abc:ABCByteArray):void
		{
			var iter:uint;
			
			abc.writeU30(paramTypes.length);
			abc.writeU30(returnType);
			for(iter = 0; iter < paramTypes.length; iter++)
			{
				abc.writeU30(paramTypes[iter]);
			}
			abc.writeU30(name);
			abc.writeU8(flags);
			if(flags & FLAG_HAS_OPTIONAL)
			{
				options.write(abc);
			}
			if(flags & FLAG_HAS_PARAM_NAMES)
			{
				for(iter = 0; iter < paramCount; iter++)
				{
					paramNames[iter].write(abc);
				}
			}
		}
	}
}