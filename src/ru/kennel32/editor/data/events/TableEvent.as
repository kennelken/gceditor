package ru.kennel32.editor.data.events 
{
	import flash.events.Event;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class TableEvent extends Event 
	{
		public static const FILE_CHANGED:String = 'filechanged';
		public static const TREE_CHANGED:String = 'treechanged';
		public static const TABLE_SELECTION_CHANGED:String = 'tableselectionchanged';
		public static const ROW_CHECKED_CHANGED:String = 'rowcheckedchanged';
		public static const TABLE_CHECKED_CHANGED:String = 'tableselectionchanged';
		public static const ROWS_ADDED:String = 'rowsadded';
		public static const ROWS_DELETED:String = 'rowsdeleted';
		public static const TABLES_ADDED:String = 'tablesadded';
		public static const TABLES_DELETED:String = 'tablesdeleted';
		public static const TREE_COLLAPSE_CHANGED:String = 'treecollapsechanged';
		public static const META_CHANGED:String = 'metachanged';
		public static const COLUMN_ADDED:String = 'columnadded';
		public static const COLUMN_CHANGED:String = 'columnchanged';
		public static const COLUMN_REMOVED:String = 'columnremoved';
		public static const COLUMN_MOVED:String = 'columnmoved';
		public static const CACHE_UPDATED:String = 'cacheupdated';
		
		public function TableEvent(type:String, table:BaseTable, row:TableRow = null, rows:Vector.<TableRow> = null, parent:ContainerTable = null, tables:Vector.<BaseTable> = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			this.table = table;
			this.row = row;
			this.rows = rows;
			this.parent = parent;
			this.tables = tables;
			
			super(type, bubbles, cancelable);
		}
		
		public var table:BaseTable;
		public var row:TableRow;
		public var rows:Vector.<TableRow>;
		public var parent:ContainerTable;
		public var tables:Vector.<BaseTable>;
	}
}