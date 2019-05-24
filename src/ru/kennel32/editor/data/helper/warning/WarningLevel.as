package ru.kennel32.editor.data.helper.warning
{
	public class WarningLevel
	{
		public static const MESSAGE:WarningLevel		= new WarningLevel(0);
		public static const WARNING:WarningLevel		= new WarningLevel(1);
		public static const ERROR:WarningLevel			= new WarningLevel(2);
		
		public static const ALL:Vector.<WarningLevel> = Vector.<WarningLevel>([ERROR, WARNING, MESSAGE]);
		
		public var value:int;
		public function WarningLevel(level:int)
		{
			this.value = value;
		}
	}
}