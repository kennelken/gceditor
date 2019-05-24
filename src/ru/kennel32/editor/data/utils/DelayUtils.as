package ru.kennel32.editor.data.utils 
{
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class DelayUtils
	{
		private static var _list:Dictionary = new Dictionary();
		
		public static function execute(func:Function, delay:Number, updateTimer:Boolean = false, params:Array = null):void
		{
			if (_list[func] != null)
			{
				var entry:DelayUtilsEntry = _list[func] as DelayUtilsEntry;
				entry.params = params;
				
				if (!updateTimer)
				{
					return;
				}
			}
			
			if (entry != null)
			{
				clearTimeout(entry.timer);
			}
			else
			{
				entry = new DelayUtilsEntry();
				entry.func = func;
				entry.params = params;
			}
			
			_list[entry.func] = entry;
			entry.timer = setTimeout(doExecute, delay, entry);
		}
		
		private static function doExecute(entry:DelayUtilsEntry):void
		{
			delete _list[entry.func];
			
			entry.func.apply(entry.params);
		}
	}
}


internal class DelayUtilsEntry
{
	public var func:Function;
	public var params:Array;
	
	public var timer:uint;
}