package ru.kennel32.editor.data.commands
{
	import ru.kennel32.editor.assets.Texts;
	
	public class BaseCommand
	{
		public var description:String;
		public var isChangeValueCommand:Boolean;
		
		public function BaseCommand()
		{
			description = Texts.commandDefault;
		}
		
		public function get isImportant():Boolean
		{
			return true;
		}
	}
}