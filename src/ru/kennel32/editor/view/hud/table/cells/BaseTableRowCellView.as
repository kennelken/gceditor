package ru.kennel32.editor.view.hud.table.cells
{
	import flash.events.Event;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.events.AppEvent;
	import ru.kennel32.editor.data.events.InnerTableEvent;
	import ru.kennel32.editor.data.events.TableCellEvent;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	
	[Event(name="valuechanged", type="ru.kennel.editor.data.events.InnerTableEvent")]
	public class BaseTableRowCellView extends CanvasSprite implements IDisposable
	{
		public static const DEFAULT_HEIGHT:int = 30;
		public static const DEFAULT_TF_HEIGHT:int = 24;
		
		protected var _region:ExpandableRegion;
		
		protected var _tableRow:TableRow;
		protected var _columnIndex:int;
		
		protected var _columnData:TableColumnDescription;
		
		protected var _type:int;
		public function get type():int
		{
			return _type;
		}
		
		protected var _isVertical:Boolean;
		public function get isVertical():Boolean
		{
			return _isVertical;
		}
		public function set isVertical(value:Boolean):void
		{
			_isVertical = value;
		}
		
		public function BaseTableRowCellView()
		{
			_region = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.CELL_REGULAR);
			addChild(_region);
			
			_contentHeight = DEFAULT_HEIGHT;
			
			super();
		}
		
		public function get rowData():TableRow
		{
			return _tableRow;
		}
		public function get columnIndex():int
		{
			return _columnIndex;
		}
		public function init(rowData:TableRow, columnIndex:int):void
		{
			_tableRow = rowData;
			_columnIndex = columnIndex;
			
			setSize(_columnData.width, DEFAULT_HEIGHT);
			updateValue();
			
			Main.instance.addEventListener(AppEvent.BEFORE_SAVE, doBeforeSave);
			Main.instance.addEventListener(AppEvent.BEFORE_COMMAND, doBeforeSave);
		}
		
		protected function doBeforeSave(e:Event):void
		{
			//
		}
		
		public function get columnData():TableColumnDescription
		{
			return _columnData;
		}
		public function set columnData(value:TableColumnDescription):void
		{
			_columnData = value;
		}
		
		public function dispose():void
		{
			Main.instance.removeEventListener(AppEvent.BEFORE_SAVE, doBeforeSave);
			Main.instance.removeEventListener(AppEvent.BEFORE_COMMAND, doBeforeSave);
			_region.setSize(0, 0);
		}
		
		public function updateWidth(forceWidth:int = 0):void
		{
			setSize(forceWidth > 0 ? forceWidth : _columnData.width, -1);
		}
		
		public function updateValue():void
		{
			
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_region.setSize(_width, _height);
		}
		
		protected function get locked():Boolean
		{
			return _columnData.lock ||
				Hardcode.isLockedColumnData2(_tableRow.parent.meta, _columnData) ||
				(_tableRow.lock && _columnData.type != TableColumnDescriptionType.LOCK);
		}
		
		protected function dispatchHeightChanged():void
		{
			dispatchEvent(new TableCellEvent(TableCellEvent.HEIGHT_CHANGED));
		}
		
		protected var _contentHeight:int;
		public function get contentHeight():int
		{
			return _contentHeight;
		}
		
		protected function dispatchChangeInnerTableValue(value:*):Boolean
		{
			if (_tableRow.parent.meta.forInnerTable)
			{
				dispatchEvent(new InnerTableEvent(InnerTableEvent.VALUE_CHANGED, value));
				return true;
			}
			
			return false;
		}
	}
}