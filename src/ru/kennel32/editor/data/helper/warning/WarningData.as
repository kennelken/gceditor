package ru.kennel32.editor.data.helper.warning
{
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class WarningData
	{
		public var type:WarningType;
		public var row:TableRow;
		public var column:TableColumnDescription;
		public var table:BaseTable;
		
		public function WarningData(type:WarningType, table:BaseTable, column:TableColumnDescription, row:TableRow = null)
		{
			this.type = type;
			this.row = row;
			this.column = column;
			this.table = table;
		}
	}
}