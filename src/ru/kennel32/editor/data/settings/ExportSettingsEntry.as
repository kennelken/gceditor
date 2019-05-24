package ru.kennel32.editor.data.settings
{
	public class ExportSettingsEntry
	{
		public var suffix:String;
		public var serializerType:int;
		public var exportOnSave:Boolean;
		
		public function ExportSettingsEntry(suffix:String, serializerType:int, exportOnSave:Boolean)
		{
			this.suffix = suffix;
			this.serializerType = serializerType;
			this.exportOnSave = exportOnSave;
		}
	}
}