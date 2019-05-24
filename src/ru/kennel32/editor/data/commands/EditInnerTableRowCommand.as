package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class EditInnerTableRowCommand extends BaseCommand implements ICommand
	{
		public var tableRow:TableRow;
		public var columnIndex:int;
		
		public var innerRowIndex:int;
		public var innerColumnIndex:int;
		public var oldValue:*;
		public var newValue:*;
		
		public function EditInnerTableRowCommand(tableRow:TableRow, columnIndex:int, innerRowIndex:int, innerColumnIndex:int, newValue:*)
		{
			super();
			
			this.tableRow = tableRow;
			this.columnIndex = columnIndex;
			
			this.innerRowIndex = innerRowIndex;
			this.innerColumnIndex = innerColumnIndex;
			this.newValue = newValue;
			
			var data:Vector.<Array> = tableRow.data[columnIndex];
			
			oldValue = data[innerRowIndex][innerColumnIndex];
			
			description = Texts.commandEditInnerTableRow;
		}
		
		public function redo():void
		{
			var data:Vector.<Array> = tableRow.data[columnIndex];
			
			data[innerRowIndex][innerColumnIndex] = newValue;
			
			tableRow.dispatchChange();
		}
		
		public function undo():void
		{
			var data:Vector.<Array> = tableRow.data[columnIndex];
			
			data[innerRowIndex][innerColumnIndex] = oldValue;
			
			tableRow.dispatchChange();
		}
	}
}