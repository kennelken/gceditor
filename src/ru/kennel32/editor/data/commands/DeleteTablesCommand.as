package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.Counter;
	
	public class DeleteTablesCommand extends BaseCommand implements ICommand
	{
		public var parent:ContainerTable;
		public var tables:Vector.<BaseTable>;
		
		private var _movedIndexBy:int;
		
		private var _changeTableSelectionTo:BaseTable;
		
		public function DeleteTablesCommand(parent:ContainerTable, tables:Vector.<BaseTable>)
		{
			super();
			
			this.parent = parent;
			this.tables = tables;
			
			if (tables.indexOf(Main.instance.selectedTable) > -1)
			{
				_changeTableSelectionTo = Main.instance.selectedTable;
			}
			
			description = Texts.commandDeleteTables;
		}
		
		public function redo():void
		{
			parent.removeChildren(tables);
			Main.instance.rootTable.cache.builder.rebuildMain();
			
			var counter:Counter = Main.instance.rootTable.cache.getCounterById(Counter.TABLES);
			var counterValue:int = counter.getNextIndex(0);
			var maxId:int = -1;
			for (var i:int = 1; i <= counterValue; i++)
			{
				var table:BaseTable = Main.instance.rootTable.cache.getTableById(i);
				if (table != null)
				{
					maxId = table.meta.id;
				}
			}
			
			_movedIndexBy = Math.min(0, maxId - counterValue);
			if (_movedIndexBy <= 0)
			{
				counter.moveIndex(_movedIndexBy);
			}
			
			Main.instance.rootTable.cache.builder.rebuildMain();
			
			if (_changeTableSelectionTo != null)
			{
				Main.instance.selectedTable = null;
			}
		}
		
		public function undo():void
		{
			parent.addChildren(tables);
			Main.instance.rootTable.cache.builder.rebuildMain();
			
			if (_movedIndexBy <= 0)
			{
				var counter:Counter = Main.instance.rootTable.cache.getCounterById(Counter.TABLES);
				counter.moveIndex(-_movedIndexBy);
			}
			
			Main.instance.rootTable.cache.builder.rebuildMain();
			
			if (_changeTableSelectionTo != null)
			{
				Main.instance.selectedTable = _changeTableSelectionTo;
			}
		}
	}
}