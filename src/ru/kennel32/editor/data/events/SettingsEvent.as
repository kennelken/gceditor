package ru.kennel32.editor.data.events
{
	import flash.events.Event;
	
	public class SettingsEvent extends Event
	{
		public static const EXPORT_SETTINGS_CHANGED:String	= 'exportsettingschanged';
		public static const UPLOAD_PATHS_CHANGED:String		= 'uploadpathschanged';
		public static const TIMEZONE_CHANGED:String			= 'timezonechanged';
		public static const TABLE_SCALE_CHANGED:String		= 'tablescalechanged';
		public static const FILES_ROOT_CHANGED:String		= 'filesrootchanged';
		
		public function SettingsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}