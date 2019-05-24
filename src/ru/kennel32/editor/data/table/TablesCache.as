package ru.kennel32.editor.data.table 
{
	import flash.utils.Dictionary;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.helper.warning.WarningData;
	import ru.kennel32.editor.data.helper.warning.WarningLevel;
	import ru.kennel32.editor.data.helper.warning.WarningType;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class TablesCache
	{
		internal var _root:ContainerTable;
		
		internal var _tablesById:Object;
		internal var _countersById:Object;
		internal var _countersTable:DataTable;
		internal var _localizationTable:DataTable;
		internal var _tablesByCounterId:Object;
		internal var _rowsByCounterIdAndId:Object;
		internal var _localizationByKey:Object;
		internal var _dataRowsByLocalizationKey:Object;
		internal var _listInnerTableMeta:Vector.<TableMeta>;
		internal var _listTablesByInnerTableMeta:Object;
		
		internal var _warningsByLevel:Dictionary;
		internal var _warningsCountByLevel:Dictionary;
		
		private var _builder:TablesCacheBuilder;
		public function get builder():TablesCacheBuilder { return _builder; }
		
		public function TablesCache(root:BaseTable)
		{
			resetMain();
			resetLocalization();
			
			_root = root as ContainerTable;
			_builder = new TablesCacheBuilder(this, _root);
		}
		
		public function resetMain():void
		{
			_tablesById = new Object();
			_countersById = new Object();
			_countersTable = null;
			_localizationTable = null;
			_tablesByCounterId = new Object();
			_rowsByCounterIdAndId = new Object();
			_dataRowsByLocalizationKey = new Object();
			_listInnerTableMeta = new Vector.<TableMeta>();
			_listTablesByInnerTableMeta = new Object();
			
			resetWarnings();
		}
		public function resetLocalization():void
		{
			_localizationByKey = new Object();
		}
		public function resetWarnings():void
		{
			_cachedWarningsByLevel = null;
			_warningsByLevel = new Dictionary();
			_warningsCountByLevel = new Dictionary();
			
			for each (var level:WarningLevel in WarningLevel.ALL)
			{
				_warningsByLevel[level] = new Dictionary();
				_warningsCountByLevel[level] = 0;
				for each (var wt:WarningType in WarningType.ALL)
				{
					if (wt.level == level)
					{
						_warningsByLevel[level][wt] = new Vector.<WarningData>();
					}
				}
			}
		}
		
		public function getTableById(id:uint):BaseTable
		{
			return _tablesById[id];
		}
		
		public function getCounterById(id:uint):Counter
		{
			return _countersById[id];
		}
		
		public function get countersTable():DataTable
		{
			return _countersTable;
		}
		
		public function get localizationTable():DataTable
		{
			return _localizationTable;
		}
		
		public function getTablesByCounterId(id:int):Vector.<BaseTable>
		{
			if (_tablesByCounterId[id] === undefined)
			{
				_tablesByCounterId[id] = new Vector.<BaseTable>();
			}
			return _tablesByCounterId[id];
		}
		
		public function getRowById(itemId:uint, counterId:uint):TableRow
		{
			if (_rowsByCounterIdAndId[counterId] == null)
			{
				_rowsByCounterIdAndId[counterId] = new Object();
			}
			return _rowsByCounterIdAndId[counterId][itemId];
		}
		
		public function getLocalization(key:String):String
		{
			if (_localizationByKey[key] == null)
			{
				return '__' + key + '__';
			}
			else if (_localizationByKey[key]['length'] <= 0)
			{
				return Texts.textEmpty;
			}
			return _localizationByKey[key];
		}
		
		public function getDataRowByLocalizationKey(key:String):TableRow
		{
			return _dataRowsByLocalizationKey[key];
		}
		
		public function get listInnerTableMeta():Vector.<TableMeta>
		{
			return _listInnerTableMeta;
		}
		
		private static const EMPTY_VECTOR_DATATABLE:Vector.<DataTable> = new Vector.<DataTable>();
		public function getTablesByInnerTableMeta(metaId:uint):Vector.<DataTable>
		{
			var res:Vector.<DataTable> = _listTablesByInnerTableMeta[metaId];
			return res != null ? res : EMPTY_VECTOR_DATATABLE;
		}
		
		internal var _cachedWarningsByLevel:Dictionary;
		public function getWarnings(level:WarningLevel):Vector.<WarningData>
		{
			if (_cachedWarningsByLevel == null)
			{
				_cachedWarningsByLevel = new Dictionary();
				for (var lvl:Object in _warningsByLevel)
				{
					var res:Vector.<WarningData> = new Vector.<WarningData>();
					for each (var list:Vector.<WarningData> in _warningsByLevel[lvl])
					{
						res = res.concat(list);
					}
					_cachedWarningsByLevel[lvl] = res;
				}
			}
			return _cachedWarningsByLevel[level];
		}
		
		public function getWarningsCount(level:WarningLevel):int
		{
			return _warningsCountByLevel[level];
		}
	}
}