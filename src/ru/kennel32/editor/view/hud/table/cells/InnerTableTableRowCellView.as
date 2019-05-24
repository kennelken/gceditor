package ru.kennel32.editor.view.hud.table.cells
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.AddInnerTableRowCommand;
	import ru.kennel32.editor.data.commands.DeleteInnerTableRowCommand;
	import ru.kennel32.editor.data.commands.EditInnerTableRowCommand;
	import ru.kennel32.editor.data.events.InnerTableEvent;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.factory.TablesRowCellsFactory;
	import ru.kennel32.editor.view.hud.table.TableColumnHeadView;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class InnerTableTableRowCellView extends BaseTableRowCellView
	{
		private var HEADS_HEIGHT:int = BaseTableRowCellView.DEFAULT_HEIGHT - 10;
		
		private var MAX_ROWS_H_MODE:int = 5;
		private var MAX_ROWS_V_MODE:int = 8;
		
		private var _boxHeads:Sprite;
		private var _boxRows:Sprite;
		
		private var _boxContent:CanvasSprite;
		private var _scrollCanvas:ScrollableCanvas;
		
		public function InnerTableTableRowCellView()
		{
			super();
			
			_boxContent = new CanvasSprite();
			
			_boxRows = new Sprite();
			_boxRows.y = HEADS_HEIGHT;
			_boxContent.addChild(_boxRows);
			
			_boxHeads = new Sprite();
			_boxContent.addChild(_boxHeads);
			
			_scrollCanvas = new ScrollableCanvas(true, true);
			addChild(_scrollCanvas);
			
			_scrollCanvas.setContent(_boxContent);
			_scrollCanvas.keepYConstFor = _boxHeads;
			
			_type = TableColumnDescriptionType.INNER_TABLE;
		}
		
		override public function updateValue():void 
		{
			var oldNumRows:int = _boxRows.numChildren;
			
			super.updateValue();
			
			redrawHeadIfRequired();
			redrawCellsIfRequired();
			
			updateHeight(false);
			
			attachContextMenu(this, false, false);
			
			_scrollCanvas.init();
			
			if (oldNumRows > 0 && _boxRows.numChildren > oldNumRows)
			{
				_scrollCanvas.focusOn(_boxRows.getChildAt(_boxRows.numChildren - 1));
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			resetHeads();
			resetRows();
			
			clearContextMenu(this);
			_scrollCanvas.dispose();
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_boxContent.setSize(ViewUtils.getCustomWidth(_boxContent), ViewUtils.getCustomHeight(_boxContent));
			_scrollCanvas.setSize(_width, _height - 2);
		}
		
		private function updateHeight(silent:Boolean = true):void
		{
			var data:Vector.<Array> = _tableRow.data[_columnIndex];
			
			var newHeight:int = HEADS_HEIGHT + Math.max(1, Math.min(MAX_ROWS_H_MODE, data.length)) * BaseTableRowCellView.DEFAULT_HEIGHT + 2;
			if (isVertical)
			{
				newHeight = HEADS_HEIGHT + MAX_ROWS_V_MODE * BaseTableRowCellView.DEFAULT_HEIGHT + 2;
			}
			if (_contentHeight != newHeight)
			{
				_contentHeight = newHeight;
				if (!silent)
				{
					dispatchHeightChanged();
				}
			}
			
			_scrollCanvas.updateControls(false);
		}
		
		private function redrawHeadIfRequired():void
		{
			var table:BaseTable = Main.instance.rootTable.cache.getTableById(_columnData.metaId);
			var meta:TableMeta = table == null ? null : table.meta;
			
			var needRedraw:Boolean = meta == null;
			if (!needRedraw)
			{
				needRedraw = (meta.columns.length - Hardcode.INNER_TABLE_SKIP_ID) != _boxHeads.numChildren;
			}
			if (!needRedraw)
			{
				for (var i:int = 0; i < _boxHeads.numChildren; i++)
				{
					var columnHeadView:TableColumnHeadView = _boxHeads.getChildAt(0) as TableColumnHeadView;
					if (columnHeadView.data != meta.columns[i + Hardcode.INNER_TABLE_SKIP_ID])
					{
						needRedraw = true;
						break;
					}
				}
			}
			
			if (needRedraw)
			{
				resetHeads();
				
				if (meta != null)
				{
					var currentX:int;
					for (i = Hardcode.INNER_TABLE_SKIP_ID; i < meta.columns.length; i++)
					{
						columnHeadView = new TableColumnHeadView(true, true);
						columnHeadView.data = meta.columns[i];
						columnHeadView.x = currentX;
						columnHeadView.setSize(meta.columns[i].width, HEADS_HEIGHT);
						currentX += columnHeadView.width;
						
						_boxHeads.addChild(columnHeadView);
					}
					
					attachContextMenu(_boxHeads, false);
				}
			}
		}
		
		private function redrawCellsIfRequired():void
		{
			var table:BaseTable = Main.instance.rootTable.cache.getTableById(_columnData.metaId);
			var meta:TableMeta = table == null ? null : table.meta;
			
			var data:Vector.<Array> = _tableRow.data[_columnIndex];
			
			var needRedraw:Boolean = meta == null;
			if (!needRedraw)
			{
				needRedraw = _boxRows.numChildren == 0 ||
					(_boxRows.getChildAt(0) as Sprite).numChildren != (meta.columns.length - Hardcode.INNER_TABLE_SKIP_ID) ||
					_boxRows.numChildren != data.length;
			}
			
			if (needRedraw)
			{
				resetRows();
				
				if (meta != null)
				{
					var currentY:int;
					for (var i:int = 0; i < data.length; i++)
					{
						var boxRow:Sprite = new Sprite();
						boxRow.y = currentY;
						currentY += DEFAULT_HEIGHT;
						_boxRows.addChild(boxRow);
						
						var currentX:int = 0;
						for (var j:int = Hardcode.INNER_TABLE_SKIP_ID; j < meta.columns.length; j++)
						{
							var cell:BaseTableRowCellView = TablesRowCellsFactory.instance.create(meta.columns[j], true, false);
							cell.x = currentX;
							cell.y = 0;
							currentX += meta.columns[j].width;
							boxRow.addChild(cell);
							
							cell.addEventListener(InnerTableEvent.VALUE_CHANGED, onInnerTableValueChanged);
							
							_contentHeight = 0;	//force size change
						}
					}
				}
			}
			
			for (i = 0; i < data.length; i++)
			{
				boxRow = _boxRows.getChildAt(i) as Sprite;
				attachContextMenu(boxRow, true);
				
				var rowDataSrc:Array = new Array(Hardcode.INNER_TABLE_SKIP_ID);
				rowDataSrc = rowDataSrc.concat(data[i]);
				
				var rowData:TableRow = new TableRow(table);
				rowData.data = rowDataSrc;
				
				for (j = 0; j < data[i].length; j++)
				{
					cell = boxRow.getChildAt(j) as BaseTableRowCellView;
					cell.init(rowData, j + Hardcode.INNER_TABLE_SKIP_ID);
				}
			}
		}
		
		private function resetHeads():void
		{
			while (_boxHeads.numChildren > 0)
			{
				var head:TableColumnHeadView = (_boxHeads.removeChildAt(0) as TableColumnHeadView);
				head.dispose();
				clearContextMenu(head);
			}
		}
		
		private function resetRows():void
		{
			while (_boxRows.numChildren > 0)
			{
				var row:Sprite = _boxRows.removeChildAt(0) as Sprite;
				while (row.numChildren > 0)
				{
					var cell:BaseTableRowCellView = row.removeChildAt(0) as BaseTableRowCellView;
					cell.removeEventListener(InnerTableEvent.VALUE_CHANGED, onInnerTableValueChanged);
					TablesRowCellsFactory.instance.release(cell);
				}
				clearContextMenu(row);
			}
		}
		
		private function onInnerTableValueChanged(e:InnerTableEvent):void
		{
			var cell:BaseTableRowCellView = e.currentTarget as BaseTableRowCellView;
			if (cell.parent == null)
			{
				return;
			}
			
			var innerRowIndex:int = _boxRows.getChildIndex(cell.parent);
			
			var innerColumnIndex:int = cell.columnIndex - Hardcode.INNER_TABLE_SKIP_ID;
			
			var data:Vector.<Array> = _tableRow.data[_columnIndex];
			
			Main.instance.commandsHistory.addCommandAndExecute(new EditInnerTableRowCommand(_tableRow, _columnIndex, innerRowIndex, innerColumnIndex, e.newValue));
		}
		
		//////////////////////////////////
		
		private function attachContextMenu(target:InteractiveObject, allowDelete:Boolean, recursive:Boolean = true):void
		{
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			
			var contextMenuItemAdd:ContextMenuItem = new ContextMenuItem(Texts.textAdd);
			contextMenu.customItems.push(contextMenuItemAdd);
			contextMenuItemAdd.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemAdd);
			
			var contextMenuItemDelete:ContextMenuItem = new ContextMenuItem(Texts.textDelete);
			contextMenu.customItems.push(contextMenuItemDelete);
			contextMenuItemDelete.enabled = allowDelete;
			contextMenuItemDelete.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemDelete);
			
			if (recursive)
			{
				recursiveAttachContextMenu(target, contextMenu);
			}
			else
			{
				target.contextMenu = contextMenu;
			}
		}
		
		private function recursiveAttachContextMenu(target:InteractiveObject, contextMenu:ContextMenu):void
		{
			target.contextMenu = contextMenu;
			
			var container:DisplayObjectContainer = target as DisplayObjectContainer;
			if (container != null)
			{
				for (var i:int = 0; i < container.numChildren; i++)
				{
					recursiveAttachContextMenu(container.getChildAt(i) as InteractiveObject, contextMenu);
				}
			}
		}
		
		private function clearContextMenu(target:InteractiveObject):void
		{
			target.contextMenu = null;
			
			var container:DisplayObjectContainer = target as DisplayObjectContainer;
			if (container != null)
			{
				for (var i:int = 0; i < container.numChildren; i++)
				{
					clearContextMenu(container.getChildAt(i) as InteractiveObject);
				}
			}
		}
		
		private function onContextMenuItemAdd(e:ContextMenuEvent):void
		{
			Main.instance.commandsHistory.addCommandAndExecute(new AddInnerTableRowCommand(_tableRow, _columnIndex));
		}
		
		private function onContextMenuItemDelete(e:ContextMenuEvent):void
		{
			var owner:InteractiveObject = e.contextMenuOwner;
			
			for (var i:int = 0; i < _boxRows.numChildren; i++)
			{
				var row:Sprite = _boxRows.getChildAt(i) as Sprite;
				if (row.contains(owner))
				{
					var rowIndex:int = _boxRows.getChildIndex(row);
					Main.instance.commandsHistory.addCommandAndExecute(new DeleteInnerTableRowCommand(_tableRow, _columnIndex, rowIndex));
					return;
				}
			}
		}
	}
}