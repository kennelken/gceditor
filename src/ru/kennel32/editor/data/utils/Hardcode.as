package ru.kennel32.editor.data.utils
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableMeta;
	
	public class Hardcode
	{
		public static const LOCALIZTION_TABLE_NUM_SYSTEM_COLUMNS:int	= 2;
		public static const COUNTER_TABLE_NUM_SYSTEM_COLUMNS:int		= 3;
		public static const SETTINGS_TABLE_NUM_SYSTEM_COLUMNS:int		= 4;
		
		public static const ID_INDEX:int = 0;
		public static const INNER_TABLE_SKIP_ID:int = 1;
		
		public static function isSystemMeta(meta:TableMeta):Boolean
		{
			return meta.id <= Counter.PROJECT_SETTINGS;
		}
		
		public static function isRootMeta(meta:TableMeta):Boolean
		{
			return meta.id == 1;
		}
		
		public static function isLockedData(meta:TableMeta):Boolean
		{
			return meta.id == Counter.PROJECT_SETTINGS;
		}
		
		public static function isSystemCounter(counter:Counter):Boolean
		{
			return counter.id <= Counter.PROJECT_SETTINGS;
		}
		
		public static function isLockedColumnMeta(meta:TableMeta, columnIndex:int):Boolean
		{
			var column:TableColumnDescription = columnIndex >= 0 && columnIndex < meta.allColumns.length ? meta.allColumns[columnIndex] : null;
			if (column == null)
			{
				return true;
			}
			
			if (column.type == TableColumnDescriptionType.ID || column.type == TableColumnDescriptionType.COUNTER)
			{
				return true;
			}
			
			if (meta.counterId == Counter.LOCALIZATION)
			{
				if (columnIndex < LOCALIZTION_TABLE_NUM_SYSTEM_COLUMNS)
				{
					return true;
				}
			}
			
			if (meta.counterId == Counter.COUNTERS)
			{
				if (columnIndex < COUNTER_TABLE_NUM_SYSTEM_COLUMNS)
				{
					return true;
				}
			}
			
			if (meta.counterId == Counter.PROJECT_SETTINGS)
			{
				if (columnIndex < SETTINGS_TABLE_NUM_SYSTEM_COLUMNS)
				{
					return true;
				}
			}
			
			return false;
		}
		
		public static function isLockedColumnMeta2(meta:TableMeta, column:TableColumnDescription):Boolean
		{
			return isLockedColumnMeta(meta, meta.allColumns.indexOf(column));
		}
		
		public static function isLockedColumnData(meta:TableMeta, columnIndex:int):Boolean
		{
			var column:TableColumnDescription = columnIndex >= 0 && columnIndex < meta.allColumns.length ? meta.allColumns[columnIndex] : null;
			if (column == null)
			{
				return true;
			}
			
			if (column.type == TableColumnDescriptionType.ID || column.type == TableColumnDescriptionType.COUNTER)
			{
				return true;
			}
			
			return false;
		}
		
		public static function isLockedColumnData2(meta:TableMeta, column:TableColumnDescription):Boolean
		{
			return isLockedColumnData(meta, meta.allColumns.indexOf(column));
		}
	}
}