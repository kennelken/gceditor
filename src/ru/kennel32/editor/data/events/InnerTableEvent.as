package ru.kennel32.editor.data.events
{
	import flash.events.Event;
	
	public class InnerTableEvent extends Event
	{
		public static const VALUE_CHANGED:String = 'valuechanged';
		
		public var newValue:*;
		
		public function InnerTableEvent(type:String, newValue:*, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.newValue = newValue;
		}
	}
}