package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class ChangeItemCommand extends BaseCommand implements ICommand
	{
		public var tableRow:TableRow;
		public var columnIndex:int;
		public var oldValue:int;
		public var newValue:int;
		
		public function ChangeItemCommand(tableRow:TableRow, columnIndex:int, oldValue:int, newValue:int)
		{
			super();
			
			this.tableRow = tableRow;
			this.columnIndex = columnIndex;
			this.oldValue = oldValue;
			this.newValue = newValue;
			
			description = Texts.commandChangeItem;
			isChangeValueCommand = true;
		}
		
		public function redo():void
		{
			tableRow.data[columnIndex] = newValue;
			tableRow.dispatchChange();
		}
		
		public function undo():void
		{
			tableRow.data[columnIndex] = oldValue;
			tableRow.dispatchChange();
		}
	}
}