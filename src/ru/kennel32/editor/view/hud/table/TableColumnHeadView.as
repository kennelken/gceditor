package ru.kennel32.editor.view.hud.table 
{
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.commands.RemoveColumnCommand;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.components.tooltip.ColumnHeadTooltipView;
	import ru.kennel32.editor.view.components.tooltip.TooltipManager;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.forms.dialog.content.EditColumnDescriptionDialogContent;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class TableColumnHeadView extends CanvasSprite implements IDisposable
	{
		private var _region:ExpandableRegion;
		private var _regionLocked:ExpandableRegion;
		private var _tfName:TextField;
		private var _data:TableColumnDescription;
		private var _static:Boolean;
		private var _noContextMenu:Boolean;
		
		private var _contextMenu:ContextMenu;
		private var _contextMenuItemEdit:ContextMenuItem;
		private var _contextMenuItemAdd:ContextMenuItem;
		private var _contextMenuItemDelete:ContextMenuItem;
		
		public function TableColumnHeadView(isStatic:Boolean = false, noContextMenu:Boolean = false)
		{
			super();
			
			_static = isStatic;
			_noContextMenu = noContextMenu;
			
			_region = new ExpandableRegion(
				RectSides.SIDES_0101,
				_static ? RectSides.SIDES_0000 : RectSides.SIDES_0100,
				_static ? ExpandableRegionStyle.COLUMN_HEAD_STATIC : ExpandableRegionStyle.COLUMN_HEAD
			);
			addChild(_region);
			
			_regionLocked = new ExpandableRegion(
				RectSides.SIDES_0101,
				_static ? RectSides.SIDES_0000 : RectSides.SIDES_0100,
				ExpandableRegionStyle.COLUMN_HEAD_LOCKED
			);
			addChild(_regionLocked);
			_regionLocked.visible = false;
			
			_tfName = TextUtils.getText('', Color.FONT, 16, null, true, -3);
			_tfName.autoSize = TextFieldAutoSize.NONE;
			_tfName.mouseEnabled = false;
			addChild(_tfName);
			
			cacheAsBitmap = true;
		}
		
		public function set data(value:TableColumnDescription):void
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
			
			_region.init();
			_regionLocked.init();
			
			_region.visible = _static || !_data.lock;
			_regionLocked.visible = !_static && _data.lock;
			
			_tfName.text = _data.name;
			
			initContextMenu();
			TooltipManager.registerTooltip(this, _data, ColumnHeadTooltipView);
			
			setSize(-1, -1);
		}
		public function get data():TableColumnDescription
		{
			return _data;
		}
		
		public function initContextMenu():void
		{
			attachContextMenu();
		}
		
		private function cleanup():void
		{
			_region.visible = true;
			_regionLocked.visible = false;
			
			_region.dispose(); 
			_regionLocked.dispose();
			
			_tfName.text = '';
			
			clearContextMenu();
			TooltipManager.unregisterTooltip(this);
		}
		
		public function dispose():void
		{
			cleanup();
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_region.setSize(_width, _height);
			_regionLocked.setSize(_width, _height);
			
			_tfName.width = _width - 0 - 3;
			_tfName.height = _tfName.textHeight + 10;
			_tfName.y = ((_height - _tfName.height) / 2) + 1 + ((_tfName.numLines % 2 == 1 && _tfName.numLines > 4) ? -7 + (_tfName.numLines - 3) * 7 : 0);
			_tfName.x = Math.max(1, (_width - _tfName.textWidth) / 2) - 3;
			
			_tfName.width = _width - _tfName.x;
		}
		
		override public function set minWidth(value:int):void 
		{
			super.minWidth = value;
			_region.minWidth = value;
			_regionLocked.minWidth = value;
		}
		
		override public function set maxWidth(value:int):void 
		{
			super.maxWidth = value;
			_region.maxWidth = value;
			_regionLocked.maxWidth = value;
		}
		
		public function get preferredWidth():int
		{
			var oldTextWidth:int = _tfName.width;
			if (_tfName.numLines > 1)
			{
				_tfName.width = 2000;
			}
			var res:int = _tfName.textWidth + 20;
			_tfName.width = oldTextWidth;
			return res;
		}
		
		//////////////////////////////////
		
		private function attachContextMenu():void
		{
			if (_noContextMenu)
			{
				return;
			}
			
			_contextMenu = new ContextMenu();
			_contextMenu.addEventListener(Event.PREPARING, onContextMenuPreparing);
			
			_contextMenuItemEdit = new ContextMenuItem(Texts.textEdit);
			_contextMenu.customItems.push(_contextMenuItemEdit);
			_contextMenuItemEdit.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemEdit);
			
			_contextMenuItemAdd = new ContextMenuItem(Texts.textAdd);
			_contextMenu.customItems.push(_contextMenuItemAdd);
			_contextMenuItemAdd.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemAdd);
			
			_contextMenuItemDelete = new ContextMenuItem(Texts.textDelete);
			_contextMenu.customItems.push(_contextMenuItemDelete);
			_contextMenuItemDelete.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemDelete);
			
			updateEditAction();
			
			contextMenu = _contextMenu;
		}
		
		private function clearContextMenu():void
		{
			if (_contextMenu != null)
			{
				updateEditAction(true);
				
				_contextMenu.removeEventListener(Event.PREPARING, onContextMenuPreparing);
				
				_contextMenuItemEdit.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemEdit);
				_contextMenuItemAdd.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemAdd);
				_contextMenuItemDelete.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemDelete);
				
				contextMenu = null;
				_contextMenu = null;
				_contextMenuItemEdit = null;
				_contextMenuItemAdd = null;
				_contextMenuItemDelete = null;
			}
		}
		
		private function onContextMenuPreparing(e:Event):void
		{
			var selectedTable:BaseTable = Main.instance.selectedTable;
			
			updateEditAction();
			
			_contextMenuItemAdd.enabled = selectedTable.meta.counterId > 0;
			_contextMenuItemDelete.enabled = _contextMenuItemEdit.enabled;
		}
		
		private function updateEditAction(clear:Boolean = false):void
		{
			var selectedTable:BaseTable = Main.instance.selectedTable;
			
			if (_data == null || selectedTable == null)
			{
				_contextMenuItemEdit.enabled = false;
				removeEventListener(MouseEvent.CLICK, onMouseClick);
				return;
			}
			
			var index:int = selectedTable.meta.columns.indexOf(_data);
			
			var canEdit:Boolean = !clear && selectedTable.meta.columns.indexOf(_data) > -1 && !Hardcode.isLockedColumnMeta2(selectedTable.meta, _data);
			
			_contextMenuItemEdit.enabled = canEdit;
			if (canEdit)
			{
				addEventListener(MouseEvent.CLICK, onMouseClick);
			}
			else
			{
				removeEventListener(MouseEvent.CLICK, onMouseClick);
			}
		}
		
		private function onContextMenuItemEdit(e:ContextMenuEvent):void
		{
			var selectedTable:BaseTable = Main.instance.selectedTable;
			
			var content:EditColumnDescriptionDialogContent = new EditColumnDescriptionDialogContent(selectedTable, _data);
			DialogFormParams.create().setText(Texts.textEditColumn + ' "' + _data.name + '"').setContent(content).show();
		}
		
		private function onContextMenuItemAdd(e:ContextMenuEvent):void
		{
			var selectedTable:BaseTable = Main.instance.selectedTable;
			
			initAddNewColumn(selectedTable);
		}
		
		private function onContextMenuItemDelete(e:ContextMenuEvent):void
		{
			var selectedTable:BaseTable = Main.instance.selectedTable;
			
			initRemoveColumn(selectedTable, _data);
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (!ViewUtils.isForInspect(e))
			{
				return;
			}
			
			e.preventDefault();
			e.stopImmediatePropagation();
			
			onContextMenuItemEdit(null);
		}
		
		////////////////////////////////////////
		
		public static function initAddNewColumn(table:BaseTable):void
		{
			var content:EditColumnDescriptionDialogContent = new EditColumnDescriptionDialogContent(table, null);
			DialogFormParams.create().setText(Texts.textAddNewColumn).setContent(content).show();
		}
		
		public static function initRemoveColumn(table:BaseTable, column:TableColumnDescription):void
		{
			Main.instance.commandsHistory.addCommandAndExecute(new RemoveColumnCommand(table, column));
		}
	}
}