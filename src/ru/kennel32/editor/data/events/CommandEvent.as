package ru.kennel32.editor.data.events
{
	import flash.events.Event;
	import ru.kennel32.editor.data.commands.BaseCommand;
	
	public class CommandEvent extends Event
	{
		public static const BEFORE_COMMAND_EXECUTED:String = "beforecommandexecuted";
		public static const COMMAND_EXECUTED:String = "commandexecuted";
		
		public var cmd:BaseCommand;
		public var undo:Boolean;
		
		public function CommandEvent(type:String, cmd:BaseCommand, undo:Boolean, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.cmd = cmd;
			this.undo = undo;
			
			super(type, bubbles, cancelable);
		}
	}
}