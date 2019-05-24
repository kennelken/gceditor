package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.events.TableEvent;
	
	public class CreateTableCommand extends BaseCommand implements ICommand
	{
		public var parent:ContainerTable;
		public var table:BaseTable;
		
		public var _oldSelectedTable:BaseTable;
		
		public function CreateTableCommand(parent:ContainerTable, table:BaseTable)
		{
			super();
			
			this.parent = parent;
			this.table = table;
			
			_oldSelectedTable = Main.instance.selectedTable;
			
			description = Texts.commandAddRow;
		}
		
		public function redo():void
		{
			parent.addChild(table);
			
			Main.instance.rootTable.cache.getCounterById(Counter.TABLES).moveIndex(1);
			Main.instance.rootTable.cache.builder.rebuildMain();
			
			Main.instance.selectedTable = table;
			
			Main.instance.dispatchEvent(new TableEvent(TableEvent.TABLES_ADDED, parent, null, null, null, Vector.<BaseTable>[table]));
		}
		
		public function undo():void
		{
			parent.removeChild(table);
			Main.instance.rootTable.cache.getCounterById(Counter.TABLES).moveIndex(-1);
			Main.instance.rootTable.cache.builder.rebuildMain();
			
			Main.instance.selectedTable = _oldSelectedTable;
			
			Main.instance.dispatchEvent(new TableEvent(TableEvent.TABLES_DELETED, parent, null, null, null, Vector.<BaseTable>[table]));
		}
	}
}