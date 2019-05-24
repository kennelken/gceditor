package ru.kennel32.editor.data.utils
{
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	
	public class ParseUtils
	{
		public static function readValue(value:String, type:int, columns:Vector.<TableColumnDescription> = null):*
		{
			switch (type)
			{
				case TableColumnDescriptionType.BOOL_VALUE:
				case TableColumnDescriptionType.LOCK:
					return readBool(value);
				
				case TableColumnDescriptionType.COUNTER:
				case TableColumnDescriptionType.INT_VALUE:
				case TableColumnDescriptionType.ID:
				case TableColumnDescriptionType.SELECT_SINGLE_ID:
				case TableColumnDescriptionType.DATE:
					return int(value);
				
				case TableColumnDescriptionType.FLOAT_VALUE:
					return readFloat(value);
					
				case TableColumnDescriptionType.STRING_VALUE:
				case TableColumnDescriptionType.STRING_MULTILINE:
				case TableColumnDescriptionType.TEXT_PATTERN:
				case TableColumnDescriptionType.FILE_PATH:
					return value == null ? '' : value;
			}
			
			throw new Error("Unexpected type in ParseUtils.readValue");
			return 0;
		}
		
		private static var _newLineOptions:Vector.<String> = Vector.<String>(['\r\n', '\n\r', '\r', '\n']);
		private static var _requiredNewLineSymbol:String = '\n';
		
		public static function writeValue(value:*, type:int):String
		{
			switch (type)
			{
				case TableColumnDescriptionType.BOOL_VALUE:
				case TableColumnDescriptionType.LOCK:
					return writeBool(value).toString();
				
				case TableColumnDescriptionType.COUNTER:
				case TableColumnDescriptionType.INT_VALUE:
				case TableColumnDescriptionType.ID:
				case TableColumnDescriptionType.SELECT_SINGLE_ID:
				case TableColumnDescriptionType.DATE:
					return value.toString();
				
				case TableColumnDescriptionType.FLOAT_VALUE:
					return readFloat(value).toString();
				
				case TableColumnDescriptionType.STRING_VALUE:
				case TableColumnDescriptionType.TEXT_PATTERN:
				case TableColumnDescriptionType.FILE_PATH:
					return value == null ? '' : String(value);
				
				case TableColumnDescriptionType.STRING_MULTILINE:
					var str:String = value as String;
					if (str == null)
					{
						return str;
					}
					
					var newLineSymbol:String = '__NEW_LINE__';
					for each (var newLineOption:String in _newLineOptions)
					{
						while (str.indexOf(newLineOption) > -1)
						{
							str = str.replace(newLineOption, newLineSymbol);
						}
					}
					while (str.indexOf(newLineSymbol) > -1)
					{
						str = str.replace(newLineSymbol, _requiredNewLineSymbol);
					}
					return str;
			}
			
			throw new Error("Unexpected type in ParseUtils.readValue");
			return null;
		}
		
		public static function readBool(value:Object):Boolean
		{
			return int(value) > 0;
		}
		public static function writeBool(value:Boolean):int
		{
			return value ? 1 : 0;
		}
		
		public static function readFloat(value:Object):Number
		{
			var res:Number = Number(value);
			return isNaN(res) ? 0 : res;
		}
		
		public static function readInnerTable(value:String, columns:Vector.<TableColumnDescription>):Vector.<Array>
		{
			var res:Vector.<Array> = new Vector.<Array>();
			
			if (value != null && value.length > 0)
			{
				var array:Array = value.split(';');
				
				for (var i:int = 0; i < array.length; i++)
				{
					var subArray:Array = array[i].split(',');
					res.push(new Array());
					
					for (var j:int = Hardcode.INNER_TABLE_SKIP_ID; j < columns.length; j++)
					{
						var column:TableColumnDescription = columns[j];
						var cellValue:* = (j - Hardcode.INNER_TABLE_SKIP_ID) < subArray.length ? subArray[j - Hardcode.INNER_TABLE_SKIP_ID] : column.defaultValue;
						
						res[i].push(readValue(cellValue, column.type));
					}
				}
			}
			
			return res;
		}
		
		public static function writeInnerTable(value:Vector.<Array>, columns:Vector.<TableColumnDescription>):String
		{
			var listData:Vector.<Array> = value;
			var res:String = '';
			
			var lastI:int = listData.length - 1;
			for (var i:int = 0; i < listData.length; i++)
			{
				var lastJ:int = listData[i].length - 1;
				for (var j:int = 0; j < listData[i].length; j++)
				{
					res += writeValue(listData[i][j], columns[j + Hardcode.INNER_TABLE_SKIP_ID].type) + (j < lastJ ? ',' : '');
				}
				res += (i < lastI ? ';' : '');
			}
			return res;
		}
	}
}