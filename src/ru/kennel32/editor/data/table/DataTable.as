package ru.kennel32.editor.data.table
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.helper.ColumnStoredValues;
	import ru.kennel32.editor.data.utils.SortUtils;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	
	public class DataTable extends BaseTable
	{
		public function DataTable(meta:TableMeta)
		{
			super(meta);
			
			_rows = new Vector.<TableRow>();
		}
		
		internal var _rows:Vector.<TableRow>;
		public function get rows():Vector.<TableRow>
		{
			return _rows;
		}
		
		public function addRow(row:TableRow):void
		{
			addRows(Vector.<TableRow>([row]));
		}
		
		public function deleteRow(row:TableRow):void
		{
			deleteRows(Vector.<TableRow>([row]));
		}
		
		public function addRows(rows:Vector.<TableRow>):void
		{
			rows = rows.concat().sort(SortUtils.sortRowsByIndex);
			
			for (var i:int = 0; i < rows.length; i++)
			{
				_rows.splice(rows[i].index, 0, rows[i]);
			}
			updateRowsIndexes();
			
			dispatchEvent(new TableEvent(TableEvent.ROWS_ADDED, this, null, rows));
		}
		
		public function deleteRows(rows:Vector.<TableRow>):void
		{
			rows = rows.concat().sort(SortUtils.sortRowsByIndex).reverse();
			
			for (var i:int = 0; i < rows.length; i++)
			{
				_rows.splice(_rows.indexOf(rows[i]), 1);
			}
			updateRowsIndexes();
			
			dispatchEvent(new TableEvent(TableEvent.ROWS_DELETED, this, null, rows));
		}
		
		private function updateRowsIndexes():void
		{
			for (var i:int = 0; i < _rows.length; i++)
			{
				_rows[i].index = i;
			}
		}
		
		public function createNewRow(indexOffset:int = 1):TableRow
		{
			var res:TableRow = (this == Main.instance.rootTable.cache.countersTable) ? new Counter(this) : new TableRow(this);
			
			var data:Array = new Array();
			
			for (var i:int = 0; i < _meta.allColumns.length; i++)
			{
				var column:TableColumnDescription = _meta.allColumns[i];
				var type:int = column.type;
				switch (type)
				{
					case TableColumnDescriptionType.ID:
						data[i] = Main.instance.rootTable.cache.getCounterById(_meta.counterId).getNextIndex(indexOffset);
						break;
					
					default:
						data[i] = column.defaultValue;
						break;
				}
			}
			
			res.index = _rows.length - 1 + indexOffset;
			res.decode(data);
			
			return res;
		}
		
		override protected function onColumnAdded(column:TableColumnDescription, index:int):void 
		{
			super.onColumnAdded(column, index);
			
			for (var i:int = 0; i < _rows.length; i++)
			{
				_rows[i].onColumnAdded(index);
			}
		}
		
		override protected function onColumnRemoved(column:TableColumnDescription, index:int):void 
		{
			super.onColumnRemoved(column, index);
			
			for (var i:int = 0; i < _rows.length; i++)
			{
				_rows[i].onColumnRemoved(index);
			}
		}
		
		override protected function onColumnMoved(column:TableColumnDescription, oldIndex:int, newIndex:int):void 
		{
			super.onColumnMoved(column, oldIndex, newIndex);
			
			for (var i:int = 0; i < _rows.length; i++)
			{
				_rows[i].onColumnMoved(oldIndex, newIndex);
			}
		}
		
		override protected function onColumnChanged(column:TableColumnDescription, index:int, typeChanged:Boolean, valuesToSet:ColumnStoredValues = null):void 
		{
			super.onColumnChanged(column, index, typeChanged);
			
			for (var i:int = 0; i < _rows.length; i++)
			{
				var value:Object = valuesToSet == null ? null : valuesToSet.getValuesForTable(_meta.id, index)[i];
				_rows[i].onColumnChanged(index, typeChanged, value);
			}
		}
		
		override public function getTablesRowsValuesByColumn(column:TableColumnDescription, values:ColumnStoredValues = null):ColumnStoredValues 
		{
			values = super.getTablesRowsValuesByColumn(column, values);
			
			var columnIndex:int = _meta.allColumns.indexOf(column);
			
			var list:Vector.<Object> = values.getValuesForTable(_meta.id, columnIndex);
			
			for (var i:int = 0; i < _rows.length; i++)
			{
				list.push(_rows[i].data[columnIndex]);
			}
			
			return values;
		}
		
		public function updateInnerTablesAfterMetaChanged(metaId:uint, values:ColumnStoredValues):void
		{
			for (var i:int = 0; i < meta.allColumns.length; i++)
			{
				var column:TableColumnDescription = meta.allColumns[i];
				
				if (column.metaId == metaId)
				{
					for (var j:int = 0; j < rows.length; j++)
					{
						rows[j].data[i] = values.getValuesForTable(meta.id, i, false)[j];
					}
				}
			}
		}
		
		public function getInnerTablesValues(metaId:uint, values:ColumnStoredValues):void
		{
			for (var i:int = 0; i < meta.allColumns.length; i++)
			{
				var column:TableColumnDescription = meta.allColumns[i];
				
				if (column.metaId == metaId)
				{
					for each (var row:TableRow in rows)
					{
						var value:Vector.<Array> = row.data[i];
						
						var list:Vector.<Object> = values.getValuesForTable(meta.id, i, true);
						list.push(value);
					}
				}
			}
		}
	}
}