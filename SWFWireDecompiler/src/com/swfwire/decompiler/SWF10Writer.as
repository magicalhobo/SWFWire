package com.swfwire.decompiler
{
	public class SWF10Writer extends SWF9Writer
	{
		private static var FILE_VERSION:uint = 10;
		
		public function SWF10Writer()
		{
			version = FILE_VERSION;
		}
	}
}