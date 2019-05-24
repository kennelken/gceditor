package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.utils.Hardcode;
	
	public class DeleteRowsCommand extends BaseCommand implements ICommand
	{
		public var table:DataTable;
		public var tableRows:Vector.<TableRow>;
		
		private var _movedIndexBy:int;
		
		public function DeleteRowsCommand(table:DataTable, tableRows:Vector.<TableRow>)
		{
			super();
			
			this.table = table;
			this.tableRows = tableRows;
			
			description = Texts.commandDeleteRows;
		}
		
		public function redo():void
		{
			if (Hardcode.isLockedData(table.meta))
			{
				return;
			}
			
			table.deleteRows(tableRows);
			
			var allTablesByCounter:Vector.<BaseTable> = Main.instance.rootTable.cache.getTablesByCounterId(table.meta.counterId);
			var maxId:int = 0;
			for each (var t:BaseTable in allTablesByCounter)
			{
				var dataTable:DataTable = t as DataTable;
				if (dataTable != null)
				{
					var lastRow:TableRow = dataTable.rows.length <= 0 ? null : dataTable.rows[dataTable.rows.length - 1];
					if (lastRow != null)
					{
						maxId = Math.max(maxId, lastRow.id);
					}
				}
			}
			
			var counter:Counter = Main.instance.rootTable.cache.getCounterById(table.meta.counterId);
			_movedIndexBy = Math.min(0, maxId - counter.getNextIndex(0));
			if (_movedIndexBy <= 0)
			{
				counter.moveIndex(_movedIndexBy);
			}
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		public function undo():void
		{
			if (Hardcode.isLockedData(table.meta))
			{
				return;
			}
			
			table.addRows(tableRows);
			
			if (_movedIndexBy <= 0)
			{
				var counter:Counter = Main.instance.rootTable.cache.getCounterById(table.meta.counterId);
				counter.moveIndex(-_movedIndexBy);
			}
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
	}
}