package ru.kennel32.editor.data.table.find
{
	import flash.utils.Dictionary;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.table.TablesCache;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.data.utils.ParseUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class FindResult
	{
		private static const FIND_RESULT_CHARS_COUNT:int = 70;
		
		public static const TAB_META:int			= 0;
		public static const TAB_ROWS:int			= 1;
		public static const TAB_USAGE:int			= 2;
		public static const TAB_LOCALIZATIONS:int	= 3;
		public static const ALL_TABS:Vector.<int> = Vector.<int>([TAB_META, TAB_ROWS, TAB_USAGE, TAB_LOCALIZATIONS]);
		
		private var _cacheResultByTable:Vector.<Dictionary>;
		private var _cacheResultByRow:Vector.<Dictionary>;
		private var _cacheUsageResultByRow:Vector.<Dictionary>;
		
		private var _foundRows:Vector.<TableRow>;
		
		private var _cache:TablesCache;
		
		private var _findWhat:String;
		private var _findUsage:Boolean;
		private var _findLocalizations:Boolean;
		
		private var _result:Vector.<Vector.<FindResultEntry>>;
		public function get result():Vector.<Vector.<FindResultEntry>>
		{
			return _result;
		}
		
		public static function newFind(what:String, findUsage:Boolean = true, findLocalizations:Boolean = true, onlyInTable:BaseTable = null):FindResult
		{
			return new FindResult().find(what, findUsage, findLocalizations, onlyInTable);
		}
		
		public function FindResult()
		{
			reset();
		}
		
		public function reset():FindResult
		{
			_result = new Vector.<Vector.<FindResultEntry>>(ALL_TABS.length);
			_cacheResultByTable = new Vector.<Dictionary>(ALL_TABS.length);
			_cacheResultByRow = new Vector.<Dictionary>(ALL_TABS.length);
			_cacheUsageResultByRow = new Vector.<Dictionary>(ALL_TABS.length);
			
			_findUsage = false;
			_foundRows = new Vector.<TableRow>();
			
			for each (var tab:int in ALL_TABS)
			{
				_result[tab] = new Vector.<FindResultEntry>();
				_cacheResultByTable[tab] = new Dictionary();
				_cacheResultByRow[tab] = new Dictionary();
				_cacheUsageResultByRow[tab] = new Dictionary();
			}
			
			_findWhat = null;
			_cache = Main.instance.rootTable.cache;
			
			return this;
		}
		
		private function addRowToFindUsage(row:TableRow):void
		{
			if (_foundRows.indexOf(row) <= -1)
			{
				_foundRows.push(row);
			}
		}
		
		public function find(what:String, findUsage:Boolean = true, findLocalizations:Boolean = true, onlyInTable:BaseTable = null):FindResult
		{
			reset();
			
			_findWhat = what;
			_findLocalizations = findLocalizations;
			
			var split:Array = _findWhat.split(':');
			var tableId:int = split.length == 2 ? split[0] : 0;
			var itemId:int = split.length == 2 ? split[1] : 0;
			if (findUsage && itemId > 0 && tableId > 0 && tableId.toString() == split[0] && itemId.toString() == split[1])
			{
				if (tableId.toString() == split[0] && itemId.toString() == split[1])
				{
					addRowToFindUsage(_cache.getRowById(itemId, tableId));
				}
			}
			
			var table:BaseTable = onlyInTable != null ? onlyInTable : Main.instance.rootTable;
			if (_foundRows.length <= 0)
			{
				findInTable(table, 0);
			}
			
			_findUsage = findUsage;
			if (_findUsage && _foundRows.length > 0)
			{
				for (var i:int = 0; i < _foundRows.length; i++)
				{
					findInTable(table, 0, _foundRows[i], i * 1000);
				}
			}
			
			for each (var entries:Vector.<FindResultEntry> in _result)
			{
				entries.sort(sortResults);
			}
			
			return this;
		}
		
		private function sortResults(a:FindResultEntry, b:FindResultEntry):int
		{
			return a.sort != b.sort ? b.sort - a.sort : (a.depth - b.depth);
		}
		
		private function findInTable(table:BaseTable, depth:int, rowUsage:TableRow = null, rowUsageSort:int = 0):void
		{
			if (_findUsage && rowUsage == null)
			{
				return;
			}
			
			var contTable:ContainerTable = table as ContainerTable;
			if (contTable != null)
			{
				for each (var subTable:BaseTable in contTable.children)
				{
					findInTable(subTable, depth + 1, rowUsage, rowUsageSort);
				}
			}
			
			if (rowUsage == null)
			{
				check(table.meta.name,				TAB_META, 290, depth, table, null, 'meta.name');
				check(table.meta.id,				TAB_META, 280, depth, table, null, 'meta.id');
				check(table.meta.tag,				TAB_META, 260, depth, table, null, 'meta.tag');
				check(table.meta.description,		TAB_META, 230, depth, table, null, 'meta.description');
				check(table.meta.counterId,			TAB_META, 270, depth, table, null, 'meta.counterId');
				
				for each (var column:TableColumnDescription in table.meta.allColumns)
				{
					check(column.name,				TAB_META, 190, depth, table, null, 'column.name');
					check(column.tag,				TAB_META, 170, depth, table, null, 'column.tag');
					check(column.description,		TAB_META, 160, depth, table, null, 'column.description');
					check(column.metaId,			TAB_META, 150, depth, table, null, 'column.metaId');
					check(column.textPattern,		TAB_META, 150, depth, table, null, 'column.textPattern');
					check(column.filePath,			TAB_META, 150, depth, table, null, 'column.filePath');
					check(column.fileExtension,		TAB_META, 120, depth, table, null, 'column.fileExtension');
					if (column.fileImageSize != null && column.fileImageSize.length >= 2)
					{
						check(column.fileImageSize[0],	TAB_META, 110, depth, table, null, 'column.fileImageSize.x');
						check(column.fileImageSize[1],	TAB_META, 110, depth, table, null, 'column.fileImageSize.y');
					}
					check(column.defaultValue,		TAB_META, 120, depth, table, null, 'column.defaultValue');
				}
			}
			
			var dataTable:DataTable = table as DataTable;
			if (dataTable != null)
			{
				for each (var row:TableRow in dataTable.rows)
				{
					for (var i:int = 0; i < row.data.length; i++)
					{
						var value:Object = row.data[i];
						column = table.meta.allColumns[i];
						
						checkCellValue(value, column, depth, table, row, rowUsage, rowUsageSort, 'column:' + column.name);
					}
				}
			}
		}
		
		private function checkCellValue(value:Object, column:TableColumnDescription, depth:Number, table:BaseTable, row:TableRow, rowUsage:TableRow, rowUsageSort:int, groupDescription:String):void
		{
			if (column.type == TableColumnDescriptionType.INNER_TABLE)
			{
				var innerTableColumns:Vector.<TableColumnDescription> = _cache.getTableById(column.metaId).meta.allColumns;
				var innerTableValues:Vector.<Array> = value as Vector.<Array>;
				for (var i:int = Hardcode.INNER_TABLE_SKIP_ID; i < innerTableColumns.length; i++)
				{
					for (var j:int = 0; j < innerTableValues.length; j++)
					{
						checkCellValue(innerTableValues[j][i - Hardcode.INNER_TABLE_SKIP_ID], innerTableColumns[i], depth + 0.1, table, row, rowUsage, rowUsageSort, groupDescription + ':' + innerTableColumns[i].name);
					}
				}
				return;
			}
			
			if (rowUsage != null)
			{
				if (rowUsage.parent == _cache.localizationTable && rowUsage.name == row.getFullTextPattern(column) ||
					column.type == TableColumnDescriptionType.SELECT_SINGLE_ID && _cache.getRowById(uint(value), column.idFrom) == rowUsage)
				{
					var res:FindResultEntry = new FindResultEntry(table, row, rowUsageSort, depth, null, null, rowUsage, 0, 0, groupDescription);
					res.where = 'table row: ' + row.nameWithId + ', value: ';
					res.whereSelectionStartIndex = res.where.length;
					res.where += rowUsage.nameWithId;
					res.whereSelectionEndIndex = res.where.length;
					_result[TAB_USAGE].push(res);
				}
				return;
			}
			
			switch (column.type)
			{
				case TableColumnDescriptionType.LOCK:
				case TableColumnDescriptionType.BOOL_VALUE:
					break;
				
				case TableColumnDescriptionType.TEXT_PATTERN:
					check(row.getFullTextPattern(column),				TAB_ROWS, 290, depth, table, row, groupDescription);
					check(row.getLocalizationForTextPattern(column),	TAB_ROWS, 250, depth, table, row, groupDescription);
					break;
				
				case TableColumnDescriptionType.FILE_PATH:
					check(row.getFullFilePath(column),					TAB_ROWS, 290, depth, table, row, groupDescription);
					break;
				
				case TableColumnDescriptionType.SELECT_SINGLE_ID:
					check(value,										TAB_ROWS, 270, depth, table, row, groupDescription);
					var fromTableRow:TableRow = _cache.getRowById(uint(value), column.idFrom);
					if (fromTableRow != null)
					{
						check(fromTableRow.name, 						TAB_ROWS, 260, depth, table, row, groupDescription);
					}
					break;
				
				case TableColumnDescriptionType.STRING_VALUE:
				case TableColumnDescriptionType.STRING_MULTILINE:
					if (table == _cache.localizationTable && !Hardcode.isLockedColumnData2(table.meta, column) && !column.useAsName && _findLocalizations)
					{
						check(value,									TAB_LOCALIZATIONS, 290, depth, table, row, groupDescription); 
						break;
					}
				default:
					res = check(value,									TAB_ROWS, 290, depth, table, row, groupDescription);
					if (res != null && (column.useAsName || column.type == TableColumnDescriptionType.ID))
					{
						addRowToFindUsage(res.row);
					}
					break;
			}
		}
		
		private function check(where:Object, type:int, sort:int, depth:Number, table:BaseTable, row:TableRow, groupDescription:String):FindResultEntry
		{
			if (where == null || where == '')
			{
				return null;
			}
			var cachedValue:FindResultEntry = row == null ? _cacheResultByTable[type][table] : _cacheResultByRow[type][row];
			
			if (cachedValue != null && cachedValue.sort >= sort && cachedValue.depth <= depth)
			{
				return null;
			}
			
			var whereStr:String = where.toString().toLowerCase();
			
			var index:int = whereStr.indexOf(_findWhat);
			if (index > -1)
			{
				if (cachedValue != null)
				{
					cachedValue.sort = sort;
					return null;
				}
				
				var res:FindResultEntry = new FindResultEntry(table, row, sort, depth, _findWhat);
				
				var additionalChars:int = (FIND_RESULT_CHARS_COUNT / Settings.tableScale - _findWhat.length) / 2;
				var charsAtLeft:int = Math.min(additionalChars, index);
				var charsAtRight:int = Math.min(additionalChars, whereStr.length - index - _findWhat.length);
				additionalChars += Math.abs(charsAtLeft - charsAtRight);
				res.where = whereStr.substring(Math.max(0, index - additionalChars), Math.min(whereStr.length, index + _findWhat.length + additionalChars));
				res.whereSelectionStartIndex = res.where.indexOf(_findWhat);
				res.whereSelectionEndIndex = res.whereSelectionStartIndex + _findWhat.length;
				res.groupDescription = groupDescription;
				
				_result[type].push(res);
				
				if (row == null)
				{
					_cacheResultByTable[type][table] = res;
				}
				else
				{
					_cacheResultByRow[type][row] = res;
				}
			}
			
			return res;
		}
	}
}