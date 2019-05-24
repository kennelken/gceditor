package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableMeta;
	
	public class EditTableCommand extends BaseCommand implements ICommand
	{
		public var table:BaseTable;
		public var newMeta:TableMeta;
		
		private var _oldMeta:TableMeta;
		
		public function EditTableCommand(table:BaseTable, newMeta:TableMeta)
		{
			super();
			
			this.table = table;
			this.newMeta = newMeta;
			
			_oldMeta = new TableMeta();
			_oldMeta.copyFrom(table.meta);
			
			description = Texts.commandEditTable;
		}
		
		public function redo():void
		{
			table.copyMetaFrom(newMeta);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
		
		public function undo():void
		{
			table.copyMetaFrom(_oldMeta);
			
			Main.instance.rootTable.cache.builder.rebuildMain();
		}
	}
}