package ru.kennel32.editor.data.serialize
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class JsonAssociativeSerializer extends JsonIndexedBeautifiedSerializer
	{
		public function JsonAssociativeSerializer()
		{
		}
		
		override public function get type():int
		{
			return SerializerType.JSON_ASSOCIATIVE;
		}
		
		override protected function get jsonSpace():String
		{
			return null;
		}
		
		override protected function tryToGetType(rawData:Object):int
		{
			try
			{
				return rawData['meta']['serializer'];
			}
			catch (e:Error)
			{
				return -1;
			}
		}
		
		override protected function addChildrenTables(containerTable:ContainerTable, res:Object):void 
		{
			for each (var child:BaseTable in containerTable.children)
			{
				if (child.meta.tag != null && child.meta.tag != '')
				{
					addProp(res, child.meta.tag, serializeTableBody(child));
				}
			}
		}
		
		override protected function newNode():Object 
		{
			return new Object();
		}
		
		override protected function addProp(obj:Object, prop:String, value:Object, isRequired:Boolean = false):void 
		{
			if (!isRequired && isDefaultValue(value))
			{
				return;
			}
			
			obj[prop] = value;
		}
		
		override public function serializeRow(src:TableRow, columns:Vector.<TableColumnDescription>):Object 
		{
			var res:Object = new Object();
			
			for (var i:int = 0; i < src.data.length; i++)
			{
				var column:TableColumnDescription = columns[i];
				if (column.tag == null || column.tag == "")
				{
					continue;
				}
				
				if (column.type == TableColumnDescriptionType.INNER_TABLE)
				{
					var table:DataTable = Main.instance.rootTable.cache.getTableById(column.metaId) as DataTable;
					res[column.tag] = table == null ? '' : ParseUtils.writeInnerTable(src.data[i], table.meta.columns);
				}
				else
				{
					res[column.tag] = ParseUtils.writeValue(src.data[i], column.type);
				}
			}
			
			return res;
		}
		
		override public function deserializeRow(src:Object, columns:Vector.<TableColumnDescription>, parent:DataTable):TableRow 
		{
			var res:TableRow = parent.meta.getColumnIndexByType(TableColumnDescriptionType.COUNTER) > -1 ? new Counter(parent) : new TableRow(parent);
			
			res.data.length = columns.length;
			for (var tag:String in src)
			{
				for (var i:int = 0; i < columns.length; i++)
				{
					var column:TableColumnDescription = columns[i];
					if (column.tag == tag)
					{
						if (column.type == TableColumnDescriptionType.INNER_TABLE)
						{
							var meta:TableMeta = _cacheInnerTablesMeta[column.metaId];
							if (meta != null)
							{
								res.data[i] = ParseUtils.readInnerTable(src[tag], meta.columns);
							}
							else
							{
								res.data[i] = new Vector.<Array>();
							}
						}
						else
						{
							res.data[i] = ParseUtils.readValue(src[tag], columns[i].type);
						}
						break;
					}
				}
			}
			
			return res;
		}
		
		override protected function convertToMap(src:Object):Object 
		{
			return src;
		}
		
		override protected function deserializeChildren(srcMap:Object, containerTable:ContainerTable, result:Vector.<BaseTable>):Vector.<BaseTable>
		{
			var i:int = 0;
			for (var prop:String in srcMap)
			{
				if (prop == 'rows' || prop == 'meta')
				{
					continue;
				}
				
				var child:Object = srcMap[prop];
				var childTable:BaseTable = deserializeTableBody(child, containerTable);
				childTable.index = i;
				result.push(childTable);
				
				i++;
			}
			
			return result;
		}
	}
}