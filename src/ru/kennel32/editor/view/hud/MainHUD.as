package ru.kennel32.editor.view.hud 
{
	import flash.events.Event;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.data.utils.DelayUtils;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.hud.table.WarningsPanel;
	import ru.kennel32.editor.view.hud.table.TableView;
	import ru.kennel32.editor.view.hud.table.TablesTreeView;
	
	public class MainHUD extends CanvasSprite
	{
		private var _tablesTreeView:TablesTreeView;
		private var _warningsPanel:WarningsPanel;
		
		private var _tableView:TableView;
		
		private var _selectedTable:BaseTable;
		public function get selectedTable():BaseTable
		{
			return _selectedTable;
		}
		
		public function MainHUD()
		{
			super();
			
			_tablesTreeView = new TablesTreeView();
			addChild(_tablesTreeView);
			
			_warningsPanel = new WarningsPanel();
			addChild(_warningsPanel);
			
			_tableView = new TableView();
		}
		
		public function init():void
		{
			_tablesTreeView.setSize(Settings.treeWidth > 0 ? Settings.treeWidth : (TablesTreeView.MIN_WIDTH + 100), 400);
			_tablesTreeView.init();
			_tablesTreeView.addEventListener(Event.RESIZE, onTablesTreeResized);
			
			_warningsPanel.setSize( -1, 27);
			_warningsPanel.init();
			
			Main.instance.addEventListener(TableEvent.TABLE_SELECTION_CHANGED, onTableSelectionChanged);
			onTableSelectionChanged();
			
			_tableView.init();
			setSize();
		}
		
		override public function setSize(width:int = -1, height:int = -1):void
		{
			super.setSize(width, height);
			
			_tablesTreeView.setSize(-1, _height - _warningsPanel.height);
			_warningsPanel.setSize(_tablesTreeView.width, -1);
			_warningsPanel.y = _height - _warningsPanel.height;
			
			_tableView.setSize(_width - _tablesTreeView.width, _height);
			_tableView.x = _tablesTreeView.width;
		}
		
		private function onTablesTreeResized(e:Event):void
		{
			if (e.target == _tablesTreeView)
			{
				setSize(-1, -1);
				DelayUtils.execute(saveWidth, 350, true);
			}
		}
		
		private function saveWidth():void
		{
			Settings.treeWidth = _tablesTreeView.width;
		}
		
		private function onTableSelectionChanged(e:Event = null):void
		{
			var selectedTable:BaseTable = Main.instance.selectedTable;
			if (selectedTable && _tableView.parent == null)
			{
				addChild(_tableView);
			}
			else if (!selectedTable && _tableView.parent != null)
			{
				removeChild(_tableView);
			}
		}
		
		public function get tablesTreeView():TablesTreeView
		{
			return _tablesTreeView;
		}
		
		public function get tableView():TableView
		{
			return _tableView;
		}
	}
}