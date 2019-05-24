package ru.kennel32.editor.data.settings
{
	import ru.kennel32.editor.data.serialize.SerializerType;
	
	public class ExportSettings
	{
		public var entries:Vector.<ExportSettingsEntry>;
		
		public function ExportSettings()
		{
			entries = new Vector.<ExportSettingsEntry>();
		}
		
		public function fromRawData(rawData:Object):ExportSettings
		{
			entries.length = 0;
			
			if (rawData == null)
			{
				initDefault();
			}
			else
			{
				for each (var entry:Object in rawData)
				{
					entries.push(new ExportSettingsEntry(entry['suffix'], entry['serializer'], entry['eos']));
				}
			}
			
			restoreMustSettings();
			return this;
		}
		
		public function toRawData():Object
		{
			restoreMustSettings();
			
			var res:Array = new Array();
			for each (var entry:ExportSettingsEntry in entries)
			{
				res.push({'suffix': entry.suffix, 'serializer': entry.serializerType, 'eos': entry.exportOnSave});
			}
			
			return res;
		}
		
		private function initDefault():void
		{
			entries.push(new ExportSettingsEntry('', SerializerType.ALL[0], true));
		}
		
		public function restoreMustSettings():void
		{
			if (entries.length <= 0 || entries[0] == null)
			{
				entries.length = Math.max(1, entries.length);
				entries[0] = new ExportSettingsEntry('', SerializerType.ALL[0], true);
			}
			else
			{
				entries[0].suffix = '';
				entries[0].exportOnSave = true;
			}
		}
	}
}