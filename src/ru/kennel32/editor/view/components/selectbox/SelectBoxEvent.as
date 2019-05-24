package ru.kennel32.editor.view.components.selectbox
{
	import flash.events.Event;
	
	public class SelectBoxEvent extends Event
	{
		public static const CREATE_NEW_ITEM:String = "createnewitem";
		
		public function SelectBoxEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}