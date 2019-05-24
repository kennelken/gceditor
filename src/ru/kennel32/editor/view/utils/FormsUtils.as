package ru.kennel32.editor.view.utils
{
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	
	public class FormsUtils
	{
		public static function getTableColumnDescriptionTypesNames(types:Vector.<uint>):Vector.<String>
		{
			var res:Vector.<String> = new Vector.<String>();
			for each (var type:uint in types)
			{
				switch (type)
				{
					case TableColumnDescriptionType.BOOL_VALUE:
						res.push("boolean value");
						break;
					
					case TableColumnDescriptionType.COUNTER:
						res.push("counter");
						break;
					
					case TableColumnDescriptionType.FLOAT_VALUE:
						res.push("float value");
						break;
					
					case TableColumnDescriptionType.ID:
						res.push("id");
						break;
					
					case TableColumnDescriptionType.INT_VALUE:
						res.push("int value");
						break;
					
					case TableColumnDescriptionType.LOCK:
						res.push("lock");
						break;
					
					case TableColumnDescriptionType.INNER_TABLE:
						res.push("inner table");
						break;
					
					case TableColumnDescriptionType.SELECT_SINGLE_ID:
						res.push("select item");
						break;
					
					case TableColumnDescriptionType.STRING_VALUE:
						res.push("string value");
						break;
					
					case TableColumnDescriptionType.STRING_MULTILINE:
						res.push("string multiline");
						break;
					
					case TableColumnDescriptionType.TEXT_PATTERN:
						res.push("text pattern");
						break;
					
					case TableColumnDescriptionType.FILE_PATH:
						res.push("file path");
						break;
					
					case TableColumnDescriptionType.DATE:
						res.push("date");
						break;
					
					default:
						throw new Error('unexpected column type');
				}
			}
			
			return res;
		}
		
		public static function collectionToVector(src:*):Vector.<Object>
		{
			var res:Vector.<Object> = new Vector.<Object>();
			for each (var item:Object in src)
			{
				res.push(item);
			}
			return res;
		}
	}
}