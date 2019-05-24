package ru.kennel32.editor.data.table
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.helper.ColumnStoredValues;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.utils.SortUtils;
	
	public class ContainerTable extends BaseTable
	{
		internal var _children:Vector.<BaseTable>;
		private var _collapsed:Boolean;
		
		public function ContainerTable(meta:TableMeta)
		{
			super(meta);
			
			_children = new Vector.<BaseTable>();
		}
		
		public function get children():Vector.<BaseTable>
		{
			return _children;
		}
		
		public function addChild(child:BaseTable):void
		{
			addChildren(Vector.<BaseTable>([child]));
		}
		
		public function removeChild(child:BaseTable):void
		{
			removeChildren(Vector.<BaseTable>([child]));
		}
		
		public function addChildren(tables:Vector.<BaseTable>):void
		{
			tables = tables.concat().sort(SortUtils.sortTablesByIndex);
			
			for (var i:int = 0; i < tables.length; i++)
			{
				_children.splice(tables[i].index, 0, tables[i]);
				tables[i].parent = this;
				tables[i]._cache = _cache;
			}
			updateSubtablesIndexes();
			
			Main.instance.dispatchEvent(new TableEvent(TableEvent.TABLES_ADDED, this, null, null, null, tables));
		}
		
		public function removeChildren(tables:Vector.<BaseTable>):void
		{
			tables = tables.concat().sort(SortUtils.sortTablesByIndex).reverse();
			
			for (var i:int = 0; i < tables.length; i++)
			{
				var child:BaseTable = tables[i];
				
				if (child is ContainerTable && (child as ContainerTable).children.length > 0 ||
					child is DataTable && (child as DataTable).rows.length > 0)
				{
					throw new Error("Can not delete not empty table");
				}
				
				child.parent = null;
				_children.splice(_children.indexOf(child), 1);
			}
			updateSubtablesIndexes();
			
			Main.instance.dispatchEvent(new TableEvent(TableEvent.TABLES_DELETED, this, null, null, null, tables));
		}
		
		private function updateSubtablesIndexes():void
		{
			for (var i:int = 0; i < _children.length; i++)
			{
				_children[i].index = i;
			}
		}
		
		public function get collapsed():Boolean
		{
			return _collapsed;
		}
		public function set collapsed(value:Boolean):void
		{
			if (_collapsed == value)
			{
				return;
			}
			
			_collapsed = value;
			
			dispatchEvent(new TableEvent(TableEvent.TREE_COLLAPSE_CHANGED, this));
		}
		
		override protected function onColumnAdded(column:TableColumnDescription, index:int):void 
		{
			super.onColumnAdded(column, index);
			
			for each (var table:BaseTable in _children)
			{
				table.addColumnAt(column, index, false);
			}
		}
		
		override protected function onColumnRemoved(column:TableColumnDescription, index:int):void 
		{
			super.onColumnRemoved(column, index);
			
			for each (var table:BaseTable in _children)
			{
				table.removeColumn(column);
			}
		}
		
		override protected function onColumnMoved(column:TableColumnDescription, oldIndex:int, newIndex:int):void 
		{
			super.onColumnMoved(column, oldIndex, newIndex);
			
			for each (var table:BaseTable in _children)
			{
				table.moveColumn(column, newIndex);
			}
		}
		
		override protected function onColumnChanged(column:TableColumnDescription, index:int, typeChanged:Boolean, valuesToSet:ColumnStoredValues = null):void 
		{
			super.onColumnChanged(column, index, typeChanged, valuesToSet);
			
			for each (var table:BaseTable in _children)
			{
				table.editColumn(column, column, typeChanged, valuesToSet);
			}
		}
		
		override public function getTablesRowsValuesByColumn(column:TableColumnDescription, values:ColumnStoredValues = null):ColumnStoredValues 
		{
			values = super.getTablesRowsValuesByColumn(column, values);
			
			for (var i:int = 0; i < _children.length; i++)
			{
				_children[i].getTablesRowsValuesByColumn(column, values);
			}
			
			return values;
		}
	}
}