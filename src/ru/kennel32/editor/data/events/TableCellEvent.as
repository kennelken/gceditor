package ru.kennel32.editor.data.events
{
	import flash.events.Event;
	
	public class TableCellEvent extends Event
	{
		public static const HEIGHT_CHANGED:String = "heightchanged";
		
		public function TableCellEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}