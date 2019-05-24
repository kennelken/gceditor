package ru.kennel32.editor.data.settings
{
	import flash.filesystem.File;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	
	public class ProjectSettings
	{
		private static const FILES_PATH:int				= 0;
		private static const TIMEZONE:int				= 1;
		
		private static var _values:ProjectSettings;
		
		private var _filesRoot:String;
		private var _timezone:Number;
		
		public function ProjectSettings()
		{
			_filesRoot = parseFilesRoot(data.rows[FILES_PATH].data[3]);
			_timezone = parseFloat(data.rows[TIMEZONE].data[3]);
			_timezone = isNaN(_timezone) ? 0 : _timezone;
		}
		
		public static function get filesRoot():String
		{
			updateIfRequired();
			return _values._filesRoot;
		}
		
		
		public static function get timezone():Number
		{
			updateIfRequired();
			return _values._timezone;
		}
		
		private static function get data():DataTable
		{
			return Main.instance.rootTable.children[Counter.PROJECT_SETTINGS - 1 - 1] as DataTable;
		}
		
		public static function clearCache():void
		{
			_values = null;
		}
		
		private static function updateIfRequired():void
		{
			if (_values == null)
			{
				_values = new ProjectSettings();
			}
		}
		
		private function parseFilesRoot(src:String):String
		{
			if (src == null)
			{
				src = '';
			}
			
			if (src == '' || src.substring(0, 3) == '../')
			{
				if (Main.instance.file != null)
				{
					return appendSlashIfRequired(Main.instance.file.parent.resolvePath(src).url);
				}
			}
			
			try
			{
				var exactPathFile:File = new File(src);
				var existingFile:File = exactPathFile;
				//try to find any correct path in the specified path which means the specified path is correct
				while (existingFile != null)
				{
					if (existingFile.exists)
					{
						return appendSlashIfRequired(exactPathFile.url);
					}
					existingFile = existingFile.parent;
				}
			}
			catch (e:Error) {}
			
			return appendSlashIfRequired(File.applicationStorageDirectory.url);
		}
		
		private function appendSlashIfRequired(src:String):String
		{
			if (src.substr(src.length - 1, 1) != '/')
			{
				return src + '/';
			}
			return src;
		}
	}
}