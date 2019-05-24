package ru.kennel32.editor.data.utils
{
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class SortUtils
	{
		public static function sortRowsByIndex(a:TableRow, b:TableRow):int
		{
			return a.index - b.index;
		}
		
		public static function sortTablesByIndex(a:BaseTable, b:BaseTable):int
		{
			return a.index - b.index;
		}
	}
}