package ru.kennel32.editor.data.table.find
{
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class FindResultEntry
	{
		public var table:BaseTable;
		public var row:TableRow;
		public var sort:int;
		public var depth:Number;
		public var where:String;
		public var what:String;
		public var rowUsage:TableRow;
		public var whereSelectionStartIndex:int;
		public var whereSelectionEndIndex:int;
		public var groupDescription:String;
		
		public function FindResultEntry(
			table:BaseTable = null,
			row:TableRow = null,
			sort:int = 0,
			depth:Number = 0,
			where:String = null,
			what:String = null,
			rowUsage:TableRow = null,
			whereSelectionStartIndex:int = 0,
			whereSelectionEndIndex:int = 0,
			groupDescription:String = '')
		{
			this.table = table;
			this.row = row;
			this.sort = sort;
			this.depth = depth;
			this.where = where;
			this.what = what;
			this.rowUsage = rowUsage;
			this.whereSelectionStartIndex = whereSelectionStartIndex;
			this.whereSelectionEndIndex = whereSelectionEndIndex;
			this.groupDescription = groupDescription;
		}
	}
}