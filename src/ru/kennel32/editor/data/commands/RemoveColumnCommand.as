package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.helper.ColumnStoredValues;
	import ru.kennel32.editor.data.utils.Hardcode;
	
	public class RemoveColumnCommand extends BaseCommand implements ICommand
	{
		public var table:BaseTable;
		public var column:TableColumnDescription;
		
		private var _valuesToRestore:ColumnStoredValues;
		private var _index:int;
		
		private var _tablesWithInnerTable:Vector.<DataTable>;
		private var _innerTablesNewValues:ColumnStoredValues;
		private var _innerTablesValuesToRestore:ColumnStoredValues;
		
		public function RemoveColumnCommand(table:BaseTable, column:TableColumnDescription)
		{
			super();
			
			this.table = table;
			this.column = column;
			
			_tablesWithInnerTable = Main.instance.rootTable.cache.getTablesByInnerTableMeta(table.meta.id);
			if (_tablesWithInnerTable.length > 0)
			{
				_innerTablesValuesToRestore = new ColumnStoredValues();
				for each (var tableWithInnerTable:DataTable in _tablesWithInnerTable)
				{
					tableWithInnerTable.getInnerTablesValues(table.meta.id, _innerTablesValuesToRestore);
				}
				
				_innerTablesNewValues = _innerTablesValuesToRestore.clone().doForEveryValue(removeInnerTableColumn, [_index - Hardcode.INNER_TABLE_SKIP_ID]);
			}
			
			_valuesToRestore = table.getTablesRowsValuesByColumn(column);
			_index = table.meta.allColumns.indexOf(column);
			
			description = Texts.commandDeleteColumn;
		}
		
		public function redo():void
		{
			table.removeColumn(column);
			
			for each (var tableWithInnerTable:DataTable in _tablesWithInnerTable)
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
			
			table.addColumnAt(column, _index);
			table.editColumn(column, column, false, _valuesToRestore);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		public function removeInnerTableColumn(src:Vector.<Array>, index:int):Vector.<Array>
		{
			for each (var row:Array in src)
			{
				row.removeAt(index);
			}
			return src;
		}
	}
}