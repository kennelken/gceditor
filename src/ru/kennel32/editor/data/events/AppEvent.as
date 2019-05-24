package ru.kennel32.editor.data.events
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{
		public static const INTERRUPT_ACTIONS:String = 'interruptactions';
		public static const BEFORE_SAVE:String = 'beforesave';
		public static const BEFORE_COMMAND:String = 'beforecommand';
		
		public function AppEvent(type:String)
		{
			super(type, false, true);
		}
	}
}