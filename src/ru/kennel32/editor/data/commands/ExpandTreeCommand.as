package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.ContainerTable;
	
	public class ExpandTreeCommand extends BaseCommand implements ICommand
	{
		public var table:ContainerTable;
		public var oldValue:Boolean;
		
		public function ExpandTreeCommand(table:ContainerTable, oldValue:Boolean)
		{
			super();
			
			this.table = table;
			this.oldValue = oldValue;
			
			description = Texts.commandExpandTree;
		}
		
		public function redo():void
		{
			table.collapsed = false;
		}
		
		public function undo():void
		{
			table.collapsed = oldValue;
		}
		
		override public function get isImportant():Boolean
		{
			return false;
		}
	}
}