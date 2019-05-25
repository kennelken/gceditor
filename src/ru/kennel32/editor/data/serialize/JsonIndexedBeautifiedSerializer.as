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
	import ru.kennel32.editor.data.table.TableType;
	import ru.kennel32.editor.data.serialize.ITableSerializer;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class JsonIndexedBeautifiedSerializer implements ITableSerializer
	{
		public function JsonIndexedBeautifiedSerializer()
		{
		}
		
		public function get basicType():int
		{
			return SerializeBasicType.JSON;
		}
		public function get type():int
		{
			return SerializerType.JSON_INDEXED_BEAUTIFIED;
		}
		public function get fileExtension():String
		{
			return "json";
		}
		
		protected function tryToGetType(rawData:Object):int
		{
			try
			{
				return rawData[0][1][0][1];
			}
			catch (e:Error)
			{
				return -1;
			}
		}
		
		public function serializeTable(src:BaseTable, onlyBasic:Boolean = false):SerializerParams
		{
			var res:SerializerParams = new SerializerParams();
			res.table = src;
			
			res.rawData = serializeTableBody(src);
			res.basicSerializerType = basicType;
			res.serializerType = type;
			
			if (!onlyBasic)
			{
				res.source = JSON.stringify(res.rawData, null, jsonSpace);
			}
			
			return res;
		}
		
		protected function get jsonSpace():String
		{
			return "\t";
		}
		
		protected function serializeTableBody(src:BaseTable):Object
		{
			var res:Object = newNode()
			
			addProp(res, 'meta', serializeMeta(src.meta))
			
			var dataTable:DataTable = src as DataTable;
			if (dataTable != null)
			{
				var rows:Array = [];
				addProp(res, 'rows', rows);
				for each (var row:TableRow in dataTable.rows)
				{
					rows.push(serializeRow(row, src.meta.allColumns));
				}
			}
			
			var containerTable:ContainerTable = src as ContainerTable;
			if (containerTable != null)
			{
				addChildrenTables(containerTable, res);
			}
			
			return res;
		}
		
		protected function addChildrenTables(containerTable:ContainerTable, res:Object):void
		{
			var children:Array = [];
			addProp(res, 'children', children);
			for each (var child:BaseTable in containerTable.children)
			{
				children.push(serializeTableBody(child));
			}
		}
		
		public function serializeMeta(src:TableMeta):Object
		{
			var res:Object = newNode();
			
			if (Hardcode.isRootMeta(src))
			{
				addProp(res, 'serializer', type, true);
			}
			addProp(res, 'id', src.id);
			addProp(res, 'type', src.type, true);
			addProp(res, 'counterId', src.counterId);
			addProp(res, 'tag', src.tag);
			addProp(res, 'name', src.name);
			addProp(res, 'description', src.description);
			addProp(res, 'lock', ParseUtils.writeBool(src.lock));
			addProp(res, 'forInnerTable', ParseUtils.writeBool(src.forInnerTable));
			
			var columns:Array = [];
			addProp(res, 'columns', columns);
			for each (var column:TableColumnDescription in src.columns)
			{
				columns.push(serializeColumn(column));
			}
			
			return res;
		}
		
		public function serializeColumn(src:TableColumnDescription):Object
		{
			var res:Object = newNode();
			
			addProp(res, 'type', src.type, true);
			addProp(res, 'tag', src.tag);
			addProp(res, 'lock', ParseUtils.writeBool(src.lock));
			addProp(res, 'mustBeNonEmpty', ParseUtils.writeBool(src.mustBeNonEmpty));
			addProp(res, 'name', src.name);
			addProp(res, 'description', src.description);
			addProp(res, 'useAsName', ParseUtils.writeBool(src.useAsName));
			addProp(res, 'width', src.width);
			addProp(res, 'idFrom', src.idFrom);
			addProp(res, 'textPattern', src.textPattern);
			if (src.filePath != null && src.filePath.length > 0 || src.fileExtension != null && src.fileExtension.length > 0 || src.fileImageSize != null && (src.fileImageSize[0] > 0 || src.fileImageSize[1] > 0))
			{
				addProp(res, 'filePath', src.filePath + ';' + src.fileExtension + ';' + src.fileImageSize.join(','));
			}
			addProp(res, 'defaultValue', src.defaultValue);
			addProp(res, 'metaId', src.metaId);
			
			return res;
		}
		
		public function serializeRow(src:TableRow, columns:Vector.<TableColumnDescription>):Object
		{
			var res:Array = new Array();
			
			for (var i:int = 0; i < src.data.length; i++)
			{
				var column:TableColumnDescription = columns[i];
				if (column.type == TableColumnDescriptionType.INNER_TABLE)
				{
					var table:DataTable = Main.instance.rootTable.cache.getTableById(column.metaId) as DataTable;
					if (table != null)
					{
						res.push(ParseUtils.writeInnerTable(src.data[i], table.meta.columns));
					}
					else
					{
						res.push('');
					}
				}
				else
				{
					res.push(ParseUtils.writeValue(src.data[i], column.type));
				}
			}
			
			return res;
		}
		
		protected function newNode():Object
		{
			return new Array();
		}
		protected function addProp(obj:Object, prop:String, value:Object, isRequired:Boolean = false):void
		{
			if (!isRequired && isDefaultValue(value))
			{
				return;
			}
			
			obj.push([prop, value]);
		}
		
		protected function isDefaultValue(value:Object):Boolean
		{
			return value === null || value === 0 || value === '' || value == '0';
		}
		
		//////////////////////
		
		protected var _cacheInnerTablesMeta:Object;
		
		public function deserializeTable(src:SerializerParams, onlyBasic:Boolean = true):SerializerParams
		{
			try
			{
				if (src.rawData == null)
				{
					src.rawData = JSON.parse(src.source);
					src.basicSerializerType = basicType;
				}
				
				if (onlyBasic)
				{
					if (tryToGetType(src.rawData) == type)
					{
						src.serializerType = type;
					}
					return src;
				}
			}
			catch (e:Error)
			{
				return src;
			}
			
			if (tryToGetType(src.rawData) != type)
			{
				return src;
			}
			
			src.serializerType = type;
			
			_cacheInnerTablesMeta = buildInnerTablesMetaCache(src.rawData, new Object());
			
			src.table = deserializeTableBody(src.rawData, null);
			
			_cacheInnerTablesMeta = null;
			
			return src;
		}
		
		protected function deserializeTableBody(src:Object, parent:ContainerTable):BaseTable
		{
			var srcMap:Object = convertToMap(src);
			
			var meta:TableMeta = deserializeMeta(srcMap['meta']);
			if (_cacheInnerTablesMeta[meta.id] != null)
			{
				meta = _cacheInnerTablesMeta[meta.id];
			}
			
			var res:BaseTable = meta.type == TableType.BASIC ? new DataTable(meta) : new ContainerTable(meta);
			res.parent = parent;
			if (res.parent != null)
			{
				meta.updateParentColumnsForNewTable(res.parent.meta);
			}
			
			var dataTable:DataTable = res as DataTable;
			if (dataTable != null)
			{
				var rows:Vector.<TableRow> = new Vector.<TableRow>();
				
				var rowsData:Array = srcMap['rows'];
				for (var i:int = 0; i < rowsData.length; i++)
				{
					var row:TableRow = deserializeRow(rowsData[i], meta.allColumns, dataTable);
					row.index = i;
					rows.push(row);
				}
				
				dataTable.addRows(rows);
			}
			
			var containerTable:ContainerTable = res as ContainerTable;
			if (containerTable != null)
			{
				containerTable.addChildren(deserializeChildren(srcMap, containerTable, new Vector.<BaseTable>()));
			}
			
			return res;
		}
		
		protected function deserializeChildren(srcMap:Object, containerTable:ContainerTable, result:Vector.<BaseTable>):Vector.<BaseTable>
		{
			var childrenData:Array = srcMap['children'];
			for (var i:int = 0; i < childrenData.length; i++)
			{
				var child:Object = childrenData[i];
				var childTable:BaseTable = deserializeTableBody(child, containerTable);
				childTable.index = i;
				result.push(childTable);
			}
			
			return result;
		}
		
		private function buildInnerTablesMetaCache(src:Object, cache:Object):Object
		{
			var srcMap:Object = convertToMap(src);
			
			var meta:TableMeta = deserializeMeta(srcMap['meta']);
			
			if (meta.forInnerTable)
			{
				cache[meta.id] = meta;
			}
			
			var childrenData:Array = srcMap['children'];
			for each (var child:Object in childrenData)
			{
				buildInnerTablesMetaCache(child, cache);
			}
			
			return cache;
		}
		
		public function deserializeMeta(src:Object):TableMeta
		{
			var srcMap:Object = convertToMap(src);
			
			var res:TableMeta = TableMeta.create(srcMap['id'], srcMap['type'], srcMap['tag'], srcMap['counterId']);
			res.name = srcMap['name'];
			res.description = srcMap['description'];
			res.lock = ParseUtils.readBool(srcMap['lock']);
			res.forInnerTable = ParseUtils.readBool(srcMap['forInnerTable']);
			
			for each (var columnData:Object in srcMap['columns'])
			{
				res.columns.push(deserializeColumn(columnData));
			}
			
			return res;
		}
		
		public function deserializeColumn(src:Object):TableColumnDescription
		{
			var srcMap:Object = convertToMap(src);
			
			var res:TableColumnDescription = new TableColumnDescription();
			res.type = int(srcMap['type']);
			res.tag = srcMap['tag'];
			res.lock = ParseUtils.readBool(srcMap['lock']);
			res.mustBeNonEmpty = ParseUtils.readBool(srcMap['mustBeNonEmpty']);
			res.name = srcMap['name'];
			res.description = srcMap['description'];
			res.useAsName = ParseUtils.readBool(srcMap['useAsName']);
			res.width = int(srcMap['width']);
			res.idFrom = int(srcMap['idFrom']);
			res.textPattern = srcMap['textPattern'];
			
			res.defaultValue = srcMap['defaultValue'];
			if (res.defaultValue == null)
			{
				res.defaultValue = TableColumnDescription.getDefaultValue(res.type);
			}
			res.metaId = srcMap['metaId'];
			
			
			if (srcMap['filePath'] == null)
			{
				srcMap['filePath'] = '';
			}
			var filePathRaw:Array = (srcMap['filePath'] as String).split(';');
			res.filePath = filePathRaw.length > 0 ? filePathRaw[0] : '';
			res.fileExtension = filePathRaw.length > 1 ? filePathRaw[1] : '';
			res.fileImageSize = filePathRaw.length > 2 ? Vector.<uint>((filePathRaw[2] as String).split(',')) : new Vector.<uint>();
			res.fileImageSize.length = 2;
			
			return res;
		}
		
		public function deserializeRow(src:Object, columns:Vector.<TableColumnDescription>, parent:DataTable):TableRow
		{
			var res:TableRow = parent.meta.getColumnIndexByType(TableColumnDescriptionType.COUNTER) > -1 ? new Counter(parent) : new TableRow(parent);
			
			var srcArray:Array = src as Array;
			
			for (var i:int = 0; i < srcArray.length; i++)
			{
				var column:TableColumnDescription = columns[i];
				if (column.type == TableColumnDescriptionType.INNER_TABLE)
				{
					var meta:TableMeta = _cacheInnerTablesMeta[column.metaId];
					if (meta != null)
					{
						res.data.push(ParseUtils.readInnerTable(srcArray[i], meta.columns));
					}
					else
					{
						res.data.push(new Vector.<Array>());
					}
				}
				else
				{
					res.data.push(ParseUtils.readValue(srcArray[i], columns[i].type));
				}
			}
			
			return res;
		}
		
		protected function convertToMap(src:Object):Object
		{
			var res:Object = new Object();
			
			for each (var entry:Array in src)
			{
				res[entry[0]] = entry[1];
			}
			
			return res;
		}
	}
}