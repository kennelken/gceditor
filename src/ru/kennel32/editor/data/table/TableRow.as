package ru.kennel32.editor.data.table 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.settings.ProjectSettings;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.data.utils.LocalizationUtils;
	import ru.kennel32.editor.data.utils.ParseUtils;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.DataTable;
	
	public class TableRow extends EventDispatcher
	{
		public function TableRow(parent:BaseTable)
		{
			_parent = parent;
			_data = new Array();
			
			doOnAnyChange();
		}
		
		protected var _parent:BaseTable;
		public function get parent():BaseTable
		{
			return _parent;
		}
		
		internal var _data:Array;
		public function get data():Array
		{
			return _data;
		}
		public function set data(value:Array):void
		{
			_data = value;
		}
		
		private var _id:int;
		public function get id():int
		{
			if (_id <= -1)
			{
				_id = _data[Hardcode.ID_INDEX];
			}
			return _id;
		}
		
		public function get lock():Boolean
		{
			var index:int = _parent.meta.getColumnIndexByType(TableColumnDescriptionType.LOCK);
			
			return index > -1 && ParseUtils.readBool(_data[index]);
		}
		
		public function decode(data:Array):void
		{
			_data = data;
			
			var columns:Vector.<TableColumnDescription> = _parent.meta.allColumns;
			for (var i:int = 0; i < columns.length; i++)
			{
				var type:int = columns[i].type;
				switch (type)
				{
					case TableColumnDescriptionType.INNER_TABLE:
						var table:BaseTable = Main.instance.rootTable.cache.getTableById(columns[i].metaId);
						var meta:TableMeta = table == null ? null : table.meta;
						_data[i] = ParseUtils.readInnerTable(_data[i], meta == null ? null : meta.columns)
						break;
					
					default:
						_data[i] = ParseUtils.readValue(_data[i], type);
				}
			}
			
			doOnAnyChange();
		}
		
		private var _name:String;
		public function get name():String
		{
			if (_name == null)
			{
				var i:int = _parent.meta.nameColumnIndex;
				
				if (i > -1)
				{
					if (_parent._meta._allColumns[i].type == TableColumnDescriptionType.TEXT_PATTERN)
					{
						_name = getLocalizationForTextPattern(_parent._meta._allColumns[i]);
					}
					else
					{
						_name = _data[i];
					}
				}
				else
				{
					_name = '<' + _parent.meta.name + id + '>';
				}
			}
			
			return _name;
		}
		
		private var _nameWithId:String;
		public function get nameWithId():String
		{
			if (_nameWithId == null)
			{
				_nameWithId = id + '.' + name;
			}
			return _nameWithId;
		}
		
		public function dispatchChange():void
		{
			doOnAnyChange();
			dispatchEvent(new Event(Event.CHANGE));
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
			
			dispatchEvent(new TableEvent(TableEvent.ROW_CHECKED_CHANGED, _parent, this));
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
		
		public function doOnAnyChange():void
		{
			_id = -1;
			_name = null;
			_nameWithId = null;
		}
		
		public function get isSystem():Boolean
		{
			return false;	//to override
		}
		
		public function get allowForUseinSelectItem():Boolean
		{
			return !isSystem;
		}
		
		internal function onColumnAdded(index:int):void
		{
			var column:TableColumnDescription = _parent.meta.allColumns[index];
			var isInnerTable:Boolean = column.type == TableColumnDescriptionType.INNER_TABLE;
			
			_data.splice(index, 0, null);
			onColumnChanged(index, true, isInnerTable ? null : _parent.meta.allColumns[index].defaultValue);
		}
		
		internal function onColumnRemoved(index:int):void
		{
			_data.splice(index, 1);
			doOnAnyChange();
		}
		
		internal function onColumnMoved(oldIndex:int, newIndex:int):void
		{
			var value:* = _data[oldIndex];
			_data.splice(oldIndex, 1);
			_data.splice(newIndex, 0, value);
			doOnAnyChange();
		}
		
		internal function onColumnChanged(index:int, typeChanged:Boolean, value:Object = null):void
		{
			if (value != null)
			{
				_data[index] = value;
			}
			else if (typeChanged)
			{
				var column:TableColumnDescription = _parent.meta.allColumns[index];
				if (column.type == TableColumnDescriptionType.INNER_TABLE)
				{
					var table:DataTable = Main.instance.rootTable.cache.getTableById(column.metaId) as DataTable;
					if (table != null)
					{
						_data[index] = ParseUtils.readInnerTable(column.defaultValue, table.meta.columns);
					}
					else
					{
						_data[index] = '';
					}
				}
				else
				{
					_data[index] = ParseUtils.readValue(column.defaultValue, column.type);
				}
			}
			doOnAnyChange();
		}
		
		public function getLocalizationForTextPattern(column:TableColumnDescription):String
		{
			return Main.instance.rootTable.cache.getLocalization(getFullTextPattern(column));
		}
		
		public function getFullTextPattern(column:TableColumnDescription):String
		{
			return LocalizationUtils.getKey(column.textPattern, _data[0]);
		}
		
		public function getFullFilePath(column:TableColumnDescription):String
		{
			return ProjectSettings.filesRoot + column.filePath + TextUtils.prefixToLength(_data[0].toString(), 6, '0') +
				(column.fileExtension != null && column.fileExtension.length > 0 ? '.' + column.fileExtension : '');
		}
	}
}