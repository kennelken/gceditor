package ru.kennel32.editor.data.table 
{
	public class TableColumnDescription 
	{
		public function TableColumnDescription() 
		{
		}
		
		public static function create(type:int, tag:String, lock:Boolean = false, idFrom:uint = 0, mustBeNonEmpty:Boolean = false):TableColumnDescription
		{
			if (type == TableColumnDescriptionType.ID && tag != "id")
			{
				throw new Error('Column with type="id" must be tagged as "id"');
			}
			if (type == TableColumnDescriptionType.ID && !lock)
			{
				throw new Error('Column with type="id" must be locked');
			}
			
			var res:TableColumnDescription = new TableColumnDescription();
			res._type = type;
			res._tag = tag;
			res._lock = lock;
			res._mustBeNonEmpty = mustBeNonEmpty;
			res._idFrom = idFrom;
			
			res._defaultValue = getDefaultValue(type);
			res.updateDefaultWidth();
			
			return res;
		}
		
		public static function getDefaultValue(type:int):String
		{
			switch (type)
			{
				case TableColumnDescriptionType.ID:
				case TableColumnDescriptionType.INNER_TABLE:
				case TableColumnDescriptionType.SELECT_SINGLE_ID:
				case TableColumnDescriptionType.STRING_VALUE:
				case TableColumnDescriptionType.STRING_MULTILINE:
				case TableColumnDescriptionType.TEXT_PATTERN:
				case TableColumnDescriptionType.FILE_PATH:
					return '';
				
				case TableColumnDescriptionType.BOOL_VALUE:
				case TableColumnDescriptionType.FLOAT_VALUE:
				case TableColumnDescriptionType.COUNTER:
				case TableColumnDescriptionType.INT_VALUE:
				case TableColumnDescriptionType.LOCK:
				case TableColumnDescriptionType.DATE:
					return '0';
			}
			return '';
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
		
		internal var _tag:String;
		public function get tag():String
		{
			return _tag;
		}
		public function set tag(value:String):void
		{
			_tag = value;
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
		
		internal var _mustBeNonEmpty:Boolean;
		public function get mustBeNonEmpty():Boolean
		{
			return _mustBeNonEmpty;
		}
		public function set mustBeNonEmpty(value:Boolean):void
		{
			_mustBeNonEmpty = value;
		}
		
		internal var _name:String;
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name = value;
		}
		
		internal var _description:String;
		public function get description():String
		{
			return _description;
		}
		public function set description(value:String):void
		{
			_description = value;
		}
		
		internal var _useAsName:Boolean;
		public function get useAsName():Boolean
		{
			return _useAsName;
		}
		public function set useAsName(value:Boolean):void
		{
			_useAsName = value;
		}
		
		internal var _width:Number;
		public function get width():Number
		{
			return _width;
		}
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		//
		//optional
		//
		
		internal var _idFrom:uint;
		public function get idFrom():uint
		{
			return _idFrom;
		}
		public function set idFrom(value:uint):void
		{
			_idFrom = value;
		}
		
		internal var _textPattern:String;
		public function get textPattern():String
		{
			return _textPattern;
		}
		public function set textPattern(value:String):void
		{
			_textPattern = value;
		}
		
		internal var _filePath:String;
		public function get filePath():String
		{
			return _filePath;
		}
		public function set filePath(value:String):void
		{
			_filePath = value;
		}
		
		internal var _fileExtension:String;
		public function get fileExtension():String
		{
			return _fileExtension;
		}
		public function set fileExtension(value:String):void
		{
			_fileExtension = value;
		}
		
		internal var _fileImageSize:Vector.<uint> = new Vector.<uint>(2);
		public function get fileImageSize():Vector.<uint>
		{
			return _fileImageSize;
		}
		public function set fileImageSize(value:Vector.<uint>):void
		{
			_fileImageSize = value;
		}
		
		internal var _defaultValue:String;
		public function get defaultValue():String
		{
			return _defaultValue;
		}
		public function set defaultValue(value:String):void
		{
			_defaultValue = value;
		}
		
		internal var _metaId:uint;
		public function get metaId():uint
		{
			return _metaId;
		}
		public function set metaId(value:uint):void
		{
			_metaId = value;
		}
		
		public function updateDefaultWidth():void
		{
			_width = 100;
			
			switch (_type)
			{
				case TableColumnDescriptionType.BOOL_VALUE:
					_width = 60;
					break;
				
				case TableColumnDescriptionType.ID:
					_width = 45;
					break;
				
				case TableColumnDescriptionType.COUNTER:
					_width = 60;
					break;
				
				case TableColumnDescriptionType.INT_VALUE:
					_width = 70;
					break;
				
				case TableColumnDescriptionType.LOCK:
					_width = 60;
					break;
				
				case TableColumnDescriptionType.INNER_TABLE:
				case TableColumnDescriptionType.FILE_PATH:
					_width = 250;
					break;
				
				case TableColumnDescriptionType.SELECT_SINGLE_ID:
					_width = 140;
					break;
				
				case TableColumnDescriptionType.STRING_VALUE:
				case TableColumnDescriptionType.STRING_MULTILINE:
					_width = 160;
					break;
				
				case TableColumnDescriptionType.DATE:
					_width = 200;
					break;
				
				case TableColumnDescriptionType.FLOAT_VALUE:
				case TableColumnDescriptionType.TEXT_PATTERN:
					break;
			}
		}
		
		//////////////////////////////
		
		public function copyFrom(src:TableColumnDescription):void
		{
			_type =				src._type;
			_tag =				src._tag;
			_lock =				src._lock;
			_mustBeNonEmpty =	src._mustBeNonEmpty;
			_name =				src._name;
			_description =		src._description;
			_useAsName =		src._useAsName;
			_width =			src._width;
			_idFrom =			src._idFrom;
			_textPattern =		src._textPattern;
			_filePath =			src._filePath;
			_fileExtension =	src._fileExtension;
			_fileImageSize =	src._fileImageSize;
			_defaultValue=		src._defaultValue;
			_metaId =			src._metaId;
		}
	}
}