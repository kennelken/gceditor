package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.ContainerTable;
	
	public class CollapseTreeCommand extends BaseCommand implements ICommand
	{
		public var table:ContainerTable;
		public var oldValue:Boolean;
		
		public function CollapseTreeCommand(table:ContainerTable, oldValue:Boolean)
		{
			super();
			
			this.table = table;
			this.oldValue = oldValue;
			
			description = Texts.commandExpandTree;
		}
		
		public function redo():void
		{
			table.collapsed = true;
		}
		
		public function undo():void
		{
			table.collapsed = false;
		}
		
		override public function get isImportant():Boolean
		{
			return false;
		}
	}
}