package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class DeleteInnerTableRowCommand extends BaseCommand implements ICommand
	{
		public var tableRow:TableRow;
		public var columnIndex:int;
		public var rowIndex:int;
		
		public var rowData:Array;
		
		public function DeleteInnerTableRowCommand(tableRow:TableRow, columnIndex:int, rowIndex:int)
		{
			super();
			
			this.tableRow = tableRow;
			this.columnIndex = columnIndex;
			this.rowIndex = rowIndex;
			
			rowData = tableRow.data[columnIndex][rowIndex];
			
			description = Texts.commandDeleteInnerTableRow;
		}
		
		public function redo():void
		{
			var data:Vector.<Array> = tableRow.data[columnIndex];
			
			data.splice(rowIndex, 1);
			
			tableRow.dispatchChange();
		}
		
		public function undo():void
		{
			var data:Vector.<Array> = tableRow.data[columnIndex];
			
			data.splice(rowIndex, 0, rowData);
			
			tableRow.dispatchChange();
		}
	}
}