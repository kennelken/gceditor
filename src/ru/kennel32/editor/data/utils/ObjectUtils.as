package ru.kennel32.editor.data.utils
{
	public class ObjectUtils
	{
		public static function clone(src:Object):Object
		{
			if (isPrimitive(src))
			{
				return src;
			}
			
			if (src is Array)
			{
				var res:Object = (src as Array).concat();
			}
			else if (src is Vector.<Array>)
			{
				res = (src as Vector.<Array>).concat();
			}
			else if (src is Vector.<Object>)
			{
				res = (src as Vector.<Object>).concat();
			}
			
			if (res != null)
			{
				for (var i:int = 0; i < res.length; i++)
				{
					res[i] = clone(res[i]);
				}
				return res;
			}
			
			res = new Object();
			for (var prop:Object in src)
			{
				res[prop] = clone(src[prop]);
			}
			
			return res;
		}
		
		public static function isPrimitive(src:*):Boolean
		{
			return src is int || src is Number || src is Boolean || src is String;
		}
	}
}