package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.helper.ColumnStoredValues;
	import ru.kennel32.editor.data.utils.Hardcode;
	
	public class MoveColumnCommand extends BaseCommand implements ICommand
	{
		public var table:BaseTable;
		public var column:TableColumnDescription;
		public var newIndex:int;
		
		private var _oldIndex:int;
		
		private var _tablesWithInnerTable:Vector.<DataTable>;
		private var _innerTablesNewValues:ColumnStoredValues;
		private var _innerTablesValuesToRestore:ColumnStoredValues;
		
		public function MoveColumnCommand(table:BaseTable, column:TableColumnDescription, newIndex:int)
		{
			super();
			
			this.table = table;
			this.column = column;
			this.newIndex = newIndex;
			
			_oldIndex = -1;
			
			description = Texts.commandMoveColumn;
		}
		
		public function redo():void
		{
			if (!check())
			{
				throw new Error("Invalid command data");
			}
			
			if (_oldIndex <= -1)
			{
				_oldIndex = table.meta.allColumns.indexOf(column);
				

				_tablesWithInnerTable = Main.instance.rootTable.cache.getTablesByInnerTableMeta(table.meta.id);
				if (_tablesWithInnerTable.length > 0)
				{
					_innerTablesValuesToRestore = new ColumnStoredValues();
					for each (var tableWithInnerTable:DataTable in _tablesWithInnerTable)
					{
						tableWithInnerTable.getInnerTablesValues(table.meta.id, _innerTablesValuesToRestore);
					}
					
					_innerTablesNewValues = _innerTablesValuesToRestore.clone().doForEveryValue(moveInnerTableColumn, [_oldIndex - Hardcode.INNER_TABLE_SKIP_ID, newIndex - Hardcode.INNER_TABLE_SKIP_ID]);
				}
			}
			
			table.moveColumn(column, newIndex);
			
			for each (tableWithInnerTable in _tablesWithInnerTable)
			{
				tableWithInnerTable.updateInnerTablesAfterMetaChanged(table.meta.id, _innerTablesNewValues);
			}
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		public function undo():void
		{
			for each (var tableWithInnerTable:DataTable in _tablesWithInnerTable)
			{
				tableWithInnerTable.updateInnerTablesAfterMetaChanged(table.meta.id, _innerTablesValuesToRestore);
			}
			
			table.moveColumn(column, _oldIndex);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		public function moveInnerTableColumn(src:Vector.<Array>, oldIndex:int, newIndex:int):Vector.<Array>
		{
			for each (var row:Array in src)
			{
				var value:* = row[oldIndex];
				row.splice(oldIndex, 1);
				row.splice(newIndex, 0, value);
			}
			return src;
		}
		
		public function check():Boolean
		{
			var oldIndex:int = table.meta.allColumns.indexOf(column);
			var minIndex:int = Math.min(oldIndex, newIndex);
			var maxIndex:int = Math.max(oldIndex, newIndex);
			
			if (oldIndex == newIndex)
			{
				return false;
			}
			
			var inheritedLength:int = table.meta.allColumns.length - table.meta.columns.length;
			
			if (minIndex >= inheritedLength &&
				maxIndex < table.meta.allColumns.length)
			{
				for (var i:int = minIndex; i <= maxIndex; i++)
				{
					if (Hardcode.isLockedColumnMeta(table.meta, i))
					{
						return false;
					}
				}
				
				return true;
			}
			
			return false;
		}
	}
}