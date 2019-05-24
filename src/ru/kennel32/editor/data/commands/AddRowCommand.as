package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.utils.Hardcode;
	
	public class AddRowCommand extends BaseCommand implements ICommand
	{
		public var table:DataTable;
		public var tableRow:TableRow;
		
		public function AddRowCommand(table:DataTable, tableRow:TableRow)
		{
			super();
			
			this.table = table;
			this.tableRow = tableRow;
			
			if (table.meta.forInnerTable)
			{
				throw new Error('Can not add row for Inner Table meta');
			}
			
			description = Texts.commandAddRow;
		}
		
		public function redo():void
		{
			if (Hardcode.isLockedData(table.meta))
			{
				return;
			}
			
			table.addRow(tableRow);
			Main.instance.rootTable.cache.getCounterById(table.meta.counterId).moveIndex(1);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		public function undo():void
		{
			if (Hardcode.isLockedData(table.meta))
			{
				return;
			}
			
			table.deleteRow(tableRow);
			Main.instance.rootTable.cache.getCounterById(table.meta.counterId).moveIndex( -1);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
	}
}