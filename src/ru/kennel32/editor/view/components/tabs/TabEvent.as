package ru.kennel32.editor.view.components.tabs
{
	import flash.events.Event;
	
	public class TabEvent extends Event
	{
		public static const TAB_CLICK:String = 'tabclick';
		
		public var tab:TabInfo;
		
		public function TabEvent(type:String, tab:TabInfo = null)
		{
			super(type);
			
			this.tab = tab;
		}
	}
}