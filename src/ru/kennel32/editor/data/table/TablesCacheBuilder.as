package ru.kennel32.editor.data.table
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.helper.warning.WarningData;
	import ru.kennel32.editor.data.helper.warning.WarningType;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.data.utils.LocalizationUtils;
	
	public class TablesCacheBuilder
	{
		private var _root:ContainerTable;
		private var _cache:TablesCache;
		
		public function TablesCacheBuilder(cache:TablesCache, root:ContainerTable)
		{
			_cache = cache;
			_root = root;
		}
		
		public function build():void
		{
			rebuildMain(false);
			rebuildLocalizations(false);
			onRebuild(true);
		}
		
		public function rebuildMain(isFinal:Boolean = true):void
		{
			_cache.resetMain();
			doRebuildMain(_root);
			onRebuild(isFinal);
		}
		
		public function rebuildLocalizations(isFinal:Boolean = true):void
		{
			_cache.resetLocalization();
			doRebuildLocalizations(_root);
			onRebuild(isFinal);
		}
		
		public function updateErrors():void
		{
			onRebuild(true);
		}
		
		private function onRebuild(isFinal:Boolean):void
		{
			if (isFinal)
			{
				_cache.resetWarnings();
				
				_cacheColumnTagsByTable = new Object();
				_cacheUseAsNameByTable = new Object();
				_cacheTablesTagsByParent = new Object();
				findProblems(_root);
				
				Main.instance.dispatchEvent(new TableEvent(TableEvent.CACHE_UPDATED, _root));
			}
		}
		
		public function updateLocalizations(rows:Vector.<TableRow> = null, keysToDelete:Vector.<String> = null):void
		{
			for each (var key:String in keysToDelete)
			{
				delete _cache._localizationByKey[key];
			}
			
			for each (var row:TableRow in rows)
			{
				if (row.parent.meta.counterId != Counter.LOCALIZATION)
				{
					throw new Error("Localization row expected");
				}
				
				if (row.data.length > Hardcode.LOCALIZTION_TABLE_NUM_SYSTEM_COLUMNS)
				{
					_cache._localizationByKey[row.name] = row.data[Hardcode.LOCALIZTION_TABLE_NUM_SYSTEM_COLUMNS];
				}
			}
		}
		
		private function doRebuildMain(table:BaseTable):void
		{
			table.meta.clearCache();
			
			_cache._tablesById[table.meta.id] = table;
			
			if (_cache._tablesByCounterId[table.meta.counterId] == null)
			{
				_cache._tablesByCounterId[table.meta.counterId] = new Vector.<BaseTable>();
			}
			_cache._tablesByCounterId[table.meta.counterId].push(table);
			
			var dataTable:DataTable = table as DataTable;
			if (dataTable != null)
			{
				_cache._tablesById[dataTable.meta.id] = dataTable;
				if (_cache._rowsByCounterIdAndId[dataTable.meta.counterId] == null)
				{
					_cache._rowsByCounterIdAndId[dataTable.meta.counterId] = new Object();
				}
				
				var textPatterns:Vector.<String> = new Vector.<String>();
				
				for (var i:int = 0; i < dataTable.meta.allColumns.length; i++)
				{
					if (dataTable.meta.allColumns[i].type == TableColumnDescriptionType.TEXT_PATTERN)
					{
						textPatterns.push(dataTable.meta.allColumns[i].textPattern);
					}
				}
				
				for (i = 0; i < dataTable.rows.length; i++)
				{
					if ((dataTable.rows[i] is Counter))
					{
						_cache._countersById[dataTable.rows[i].id] = dataTable.rows[i];
						_cache._countersTable = dataTable;
					}
					
					_cache._rowsByCounterIdAndId[dataTable.meta.counterId][dataTable.rows[i].id] = dataTable.rows[i];
					
					for each (var textPattern:String in textPatterns)
					{
						_cache._dataRowsByLocalizationKey[LocalizationUtils.getKey(textPattern, dataTable.rows[i].id)] = dataTable.rows[i];
					}
				}
				
				if (dataTable._meta.counterId == Counter.LOCALIZATION)
				{
					_cache._localizationTable = dataTable;
				}
				
				if (dataTable.meta.forInnerTable && dataTable.parent.meta.counterId <= 0)
				{
					_cache._listInnerTableMeta.push(dataTable.meta);
				}
				
				for (i = 0; i < table.meta.allColumns.length; i++)
				{
					var column:TableColumnDescription = table.meta.allColumns[i];
					
					if (column.type == TableColumnDescriptionType.INNER_TABLE)
					{
						var metaId:uint = column.metaId;
						
						if (_cache._listTablesByInnerTableMeta[metaId] == null)
						{
							_cache._listTablesByInnerTableMeta[metaId] = new Vector.<DataTable>();
						}
						
						if (_cache._listTablesByInnerTableMeta[metaId].indexOf(table) <= -1)
						{
							_cache._listTablesByInnerTableMeta[metaId].push(table);
						}
					}
				}
			}
			
			var containerTable:ContainerTable = table as ContainerTable;
			if (containerTable != null)
			{
				for each (var bt:BaseTable in containerTable.children)
				{
					doRebuildMain(bt);
				}
			}
		}
		
		private function doRebuildLocalizations(table:BaseTable):void
		{
			var dataTable:DataTable = table as DataTable;
			if (dataTable != null && dataTable.meta.counterId == Counter.LOCALIZATION)
			{
				for (var i:int = 0; i < dataTable.rows.length; i++)
				{
					if (dataTable.rows[i].data.length > Hardcode.LOCALIZTION_TABLE_NUM_SYSTEM_COLUMNS)
					{
						_cache._localizationByKey[dataTable.rows[i].name] = dataTable.rows[i].data[Hardcode.LOCALIZTION_TABLE_NUM_SYSTEM_COLUMNS];
					}
				}
			}
			
			var containerTable:ContainerTable = table as ContainerTable;
			if (containerTable != null)
			{
				for each (var bt:BaseTable in containerTable.children)
				{
					doRebuildLocalizations(bt);
				}
			}
		}
		
		////////////////////////////////////////
		// data validation
		//
		
		private function findProblems(table:BaseTable):void
		{
			var inheritedColumnsCount:int = table.meta.allColumns.length - table.meta.columns.length;
			for (var i:int = 0; i < table.meta.allColumns.length; i++)
			{
				var isOwn:Boolean = i >= inheritedColumnsCount;
				var column:TableColumnDescription = table.meta.allColumns[i];
				
				findProblemInColumn(column, table, isOwn);
			}
			
			findProblemInMeta(table);
			
			var dataTable:DataTable = table as DataTable;
			if (dataTable != null)
			{
				for (var j:int = 0; j < dataTable.rows.length; j++)
				{
					var row:TableRow = dataTable.rows[j];
					
					row.doOnAnyChange();
					
					for (i = 0; i < dataTable.meta.allColumns.length; i++)
					{
						column = dataTable.meta.allColumns[i];
						var data:* = row.data[i];
						
						switch (column.type)
						{
							case TableColumnDescriptionType.INNER_TABLE:
								var dataIn:Vector.<Array> = data as Vector.<Array>;
								var metaIn:TableMeta = _cache.getTableById(column.metaId).meta;
								
								for (var jIn:int = 0; jIn < dataIn.length; jIn++)
								{
									var rowIn:Array = dataIn[jIn];
									
									for (var iIn:int = 0; iIn < metaIn.allColumns.length; iIn++)
									{
										if (iIn < Hardcode.INNER_TABLE_SKIP_ID)
										{
											continue;
										}
										var columnIn:TableColumnDescription = metaIn.allColumns[iIn];
										findProblemInCell(rowIn[iIn - Hardcode.INNER_TABLE_SKIP_ID], columnIn, table, row);
									}
								}
								
								break;
							
							default:
								findProblemInCell(data, column, table, row);
						}
					}
				}
			}
			
			var containerTable:ContainerTable = table as ContainerTable;
			if (containerTable != null)
			{
				for each (var bt:BaseTable in containerTable._children)
				{
					findProblems(bt);
				}
			}
		}
		
		private function findProblemInCell(value:*, column:TableColumnDescription, table:BaseTable, row:TableRow):void
		{
			try
			{
				if (column.mustBeNonEmpty)
				{
					if (value == column.defaultValue || value == null)
					{
						addWarning(new WarningData(WarningType.MUST_BE_NON_EMPTY, table, column, row));
					}
				}
				
				switch (column.type)
				{
					case TableColumnDescriptionType.SELECT_SINGLE_ID:
						var id:int = value as int;
						if (id <= 0)
						{
							addWarning(new WarningData(WarningType.EMPTY_REFERENCE, table, column, row));
							break;
						}
						
						var data:TableRow = _cache.getRowById(id, column.idFrom);
						if (data == null)
						{
							addWarning(new WarningData(WarningType.MISSING_REFERENCE, table, column, row));
						}
						break;
					
					case TableColumnDescriptionType.TEXT_PATTERN:
						id = row.data[Hardcode.ID_INDEX];
						var loc:String = _cache._localizationByKey[LocalizationUtils.getKey(column.textPattern, id)];
						if (loc == null)
						{
							addWarning(new WarningData(WarningType.MISSING_LOCALIZATION, table, column, row));
						}
						break;
				}
			}
			catch (e:Error)
			{
				addWarning(new WarningData(WarningType.CHECKING_EXCEPTION, table, column, row));
			}
		}
		
		private var _cacheColumnTagsByTable:Object;
		private var _cacheUseAsNameByTable:Object;
		private function findProblemInColumn(column:TableColumnDescription, table:BaseTable, isOwn:Boolean):void
		{
			try
			{
				if (_cacheColumnTagsByTable[table.meta.id] == null)
				{
					_cacheColumnTagsByTable[table.meta.id] = new Object();
				}
				
				var isEmptyTag:Boolean = column.tag == null || column.tag == '';
				var isValuable:Boolean = TableColumnDescriptionType.isValuable(column.type);
				
				if (isOwn && isValuable && isEmptyTag)
				{
					addWarning(new WarningData(WarningType.MISSING_TAG, table, column, null));
				}
				
				if (!isEmptyTag && _cacheColumnTagsByTable[table.meta.id][column.tag])
				{
					addWarning(new WarningData(WarningType.DUPLICATING_TAG, table, column, null));
				}
				
				_cacheColumnTagsByTable[table.meta.id][column.tag] = true;
				
				if (column.useAsName)
				{
					if (_cacheUseAsNameByTable[table.meta.id])
					{
						addWarning(new WarningData(WarningType.MULTIPLE_USE_AS_NAME, table, column, null));
					}
					_cacheUseAsNameByTable[table.meta.id] = true;
				}
			}
			catch (e:Error)
			{
				addWarning(new WarningData(WarningType.CHECKING_EXCEPTION, table, column, null));
			}
		}
		
		private var _cacheTablesTagsByParent:Object;
		private function findProblemInMeta(table:BaseTable):void
		{
			try
			{
				var parentid:int = table.parent == null ? 0 : table.parent.meta.id;
				if (_cacheTablesTagsByParent[parentid] == null)
				{
					_cacheTablesTagsByParent[parentid] = new Object();
				}
				
				var isEmptyTag:Boolean = table.meta.tag == null || table.meta.tag == '';
				
				if (isEmptyTag)
				{
					addWarning(new WarningData(WarningType.MISSING_TAG, table, null, null));
				}
				if (!isEmptyTag && _cacheTablesTagsByParent[parentid][table.meta.tag])
				{
					addWarning(new WarningData(WarningType.DUPLICATING_TAG, table, null, null));
				}
				
				if (table is DataTable && !_cacheUseAsNameByTable[table.meta.id] && !table.meta.forInnerTable)
				{
					addWarning(new WarningData(WarningType.MISSING_USE_AS_NAME, table, null, null));
				}
				
				_cacheTablesTagsByParent[parentid][table.meta.tag] = true;
			}
			catch (e:Error)
			{
				addWarning(new WarningData(WarningType.CHECKING_EXCEPTION, table, null, null));
			}
		}
		
		private function addWarning(warning:WarningData):void
		{
			_cache._warningsByLevel[warning.type.level][warning.type]['push'](warning);
			_cache._warningsCountByLevel[warning.type.level] = _cache._warningsCountByLevel[warning.type.level] + 1;
		}
	}
}