package ru.kennel32.editor.view.hud.table
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.DeselectRowCommand;
	import ru.kennel32.editor.data.commands.InspectRowCommand;
	import ru.kennel32.editor.data.commands.SelectRowCommand;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.events.TableCellEvent;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.controls.CheckBox;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.factory.TablesRowCellsFactory;
	import ru.kennel32.editor.view.forms.dialog.content.InspectRowDialogContent;
	import ru.kennel32.editor.view.hud.table.cells.BaseTableRowCellView;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class TableRowView extends CanvasSprite implements IDisposable
	{
		private var _checkBoxRegion:ExpandableRegion;
		private var _checkBox:CheckBox;
		private var _data:TableRow;
		
		private var _contentHeight:int;
		private var _cells:Vector.<BaseTableRowCellView>;
		protected var _boxCells:CanvasSprite;
		
		private var _isVertical:Boolean;
		
		public function TableRowView(isVertical:Boolean = false)
		{
			super(true);
			_isVertical = isVertical;
			
			if (!_isVertical)
			{
				_checkBoxRegion = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.COLUMN_HEAD_STATIC);
				_checkBoxRegion.setSize(TableView.CHECKBOX_COLUMN_WIDTH, BaseTableRowCellView.DEFAULT_HEIGHT);
				addChild(_checkBoxRegion);
				
				_checkBox = new CheckBox(17);
				_checkBox.x = ((_checkBoxRegion.width - _checkBox.width) / 2) - 1;
				_checkBox.addEventListener(Event.CHANGE, onCheckBoxChanged);
				addChild(_checkBox);
			}
			
			_cells = new Vector.<BaseTableRowCellView>();
			
			_boxCells = new CanvasSprite();
			_boxCells.x = _checkBoxRegion != null ? _checkBoxRegion.width : 0;
			_boxCells.cacheAsBitmap = true;
			addChild(_boxCells);
			
			cacheAsBitmap = true;
		}
		
		public function set data(value:TableRow):void
		{
			if (_data == value)
			{
				return;
			}
			
			cleanup();
			
			_data = value;
			
			if (_data == null)
			{
				return;
			}
			
			_data.addEventListener(Event.CHANGE, onDataChange);
			_data.addEventListener(TableEvent.ROW_CHECKED_CHANGED, onCheckedChanged);
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			_contentHeight = BaseTableRowCellView.DEFAULT_HEIGHT;
			
			var allColumns:Vector.<TableColumnDescription> = _data.parent.meta.allColumns;
			for (var i:int = 0; i < allColumns.length; i++)
			{
				var cell:BaseTableRowCellView = TablesRowCellsFactory.instance.create(allColumns[i], false, _isVertical);
				cell.addEventListener(TableCellEvent.HEIGHT_CHANGED, onCellHeightChanged);
				cell.init(_data, i);
				_boxCells.addChild(cell);
				_cells.push(cell);
			}
			
			if (!_isVertical)
			{
				_checkBox.checked = _data.checked;
			}
			updateColumnsPositions();
			
			onCellHeightChanged(null);
		}
		public function get data():TableRow
		{
			return _data;
		}
		
		private function cleanup():void
		{
			_contentHeight = 0;
			
			if (_data != null)
			{
				_data.removeEventListener(Event.CHANGE, onDataChange);
				_data.removeEventListener(TableEvent.ROW_CHECKED_CHANGED, onCheckedChanged);
			}
			
			removeEventListener(MouseEvent.CLICK, onMouseClick);
			
			while (_cells.length > 0)
			{
				var cell:BaseTableRowCellView = _cells.pop();
				
				cell.removeEventListener(TableCellEvent.HEIGHT_CHANGED, onCellHeightChanged);
				TablesRowCellsFactory.instance.release(cell);
			}
		}
		
		public function dispose():void
		{
			cleanup();
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			if (_isVertical)
			{
				for (var i:int = 0; i < _cells.length; i++)
				{
					_cells[i].setSize(width, _cells[i].contentHeight);
				}
			}
			else
			{
				_checkBoxRegion.setSize( -1, _height);
				_checkBox.y = ((_checkBoxRegion.height - _checkBox.height) / 2) - 1;
				
				for (i = 0; i < _cells.length; i++)
				{
					_cells[i].setSize(-1, height);
				}
			}
			
			_boxCells.setSize(_width - _boxCells.x, _height);
		}
		
		public function get checked():Boolean
		{
			return _checkBox.checked;
		}
		
		public function updateColumnsPositions():void
		{
			var currentPos:int;
			var maxWidth:int;
			
			var allColumns:Vector.<TableColumnDescription> = _data.parent.meta.allColumns;
			
			for (var i:int = 0; i < allColumns.length; i++)
			{
				maxWidth = Math.max(maxWidth, allColumns[i].width);
			}
			maxWidth *= _isVertical ? 1.5 : 1;
			
			for (i = 0; i < allColumns.length; i++)
			{
				var cell:BaseTableRowCellView = _cells[i];
				cell.updateWidth();
				if (_isVertical)
				{
					cell.x = 0;
					cell.y = currentPos;
					currentPos += cell.contentHeight;
				}
				else
				{
					cell.x = currentPos;
					cell.y = 0;
					currentPos += cell.width;
				}
			}
			
			setSize(_isVertical ? maxWidth : (_boxCells.x + currentPos), _contentHeight);
		}
		
		private function onDataChange(e:Event):void
		{
			var allColumns:Vector.<TableColumnDescription> = _data.parent.meta.allColumns;
			for (var i:int = 0; i < allColumns.length; i++)
			{
				var cell:BaseTableRowCellView = _boxCells.getChildAt(i) as BaseTableRowCellView;
				cell.updateValue();
			}
			
			dispatchEvent(new Event(Event.RESIZE, false));
			
			Main.instance.mainUI.playAttentionEffect(this);
		}
		
		private function onCheckBoxChanged(e:Event):void
		{
			Main.instance.commandsHistory.addCommandAndExecute(_checkBox.checked ? new SelectRowCommand(_data, null, _data.checked) : new DeselectRowCommand(_data, null, _data.checked));
		}
		
		private function onCheckedChanged(e:Event):void
		{
			if (!_isVertical)
			{
				_checkBox.checked = _data.checked;
			}
		}
		
		private function onCellHeightChanged(e:Event):void
		{
			_contentHeight = _isVertical ? 0 : BaseTableRowCellView.DEFAULT_HEIGHT;
			
			for (var i:int = 0; i < _cells.length; i++)
			{
				_contentHeight = Math.max(_contentHeight, _cells[i].contentHeight + (_isVertical ? _contentHeight : 0));
			}
			setSize(-1, _contentHeight);
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (!ViewUtils.isForInspect(e) || _isVertical)
			{
				return;
			}
			
			e.preventDefault();
			e.stopImmediatePropagation();
			
			InspectRowDialogContent.showRow(_data);
		}
		
		public function get boxCells():Sprite
		{
			return _boxCells;
		}
	}
}