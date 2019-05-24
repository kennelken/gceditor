package ru.kennel32.editor.data.table
{
	import flash.events.EventDispatcher;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.helper.ColumnStoredValues;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.utils.Hardcode;
	
	public class BaseTable extends EventDispatcher
	{
		public function BaseTable(meta:TableMeta)
		{
			_meta = meta;
			
			if (Hardcode.isRootMeta(meta))
			{
				_cache = new TablesCache(this);
			}
		}
		
		internal var _cache:TablesCache;
		public function get cache():TablesCache
		{
			return _cache;
		}
		
		internal var _meta:TableMeta;
		public function get meta():TableMeta
		{
			return _meta;
		}
		
		internal var _parent:ContainerTable;
		public function get parent():ContainerTable
		{
			return _parent;
		}
		public function set parent(value:ContainerTable):void
		{
			_parent = value;
		}
		
		private var _checked:Boolean;
		public function get checked():Boolean
		{
			return _checked;
		}
		public function set checked(value:Boolean):void
		{
			if (_checked == value)
			{
				return;
			}
			
			_checked = value;
			
			dispatchEvent(new TableEvent(TableEvent.TABLE_CHECKED_CHANGED, this));
		}
		
		private var _index:int;
		public function get index():int
		{
			return _index;
		}
		public function set index(value:int):void
		{
			_index = value;
		}
		
		public function copyMetaFrom(meta:TableMeta):void
		{
			_meta.copyFrom(meta);
			dispatchEvent(new TableEvent(TableEvent.META_CHANGED, this));
		}
		
		public function addColumnAt(column:TableColumnDescription, index:int = -1, addOwn:Boolean = true):void
		{
			index = index <= -1 ? _meta.allColumns.length : index;
			
			_meta.addColumn(column, index, addOwn);
			
			onColumnAdded(column, index);
			
			dispatchEvent(new TableEvent(TableEvent.COLUMN_ADDED, this));
		}
		
		public function removeColumn(column:TableColumnDescription):void
		{
			var index:int = _meta.allColumns.indexOf(column);
			
			_meta.removeColumn(column);
			
			onColumnRemoved(column, index);
			
			dispatchEvent(new TableEvent(TableEvent.COLUMN_REMOVED, this));
		}
		
		public function moveColumn(column:TableColumnDescription, newIndex:int):void
		{
			var oldIndex:int = _meta.allColumns.indexOf(column);
			
			_meta.moveColumn(column, oldIndex, newIndex);
			
			onColumnMoved(column, oldIndex, newIndex);
			
			dispatchEvent(new TableEvent(TableEvent.COLUMN_MOVED, this));
		}
		
		public function editColumn(column:TableColumnDescription, newData:TableColumnDescription, typeChanged:Boolean, valuesToSet:ColumnStoredValues = null):void
		{
			column.copyFrom(newData);
			
			onColumnChanged(column, _meta.allColumns.indexOf(column), typeChanged, valuesToSet);
			
			dispatchEvent(new TableEvent(TableEvent.COLUMN_CHANGED, this));
		}
		
		protected function onColumnAdded(column:TableColumnDescription, index:int):void
		{
			//to override
		}
		
		protected function onColumnRemoved(column:TableColumnDescription, index:int):void
		{
			//to override
		}
		
		protected function onColumnMoved(column:TableColumnDescription, oldIndex:int, newIndex:int):void
		{
			//to override
		}
		
		protected function onColumnChanged(column:TableColumnDescription, index:int, typeChanged:Boolean, valuesToSet:ColumnStoredValues = null):void
		{
			//to override
		}
		
		public function getTablesRowsValuesByColumn(column:TableColumnDescription, values:ColumnStoredValues = null):ColumnStoredValues
		{
			if (values == null)
			{
				values = new ColumnStoredValues();
			}
			
			return values;
		}
	}
}