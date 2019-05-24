package ru.kennel32.editor.data.utils
{
	public class DebugUtils
	{
		public static function getObjectId(obj:Object):String
		{
			try
			{
				DummyClass(obj);
			}
			catch (e:Error)
			{
				return obj.toString() + String(e).replace(/.*([@|\$].*?) to .*$/gi, '$1');
			}
			
			return null;
		}
	}
}

internal final class DummyClass { }