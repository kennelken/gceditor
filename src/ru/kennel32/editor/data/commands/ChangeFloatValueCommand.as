package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class ChangeFloatValueCommand extends BaseCommand implements ICommand
	{
		public var tableRow:TableRow;
		public var columnIndex:int;
		public var oldValue:Number;
		public var newValue:Number;
		
		public function ChangeFloatValueCommand(tableRow:TableRow, columnIndex:int, oldValue:Number, newValue:Number)
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