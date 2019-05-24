package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.helper.ColumnStoredValues;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class EditColumnCommand extends BaseCommand implements ICommand
	{
		public var table:BaseTable;
		public var column:TableColumnDescription;
		public var oldColumn:TableColumnDescription;
		
		private var _oldColumnCopy:TableColumnDescription;
		private var _valuesToRestore:ColumnStoredValues;
		
		private var _tablesWithInnerTable:Vector.<DataTable>;
		private var _innerTablesNewValues:ColumnStoredValues;
		private var _innerTablesValuesToRestore:ColumnStoredValues;
		
		public function EditColumnCommand(table:BaseTable, column:TableColumnDescription, oldColumn:TableColumnDescription)
		{
			super();
			
			this.table = table;
			this.column = column;
			this.oldColumn = oldColumn;
			
			_oldColumnCopy = new TableColumnDescription();
			_oldColumnCopy.copyFrom(oldColumn);
			
			_valuesToRestore = table.getTablesRowsValuesByColumn(oldColumn);
			
			_tablesWithInnerTable = Main.instance.rootTable.cache.getTablesByInnerTableMeta(table.meta.id);
			if (_tablesWithInnerTable.length > 0 && column.type != oldColumn.type)
			{
				_innerTablesValuesToRestore = new ColumnStoredValues();
				for each (var tableWithInnerTable:DataTable in _tablesWithInnerTable)
				{
					tableWithInnerTable.getInnerTablesValues(table.meta.id, _innerTablesValuesToRestore);
				}
				
				_innerTablesNewValues = _innerTablesValuesToRestore.clone().doForEveryValue(setDefaultValueForInnerTableColumn, [table.meta.columns.indexOf(oldColumn) - Hardcode.INNER_TABLE_SKIP_ID, ParseUtils.readValue(column.defaultValue, column.type)]);
			}
			
			description = Texts.commandEditColumn;
		}
		
		public function redo():void
		{
			if (oldColumn.type != column.type)
			{
				var convertedValues:ColumnStoredValues = convertValuesIfPossible(_valuesToRestore.clone(), column.type, oldColumn.type);
			}
			
			table.editColumn(oldColumn, column, oldColumn.type != column.type, convertedValues);
			
			if (_innerTablesNewValues != null)
			{
				for each (var tableWithInnerTable:DataTable in _tablesWithInnerTable)
				{
					tableWithInnerTable.updateInnerTablesAfterMetaChanged(table.meta.id, _innerTablesNewValues);
				}
			}
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		public function undo():void
		{
			for each (var tableWithInnerTable:DataTable in _tablesWithInnerTable)
			{
				tableWithInnerTable.updateInnerTablesAfterMetaChanged(table.meta.id, _innerTablesValuesToRestore);
			}
			
			table.editColumn(oldColumn, _oldColumnCopy, _oldColumnCopy.type != oldColumn.type, _valuesToRestore);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		private function setDefaultValueForInnerTableColumn(src:Vector.<Array>, index:int, value:*):Vector.<Array>
		{
			for each (var row:Array in src)
			{
				row[index] = value;
			}
			return src;
		}
		
		private function convertValuesIfPossible(values:ColumnStoredValues, newType:int, oldType:int):ColumnStoredValues
		{
			switch (newType)
			{
				case TableColumnDescriptionType.STRING_VALUE:
					switch (oldType)
					{
						case TableColumnDescriptionType.STRING_MULTILINE:
							return values.doForEveryValue(multilineStringToString);
						
						case TableColumnDescriptionType.BOOL_VALUE:
							return values.doForEveryValue(boolToString);
						
						case TableColumnDescriptionType.COUNTER:
						case TableColumnDescriptionType.DATE:
						case TableColumnDescriptionType.FLOAT_VALUE:
						case TableColumnDescriptionType.ID:
						case TableColumnDescriptionType.INT_VALUE:
						case TableColumnDescriptionType.SELECT_SINGLE_ID:
						case TableColumnDescriptionType.STRING_VALUE:
							return values.doForEveryValue(simpleToString);
					}
					break;
				
				case TableColumnDescriptionType.STRING_MULTILINE:
					switch (oldType)
					{
						case TableColumnDescriptionType.BOOL_VALUE:
							return values.doForEveryValue(boolToString);
						
						case TableColumnDescriptionType.COUNTER:
						case TableColumnDescriptionType.DATE:
						case TableColumnDescriptionType.FLOAT_VALUE:
						case TableColumnDescriptionType.ID:
						case TableColumnDescriptionType.INT_VALUE:
						case TableColumnDescriptionType.SELECT_SINGLE_ID:
						case TableColumnDescriptionType.STRING_VALUE:
						case TableColumnDescriptionType.STRING_MULTILINE:
							return values.doForEveryValue(simpleToString);
					}
					break;
				
				case TableColumnDescriptionType.INT_VALUE:
					switch (oldType)
					{
						case TableColumnDescriptionType.BOOL_VALUE:
							return values.doForEveryValue(boolToInt);
						
						case TableColumnDescriptionType.STRING_MULTILINE:
						case TableColumnDescriptionType.STRING_VALUE:
							return values.doForEveryValue(stringToInt);
						
						case TableColumnDescriptionType.FLOAT_VALUE:
							return values.doForEveryValue(floatToInt);
							
						case TableColumnDescriptionType.ID:
						case TableColumnDescriptionType.INT_VALUE:
						case TableColumnDescriptionType.SELECT_SINGLE_ID:
						case TableColumnDescriptionType.COUNTER:
						case TableColumnDescriptionType.DATE:
							return values.doForEveryValue(simpleToInt);
					}
					break;
				
				case TableColumnDescriptionType.FLOAT_VALUE:
					switch (oldType)
					{
						case TableColumnDescriptionType.BOOL_VALUE:
							return values.doForEveryValue(boolToFloat);
						
						case TableColumnDescriptionType.STRING_MULTILINE:
						case TableColumnDescriptionType.STRING_VALUE:
							return values.doForEveryValue(stringToFloat);
						
						case TableColumnDescriptionType.ID:
						case TableColumnDescriptionType.INT_VALUE:
						case TableColumnDescriptionType.SELECT_SINGLE_ID:
						case TableColumnDescriptionType.COUNTER:
						case TableColumnDescriptionType.DATE:
							return values.doForEveryValue(simpleToFloat);
					}
					break;
				
				case TableColumnDescriptionType.BOOL_VALUE:
					switch (oldType)
					{
						case TableColumnDescriptionType.BOOL_VALUE:
						case TableColumnDescriptionType.STRING_MULTILINE:
						case TableColumnDescriptionType.STRING_VALUE:
						case TableColumnDescriptionType.INT_VALUE:
						case TableColumnDescriptionType.ID:
							return values.doForEveryValue(anyToBool);
					}
					break;
			}
			
			return null;
		}
		
		private function simpleToString(src:*):String
		{
			return src == null ? '' : src.toString();
		}
		private function boolToString(src:Boolean):String
		{
			return src ? 'true' : 'false';
		}
		private function boolToInt(src:Boolean):int
		{
			return src ? 1 : 0;
		}
		private function boolToFloat(src:Boolean):Number
		{
			return src ? 1 : 0;
		}
		private function stringToInt(src:String):int
		{
			return parseInt(src);
		}
		private function stringToFloat(src:String):Number
		{
			return parseFloat(src);
		}
		private function floatToInt(src:Number):int
		{
			return int(src);
		}
		private function simpleToInt(src:*):int
		{
			return int(src);
		}
		private function simpleToFloat(src:*):Number
		{
			return Number(src);
		}
		private function anyToBool(src:*):Boolean
		{
			return src == 'true' || src == 1 || src == '1' || (src is Boolean && src);
		}
		private function multilineStringToString(src:String):String
		{
			while (src.indexOf("\n") > 0)
			{
				src = src.replace("\n", " ");
			}
			while (src.indexOf("\r") > 0)
			{
				src = src.replace("\r", " ");
			}
			return src;
		}
	}
}