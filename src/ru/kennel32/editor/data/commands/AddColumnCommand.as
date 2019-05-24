package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.helper.ColumnStoredValues;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class AddColumnCommand extends BaseCommand implements ICommand
	{
		public var table:BaseTable;
		public var column:TableColumnDescription;
		
		private var _tablesWithInnerTable:Vector.<DataTable>;
		private var _innerTablesNewValues:ColumnStoredValues;
		private var _innerTablesValuesToRestore:ColumnStoredValues;
		
		public function AddColumnCommand(table:BaseTable, column:TableColumnDescription)
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
				_innerTablesNewValues = _innerTablesValuesToRestore.clone().doForEveryValue(addDefaultValueToTheEnd, [ParseUtils.readValue(column.defaultValue, column.type)]);
			}
			
			description = Texts.commandAddColumn;
		}
		
		public function redo():void
		{
			table.addColumnAt(column);
			
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
			
			table.removeColumn(column);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		private function addDefaultValueToTheEnd(src:Vector.<Array>, value:*):Vector.<Array>
		{
			for each (var row:Array in src)
			{
				row.push(value);
			}
			return src;
		}
	}
}