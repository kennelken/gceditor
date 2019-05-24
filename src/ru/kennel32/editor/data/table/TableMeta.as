package ru.kennel32.editor.data.table 
{
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	public class TableMeta 
	{
		public function TableMeta()
		{
		}
		
		public static function create(id:uint, type:int, tag:String, counterId:uint):TableMeta
		{
			var res:TableMeta = new TableMeta();
			res._id = id;
			res._type = type;
			res._tag = tag;
			res._counterId = counterId;
			res._columns = new Vector.<TableColumnDescription>();
			res._allColumns = new Vector.<TableColumnDescription>();
			return res;
		}
		
		internal var _id:uint;
		public function get id():uint
		{
			return _id;
		}
		
		internal var _serializerType:int;
		public function get serializerType():int
		{
			return _serializerType;
		}
		public function set serializerType(value:int):void
		{
			_serializerType = value;
		}
		
		internal var _type:int;
		public function get type():int
		{
			return _type;
		}
		public function set type(value:int):void
		{
			_type = value;
		}
		
		internal var _counterId:uint;
		public function get counterId():uint
		{
			return _counterId;
		}
		public function set counterId(value:uint):void
		{
			_counterId = value;
		}
		
		internal var _tag:String;
		public function get tag():String
		{
			return _tag;
		}
		public function set tag(value:String):void
		{
			_tag = value == null ? "" : value;
		}
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name = value == null ? "" : value;
		}
		
		internal var _description:String;
		public function get description():String
		{
			return _description;
		}
		public function set description(value:String):void
		{
			_description = value == null ? "" : value;
		}
		
		internal var _lock:Boolean;
		public function get lock():Boolean
		{
			return _lock;
		}
		public function set lock(value:Boolean):void
		{
			_lock = value;
		}
		
		internal var _forInnerTable:Boolean;
		public function get forInnerTable():Boolean
		{
			return _forInnerTable;
		}
		public function set forInnerTable(value:Boolean):void
		{
			_forInnerTable = value;
		}
		
		internal var _columns:Vector.<TableColumnDescription>;
		public function get columns():Vector.<TableColumnDescription>
		{
			return _columns;
		}
		
		internal var _allColumns:Vector.<TableColumnDescription>;
		public function get allColumns():Vector.<TableColumnDescription>
		{
			return _allColumns;
		}
		
		public function addColumn(column:TableColumnDescription, index:int, addOwn:Boolean):void
		{
			if (_allColumns.length == 0 && column.type != TableColumnDescriptionType.ID)
			{
				throw new Error('First column must be type of "id"');
			}
			
			var numInheritedColumns:int = _allColumns.length - _columns.length;
			
			_allColumns.splice(index, 0, column);
			
			if (addOwn)
			{
				_columns.splice(index - numInheritedColumns, 0, column);
			}
			
			clearCache();
		}
		
		public function removeColumn(column:TableColumnDescription):void
		{
			if (_columns.indexOf(column) > -1)
			{
				_columns.splice(_columns.indexOf(column), 1);
			}
			_allColumns.splice(_allColumns.indexOf(column), 1);
			
			clearCache();
		}
		
		public function moveColumn(column:TableColumnDescription, oldIndex:int, newIndex:int):void
		{
			if (_allColumns.indexOf(column) != oldIndex)
			{
				throw new Error('invalid column index');
			}
			
			_allColumns.splice(oldIndex, 1);
			_allColumns.splice(newIndex, 0, column);
			
			if (_columns.indexOf(column) > -1)
			{
				var inheritedColumnsLength:int = _allColumns.length - _columns.length;
				
				_columns.splice(oldIndex - inheritedColumnsLength, 1);
				_columns.splice(newIndex - inheritedColumnsLength, 0, column);
			}
			
			clearCache();
		}
		
		public function copyFrom(src:TableMeta):void
		{
			_id =				src._id;
			_type =				src._type;
			_counterId =		src._counterId;
			_tag =				src._tag;
			_name =				src._name;
			_description =		src._description;
			_lock =				src._lock;
			_forInnerTable =	src._forInnerTable;
			_columns =			src._columns.concat();
			
			clearCache();
		}
		
		public function updateParentColumnsForNewTable(parent:TableMeta):void
		{
			_allColumns.length = 0;
			
			for (var i:int = 0; i < parent._allColumns.length; i++)
			{
				_allColumns.push(parent._allColumns[i]);
			}
			for (i = 0; i < _columns.length; i++)
			{
				_allColumns.push(_columns[i]);
			}
		}
		
		//////////////////////////////////////////////////////
		
		private var _columnIndexByType:Object;
		public function getColumnIndexByType(type:int):int
		{
			if (_columnIndexByType == null)
			{
				rebuildCache();
			}
			return _columnIndexByType[type] === undefined ? -1 : _columnIndexByType[type];
		}
		
		public function clearCache():void
		{
			_nameColumnIndex = -int.MAX_VALUE;
			_columnIndexByType = null;
		}
		
		private function rebuildCache():void
		{
			clearCache();
			
			_columnIndexByType = new Object();
			for (var i:int = 0; i < _allColumns.length; i++)
			{
				if (_allColumns[i].useAsName)
				{
					_nameColumnIndex = i;
				}
				_columnIndexByType[_allColumns[i].type] = i;
			}
		}
		
		private var _nameColumnIndex:int = -int.MAX_VALUE;
		public function get nameColumnIndex():int
		{
			if (_nameColumnIndex < -1)
			{
				rebuildCache();
			}
			
			return _nameColumnIndex;
		}
	}
}