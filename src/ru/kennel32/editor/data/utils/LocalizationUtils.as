package ru.kennel32.editor.data.utils
{
	public class LocalizationUtils
	{
		public static function getKey(pattern:String, id:uint):String
		{
			return pattern + id;
		}
	}
}