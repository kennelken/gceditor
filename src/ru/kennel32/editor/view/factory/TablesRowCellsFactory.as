package ru.kennel32.editor.view.factory 
{
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.view.hud.table.cells.BaseTableRowCellView;
	import ru.kennel32.editor.view.hud.table.cells.CheckBoxTableRowCellView;
	import ru.kennel32.editor.view.hud.table.cells.DateTableRowCellView;
	import ru.kennel32.editor.view.hud.table.cells.FilePathTableRowCellView;
	import ru.kennel32.editor.view.hud.table.cells.InnerTableTableRowCellView;
	import ru.kennel32.editor.view.hud.table.cells.SelectIdTableRowCellView;
	import ru.kennel32.editor.view.hud.table.cells.TextInputMultilineTableRowCellView;
	import ru.kennel32.editor.view.hud.table.cells.TextInputTableRowCellView;
	import ru.kennel32.editor.view.hud.table.cells.TextPatternTableRowCellView;
	
	public class TablesRowCellsFactory 
	{
		private var _viewClassByDataType:Object;
		
		private static var _instance:TablesRowCellsFactory;
		public static function get instance():TablesRowCellsFactory
		{
			if (_instance == null)
			{
				_instance = new TablesRowCellsFactory();
			}
			
			return _instance;
		}
		
		public function TablesRowCellsFactory()
		{
			_viewClassByDataType = new Object();
			_viewClassByDataType[TableColumnDescriptionType.LOCK]				=
			_viewClassByDataType[TableColumnDescriptionType.BOOL_VALUE]			= CheckBoxTableRowCellView;
			_viewClassByDataType[TableColumnDescriptionType.DATE]				= DateTableRowCellView;
			_viewClassByDataType[TableColumnDescriptionType.SELECT_SINGLE_ID]	= SelectIdTableRowCellView;
			_viewClassByDataType[TableColumnDescriptionType.INNER_TABLE]		= InnerTableTableRowCellView;
			_viewClassByDataType[TableColumnDescriptionType.TEXT_PATTERN]		= TextPatternTableRowCellView;
			_viewClassByDataType[TableColumnDescriptionType.STRING_MULTILINE]	= TextInputMultilineTableRowCellView;
			_viewClassByDataType[TableColumnDescriptionType.FILE_PATH]			= FilePathTableRowCellView;
			for each (var type:int in TableColumnDescriptionType.ALL)
			{
				if (_viewClassByDataType[type] === undefined)
				{
					_viewClassByDataType[type] = TextInputTableRowCellView;
				}
			}
		}
		
		public function create(data:TableColumnDescription, isInnerTableCell:Boolean, isVertical:Boolean):BaseTableRowCellView
		{
			var res:BaseTableRowCellView = ObjectsPool.getItem(_viewClassByDataType[data.type]) as BaseTableRowCellView;
			
			if (res is TextInputTableRowCellView)
			{
				(res as TextInputTableRowCellView).isInnerTableCell = isInnerTableCell;
			}
			
			res.isVertical = isVertical;
			res.columnData = data;
			
			return res;
		}
		
		public function release(row:BaseTableRowCellView):void
		{
			ObjectsPool.release(row);
		}
	}
}