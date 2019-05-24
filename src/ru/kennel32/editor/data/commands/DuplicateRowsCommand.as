package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class DuplicateRowsCommand extends BaseCommand implements ICommand
	{
		public var table:DataTable;
		public var tableRows:Vector.<TableRow>;
		public var newRows:Vector.<TableRow>;
		
		public function DuplicateRowsCommand(table:DataTable, tableRows:Vector.<TableRow>)
		{
			super();
			
			this.table = table;
			
			var counter:Counter = Main.instance.rootTable.cache.getCounterById(table.meta.counterId);
			
			this.tableRows = tableRows;
			
			newRows = new Vector.<TableRow>();
			for (var i:int = 0; i < tableRows.length; i++)
			{
				var newRow:TableRow = table.createNewRow(1 + i);
				newRows.push(newRow);
				
				var data:Array = new Array(tableRows[i].data.length);
				for (var j:int = 0; j < tableRows[i].data.length; j++)
				{
					var type:int = table.meta.allColumns[j].type;
					switch (type)
					{
						case TableColumnDescriptionType.ID:
							data[j] = counter.getNextIndex(1 + i);
							break;
						
						default:
							data[j] = ParseUtils.writeValue(tableRows[i].data[j], type);
							break;
					}
				}
				newRow.decode(data);
			}
			
			description = Texts.commandDuplicateRows;
		}
		
		public function redo():void
		{
			if (Hardcode.isLockedData(table.meta))
			{
				return;
			}
			
			table.addRows(newRows);
			
			for each (var oldRow:TableRow in tableRows)
			{
				oldRow.checked = false;
			}
			
			var counter:Counter = Main.instance.rootTable.cache.getCounterById(table.meta.counterId);
			counter.moveIndex(newRows.length);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		public function undo():void
		{
			if (Hardcode.isLockedData(table.meta))
			{
				return;
			}
			
			table.deleteRows(newRows);
			
			for each (var oldRow:TableRow in tableRows)
			{
				oldRow.checked = true;
			}
			
			var counter:Counter = Main.instance.rootTable.cache.getCounterById(table.meta.counterId);
			counter.moveIndex(-newRows.length);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
	}
}