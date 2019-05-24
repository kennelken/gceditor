package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class DeselectRowCommand extends BaseCommand implements ICommand
	{
		public var tableRow:TableRow;
		public var table:BaseTable;
		public var oldValue:Boolean;
		
		public function DeselectRowCommand(tableRow:TableRow, table:BaseTable, oldValue:Boolean)
		{
			super();
			
			this.tableRow = tableRow;
			this.table = table;
			this.oldValue = oldValue;
			
			description = Texts.commandDeselectRow;
		}
		
		public function redo():void
		{
			if (tableRow != null)
			{
				tableRow.checked = false;
			}
			else
			{
				table.checked = false;
			}
		}
		
		public function undo():void
		{
			if (tableRow != null)
			{
				tableRow.checked = oldValue;
			}
			else
			{
				table.checked = oldValue;
			}
		}
		
		override public function get isImportant():Boolean
		{
			return false;
		}
	}
}