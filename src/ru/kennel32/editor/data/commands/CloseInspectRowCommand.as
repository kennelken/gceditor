package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.assets.Texts;
	
	public class CloseInspectRowCommand extends BaseCommand implements ICommand
	{
		private var _reverseCommand:InspectRowCommand;
		 
		public function CloseInspectRowCommand(reverseCommand:InspectRowCommand)
		{
			super();
			
			_reverseCommand = reverseCommand;
			
			description = Texts.commandCloseInspectRow;
		}
		
		public function redo():void
		{
			_reverseCommand.undo();
		}
		
		public function undo():void
		{
			_reverseCommand.redo();
		}
		
		override public function get isImportant():Boolean
		{
			return false;
		}
	}
}