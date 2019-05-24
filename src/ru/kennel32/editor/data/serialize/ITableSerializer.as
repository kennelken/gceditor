package ru.kennel32.editor.data.serialize
{
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	
	public interface ITableSerializer
	{
		function get basicType():int;
		function get type():int;
		function get fileExtension():String;
		
		function serializeTable(src:BaseTable, onlyBasic:Boolean = false):SerializerParams;
		function serializeMeta(src:TableMeta):Object;
		function serializeColumn(src:TableColumnDescription):Object;
		function serializeRow(src:TableRow, columns:Vector.<TableColumnDescription>):Object;
		
		function deserializeTable(src:SerializerParams, onlyBasic:Boolean = false):SerializerParams;
		function deserializeMeta(src:Object):TableMeta;
		function deserializeColumn(src:Object):TableColumnDescription;
		function deserializeRow(src:Object, columns:Vector.<TableColumnDescription>, parent:DataTable):TableRow;
	}
}