package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class ChangeStringValueCommand extends BaseCommand implements ICommand
	{
		public var tableRow:TableRow;
		public var columnIndex:int;
		public var oldValue:String;
		public var newValue:String;
		
		public function ChangeStringValueCommand(tableRow:TableRow, columnIndex:int, oldValue:String, newValue:String)
		{
			super();
			
			this.tableRow = tableRow;
			this.columnIndex = columnIndex;
			this.oldValue = oldValue;
			this.newValue = newValue;
			
			description = Texts.commandChangeNumberValue;
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