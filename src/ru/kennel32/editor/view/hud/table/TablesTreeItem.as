package ru.kennel32.editor.view.hud.table 
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.TableType;
	import ru.kennel32.editor.data.commands.CollapseTreeCommand;
	import ru.kennel32.editor.data.commands.ExpandTreeCommand;
	import ru.kennel32.editor.data.commands.SelectTableCommand;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.view.components.buttons.BtnExpand;
	import ru.kennel32.editor.view.components.tooltip.TableTooltipView;
	import ru.kennel32.editor.view.components.tooltip.TooltipManager;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.forms.dialog.content.EditTableDialogContent;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class TablesTreeItem extends Sprite implements IDisposable
	{
		private static const DEPTH_STEP_OFFSET:int = 25;
		private static const ROWS_DISTANCE:int = -1;
		
		private var _data:BaseTable;
		public function get data():BaseTable { return _data; }
		
		private var _bgSelected:Shape;
		private var _boxName:Sprite;
		private var _tfName:TextField;
		private var _btnExpand:SimpleButton;
		private var _btnCollapse:SimpleButton;
		
		private var _boxChildren:Sprite;
		
		private var _contextMenu:ContextMenu;
		private var _contextMenuItemEdit:ContextMenuItem;
		private var _contextMenuItemAdd:ContextMenuItem;
		private var _contextMenuItemDelete:ContextMenuItem;
		
		public function TablesTreeItem()
		{
			super();
			
			_bgSelected = new Shape();
			_bgSelected.cacheAsBitmap = true;
			addChild(_bgSelected);
			
			_btnExpand = new BtnExpand(16);
			_btnExpand.x = 0;
			_btnExpand.addEventListener(MouseEvent.CLICK, onBtnExpandClick);
			addChild(_btnExpand);
			
			_btnCollapse = new BtnExpand(16, true);
			_btnCollapse.x = 0;
			_btnCollapse.addEventListener(MouseEvent.CLICK, onBtnCollapseClick);
			addChild(_btnCollapse);
			
			_boxChildren = new Sprite();
			_boxChildren.y = 18;
			_boxChildren.addEventListener(Event.RESIZE, onChildrenResized);
			addChild(_boxChildren);
			
			_boxName = new Sprite();
			_boxName.mouseChildren = false;
			_boxName.addEventListener(MouseEvent.CLICK, onNameMouseClick);
			addChild(_boxName);
			
			_tfName = TextUtils.getText('', Color.FONT, 14);
			_boxName.addChild(_tfName);
		}
		
		private function menuItemSelectHandler(e:ContextMenuEvent):void
		{
			
		}
		
		public function init(data:BaseTable, forceUpdate:Boolean = true):void
		{
			if (!forceUpdate && _data == data)
			{
				return;
			}
			
			dispose();
			
			_data = data;
			if (_data == null)
			{
				return;
			}
			
			_data.addEventListener(TableEvent.TREE_COLLAPSE_CHANGED, onCollapseChanged);
			_data.addEventListener(TableEvent.META_CHANGED, onMetaChanged);
			
			var isContainer:Boolean = _data is ContainerTable;
			
			_boxName.x = _btnExpand.width;
			_tfName.text = ViewUtils.getTableName(_data.meta.id);
			
			var collapsed:Boolean = !isContainer || containerTable.collapsed;
			
			_btnExpand.visible = isContainer && collapsed;
			_btnCollapse.visible = isContainer && !collapsed;
			
			setBoxChildrenVisible(isContainer && !collapsed);
			
			if (isContainer)
			{
				Main.instance.addEventListener(TableEvent.TABLES_ADDED, onTableAdded);
				Main.instance.addEventListener(TableEvent.TABLES_DELETED, onTableRemoved);
				
				var children:Vector.<BaseTable> = (_data as ContainerTable).children;
				
				for (var i:int = 0; i < children.length; i++)
				{
					var item:TablesTreeItem = new TablesTreeItem();
					item.x = DEPTH_STEP_OFFSET;
					_boxChildren.addChild(item);
					
					item.init(children[i]);
				}
			}
			
			Main.instance.addEventListener(TableEvent.TABLE_SELECTION_CHANGED, onTableSelectionChanged);
			onTableSelectionChanged(null);
			
			onChildrenResized(null);
			
			attachContextMenu();
			TooltipManager.registerTooltip(this, _data, TableTooltipView);
		}
		
		public function dispose():void
		{
			clearContextMenu();
			TooltipManager.unregisterTooltip(this);
			
			Main.instance.removeEventListener(TableEvent.TABLES_ADDED, onTableAdded);
			Main.instance.removeEventListener(TableEvent.TABLES_DELETED, onTableRemoved);
			
			if (_data != null)
			{
				_data.removeEventListener(TableEvent.TREE_COLLAPSE_CHANGED, onCollapseChanged);
				_data.removeEventListener(TableEvent.META_CHANGED, onMetaChanged);
			}
			
			while (_boxChildren.numChildren > 0)
			{
				_boxChildren.removeChildAt(0);
			}
			
			_btnExpand.visible = false;
			_btnCollapse.visible = false;
			
			Main.instance.removeEventListener(TableEvent.TABLE_SELECTION_CHANGED, onTableSelectionChanged);
		}
		
		private function onBtnExpandClick(e:Event):void
		{
			Main.instance.commandsHistory.addCommandAndExecute(new ExpandTreeCommand(containerTable, containerTable.collapsed));
		}
		
		private function onBtnCollapseClick(e:Event):void
		{
			Main.instance.commandsHistory.addCommandAndExecute(new CollapseTreeCommand(containerTable, containerTable.collapsed));
		}
		
		private function get containerTable():ContainerTable
		{
			return _data as ContainerTable;
		}
		
		private function onCollapseChanged(e:Event):void
		{
			setBoxChildrenVisible(!containerTable.collapsed);
			
			onChildrenResized(null);
			dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		private function onTableAdded(e:TableEvent):void
		{
			if (e.table == _data)
			{
				init(_data, true);
				
				onChildrenResized(null);
				dispatchEvent(new Event(Event.RESIZE, true));
			}
		}
		
		private function onTableRemoved(e:TableEvent):void
		{
			if (e.table == _data)
			{
				init(_data, true);
				
				onChildrenResized(null);
				dispatchEvent(new Event(Event.RESIZE, true));
			}
		}
		
		private function onChildrenResized(e:Event):void
		{
			var currentY:int = 0;
			for (var i:int = 0; i < _boxChildren.numChildren; i++)
			{
				var child:TablesTreeItem = _boxChildren.getChildAt(i) as TablesTreeItem;
				child.y = currentY;
				currentY += child.height + ROWS_DISTANCE;
			}
			
			updateButtons();
		}
		
		private function updateButtons():void
		{
			var isContainer:Boolean = _data is ContainerTable;
			_btnExpand.visible = isContainer && containerTable.collapsed;
			_btnCollapse.visible = isContainer && !containerTable.collapsed;
		}
		
		private function onTableSelectionChanged(e:TableEvent):void
		{
			var graphics:Graphics = _bgSelected.graphics;
			
			if (_data == Main.instance.selectedTable)
			{
				graphics.beginFill(Color.BUTTON_BODY, 1);
				graphics.drawRect(_boxName.x, 0, _boxName.width + 2, 18);
				graphics.endFill();
				
				_boxName.buttonMode = false;
				
				Main.instance.mainUI.playAttentionEffect(_boxName);
			}
			else
			{
				graphics.clear();
				
				_boxName.buttonMode = true;
			}
		}
		
		private function onNameMouseClick(e:Event):void
		{
			if (ViewUtils.isForInspect(e))
			{
				onContextMenuItemEdit(null);
			}
			else if (_data != Main.instance.selectedTable)
			{
				Main.instance.commandsHistory.addCommandAndExecute(new SelectTableCommand(_data, Main.instance.selectedTable));
			}
		}
		
		private function setBoxChildrenVisible(value:Boolean):void
		{
			if (value && _boxChildren.parent == null)
			{
				addChild(_boxChildren);
			}
			if (!value && _boxChildren.parent != null)
			{
				_boxChildren.parent.removeChild(_boxChildren);
			}
		}
		
		private function onMetaChanged(e:Event):void
		{
			init(_data, true);
			Main.instance.mainUI.playAttentionEffect(_boxName);
		}
		
		//////////////////////////////////
		
		private function attachContextMenu():void
		{
			_contextMenu = new ContextMenu();
			
			_contextMenuItemEdit = new ContextMenuItem(Texts.textEditProps);
			_contextMenu.customItems.push(_contextMenuItemEdit);
			_contextMenuItemEdit.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemEdit);
			
			_contextMenuItemAdd = new ContextMenuItem(Texts.textAddSubtable);
			_contextMenu.customItems.push(_contextMenuItemAdd);
			_contextMenuItemAdd.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemAdd);
			if (_data.meta.type != TableType.CONTAINER)
			{
				_contextMenuItemAdd.enabled = false;
			}
			
			_contextMenuItemDelete = new ContextMenuItem(Texts.textDelete);
			_contextMenu.customItems.push(_contextMenuItemDelete);
			_contextMenuItemDelete.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemDelete);
			if (Hardcode.isSystemMeta(_data.meta))
			{
				_contextMenuItemDelete.enabled = false;
			}
			
			_boxName.contextMenu = _contextMenu;
		}
		
		private function clearContextMenu():void
		{
			if (_contextMenu != null)
			{
				_contextMenuItemEdit.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemEdit);
				_contextMenuItemAdd.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemAdd);
				_contextMenuItemDelete.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemDelete);
				
				_boxName.contextMenu = null;
				_contextMenu = null;
				_contextMenuItemEdit = null;
				_contextMenuItemAdd = null;
				_contextMenuItemDelete = null;
			}
		}
		
		private function onContextMenuItemEdit(e:ContextMenuEvent):void
		{
			var content:EditTableDialogContent = new EditTableDialogContent(_data, _data.parent);
			DialogFormParams.create().setText(Texts.textEditTable + ' "' + _data.meta.name + '"').setContent(content).show();
		}
		
		private function onContextMenuItemAdd(e:ContextMenuEvent):void
		{
			TableEditPanel.initCreateNewTable(_data as ContainerTable);
		}
		
		private function onContextMenuItemDelete(e:ContextMenuEvent):void
		{
			TableEditPanel.initDeleteTables(_data.parent, Vector.<BaseTable>([_data]));
		}
		
		////////////////////////////////////////
	}
}