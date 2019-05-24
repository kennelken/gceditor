package ru.kennel32.editor.data.commands
{
	import flash.geom.Point;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableRow;
	
	public class SelectTableCommand extends BaseCommand implements ICommand
	{
		public var newTable:BaseTable;
		public var oldTable:BaseTable;
		private var _newScrollPosition:Point;
		
		private var _oldCheckedRows:Vector.<TableRow>;
		private var _oldCheckedTables:Vector.<BaseTable>;
		private var _oldScrollPosition:Point;
		
		public var focusOn:TableRow;
		
		public function SelectTableCommand(newTable:BaseTable, oldTable:BaseTable, focusOn:TableRow = null)
		{
			super();
			
			this.newTable = newTable;
			this.oldTable = oldTable;
			this.focusOn = focusOn;
			
			_oldCheckedRows = new Vector.<TableRow>();
			var dataTable:DataTable = oldTable as DataTable;
			if (dataTable != null)
			{
				for (var i:int = 0; i < dataTable.rows.length; i++)
				{
					if (dataTable.rows[i].checked)
					{
						_oldCheckedRows.push(dataTable.rows[i]);
					}
				}
			}
			
			_oldCheckedTables = new Vector.<BaseTable>();
			var containerTable:ContainerTable = oldTable as ContainerTable;
			if (containerTable != null)
			{
				for (i = 0; i < containerTable.children.length; i++)
				{
					if (containerTable.children[i].checked)
					{
						_oldCheckedTables.push(containerTable.children[i]);
					}
				}
			}
			
			description = Texts.commandSelectTable;
		}
		
		public function redo():void
		{
			_oldScrollPosition = Main.instance.mainUI.mainHUD.tableView.currentScrollPosition;
			
			Main.instance.selectedTable = newTable;
			
			var dataTable:DataTable = oldTable as DataTable;
			for (var i:int = 0; i < _oldCheckedRows.length; i++)
			{
				_oldCheckedRows[i].checked = false;
			}
			
			var containerTable:ContainerTable = oldTable as ContainerTable;
			for (i = 0; i < _oldCheckedTables.length; i++)
			{
				_oldCheckedTables[i].checked = false;
			}
			
			if (focusOn != null)
			{
				Main.instance.mainUI.mainHUD.tableView.focusOn(focusOn);
				focusOn = null;
			}
			if (_newScrollPosition != null)
			{
				Main.instance.mainUI.mainHUD.tableView.setScrollPosition(_newScrollPosition);
			}
		}
		
		public function undo():void
		{
			_newScrollPosition = Main.instance.mainUI.mainHUD.tableView.currentScrollPosition;
			
			var dataTable:DataTable = oldTable as DataTable;
			for (var i:int = 0; i < _oldCheckedRows.length; i++)
			{
				_oldCheckedRows[i].checked = true;
			}
			
			var containerTable:ContainerTable = oldTable as ContainerTable;
			for (i = 0; i < _oldCheckedTables.length; i++)
			{
				_oldCheckedTables[i].checked = true;
			}
			
			Main.instance.selectedTable = oldTable;
			
			if (_oldScrollPosition != null)
			{
				Main.instance.mainUI.mainHUD.tableView.setScrollPosition(_oldScrollPosition);
			}
		}
		
		override public function get isImportant():Boolean
		{
			return false;
		}
	}
}