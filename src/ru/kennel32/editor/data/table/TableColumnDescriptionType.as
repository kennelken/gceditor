package ru.kennel32.editor.data.table 
{
	public class TableColumnDescriptionType 
	{
		public static const ID:int =					1;
		public static const LOCK:int =					2;
		public static const COUNTER:int =				3;
		public static const STRING_VALUE:int =			4;
		public static const STRING_MULTILINE:int =		5;
		public static const INT_VALUE:int =				6;
		public static const FLOAT_VALUE:int =			7;
		public static const BOOL_VALUE:int =			8;
		public static const TEXT_PATTERN:int =			9;
		public static const SELECT_SINGLE_ID:int =		10;
		public static const INNER_TABLE:int =			11;
		public static const DATE:int =					12;
		public static const FILE_PATH:int =				13;
		
		public static const ALL:Vector.<uint> = Vector.<uint>([ID, LOCK, COUNTER, STRING_VALUE, STRING_MULTILINE, INT_VALUE, FLOAT_VALUE, BOOL_VALUE, TEXT_PATTERN, SELECT_SINGLE_ID, INNER_TABLE, DATE, FILE_PATH]);
		public static const ALL_BUT_SYSTEM:Vector.<uint> = Vector.<uint>([LOCK, STRING_VALUE, STRING_MULTILINE, INT_VALUE, FLOAT_VALUE, BOOL_VALUE, TEXT_PATTERN, SELECT_SINGLE_ID, INNER_TABLE, DATE, FILE_PATH]);
		public static const FOR_INNER_TABLE:Vector.<uint> = Vector.<uint>([STRING_VALUE, INT_VALUE, FLOAT_VALUE, BOOL_VALUE, SELECT_SINGLE_ID, DATE]);
		
		public static function isValuable(type:int):Boolean
		{
			return	type != LOCK &&
					type != TEXT_PATTERN &&
					type != FILE_PATH;
		}
	}
}