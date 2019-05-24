package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class AddInnerTableRowCommand extends BaseCommand implements ICommand
	{
		public var tableRow:TableRow;
		public var columnIndex:int;
		
		public function AddInnerTableRowCommand(tableRow:TableRow, columnIndex:int)
		{
			super();
			
			this.tableRow = tableRow;
			this.columnIndex = columnIndex;
			
			description = Texts.commandAddInnerTableRow;
		}
		
		public function redo():void
		{
			var data:Vector.<Array> = tableRow.data[columnIndex];
			
			var meta:TableMeta = Main.instance.rootTable.cache.getTableById(tableRow.parent.meta.allColumns[columnIndex].metaId).meta;
			
			var newRowData:Array = new Array(meta.columns.length - Hardcode.INNER_TABLE_SKIP_ID);
			for (var i:int = Hardcode.INNER_TABLE_SKIP_ID; i < meta.columns.length; i++)
			{
				newRowData[i - Hardcode.INNER_TABLE_SKIP_ID] = ParseUtils.readValue(meta.columns[i].defaultValue, meta.columns[i].type);
			}
			
			data.push(newRowData);
			
			tableRow.dispatchChange();
		}
		
		public function undo():void
		{
			var data:Vector.<Array> = tableRow.data[columnIndex];
			
			data.pop();
			
			tableRow.dispatchChange();
		}
	}
}