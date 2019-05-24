package ru.kennel32.editor.data.table 
{
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.data.table.BaseTable;
	public class Counter extends TableRow
	{
		public static const TABLES:int				= 1;
		public static const COUNTERS:int			= 2;
		public static const LOCALIZATION:int		= 3;
		public static const PROJECT_SETTINGS:int	= 4;
		
		public function Counter(parent:BaseTable)
		{
			super(parent);
		}
		
		public function getNextIndex(offset:int = 1):int
		{
			return _data[2] + offset;
		}
		
		public function moveIndex(value:int = 1):void
		{
			_data[2] = int(_data[2]) + value;
			dispatchChange();
		}
		
		override public function get isSystem():Boolean 
		{
			return Hardcode.isSystemCounter(this);
		}
		
		override public function get allowForUseinSelectItem():Boolean 
		{
			return id == LOCALIZATION || super.allowForUseinSelectItem;	//hardcode. allow to choose localization from the list
		}
	}
}