package ru.kennel32.editor.data.settings
{
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.utils.ParseUtils;
	
	public class Settings
	{
		private static var _instance:Settings;
		
		private var _sharedObject:SharedObject;
		private var _eventDispatcher:EventDispatcher;
		
		public function Settings()
		{
		}
		
		public static function init():void
		{
			if (_instance != null)
			{
				throw new Error('Settings has been already inited');
			}
			
			_instance = new Settings();
			_instance.init();
		}
		
		private function init():void
		{
			_eventDispatcher = new EventDispatcher();
			
			try
			{
				_sharedObject = SharedObject.getLocal("kennel/gceditor");
				fixSettings();
				restoreExportSettings();
			}
			catch (e:Error)
			{
				
			}
		}
		
		public static function resetSavedSettings():void
		{
			if (_instance != null && _instance._sharedObject != null)
			{
				_instance._sharedObject.clear();
			}
			
			dispatchEvent(new SettingsEvent(SettingsEvent.TABLE_SCALE_CHANGED));
			dispatchEvent(new SettingsEvent(SettingsEvent.UPLOAD_PATHS_CHANGED));
			dispatchEvent(new SettingsEvent(SettingsEvent.EXPORT_SETTINGS_CHANGED));
		}
		
		///////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////
		
		public static function get lastFile():String
		{
			return getStringValue('file');
		}
		public static function set lastFile(value:String):void
		{
			setStringValue('file', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get treeWidth():uint
		{
			return getUintValue('treeWidth');
		}
		public static function set treeWidth(value:uint):void
		{
			setUintValue('treeWidth', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get windowWidth():uint
		{
			return getUintValue('windowWidth');
		}
		public static function set windowWidth(value:uint):void
		{
			setUintValue('windowWidth', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get windowHeight():uint
		{
			return getUintValue('windowHeight');
		}
		public static function set windowHeight(value:uint):void
		{
			setUintValue('windowHeight', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get windowX():uint
		{
			return getUintValue('windowX');
		}
		public static function set windowX(value:uint):void
		{
			setUintValue('windowX', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get windowY():uint
		{
			return getUintValue('windowY');
		}
		public static function set windowY(value:uint):void
		{
			setUintValue('windowY', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get tableScale():Number
		{
			var value:Number = getNumberValue('tableScale');
			return value <= 0.2 ? 1 : value;
		}
		public static function set tableScale(value:Number):void
		{
			setNumberValue('tableScale', value);
			
			dispatchEvent(new SettingsEvent(SettingsEvent.TABLE_SCALE_CHANGED));
		}
		///////////////////////////////////////////////////////////////////////
		public static function get needFindCheckboxUsage():Boolean
		{
			return getUintValue('checkboxUsage') > 0;
		}
		public static function set needFindCheckboxUsage(value:Boolean):void
		{
			setUintValue('checkboxUsage', value ? 1 : 0);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get needFindCheckboxLocalizations():Boolean
		{
			return getUintValue('checkboxLocalizations') > 0;
		}
		public static function set needFindCheckboxLocalizations(value:Boolean):void
		{
			setUintValue('checkboxLocalizations', value ? 1 : 0);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get findOffsetX():int
		{
			return getIntValue('findOffsetX');
		}
		public static function set findOffsetX(value:int):void
		{
			setIntValue('findOffsetX', value);
		}
		public static function get findOffsetY():int
		{
			return getIntValue('findOffsetY');
		}
		public static function set findOffsetY(value:int):void
		{
			setIntValue('findOffsetY', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get warningsOffsetX():int
		{
			return getIntValue('warningsOffsetX');
		}
		public static function set warningsOffsetX(value:int):void
		{
			setIntValue('warningsOffsetX', value);
		}
		public static function get warningsOffsetY():int
		{
			return getIntValue('warningsOffsetY');
		}
		public static function set warningsOffsetY(value:int):void
		{
			setIntValue('warningsOffsetY', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get settingsOffsetX():int
		{
			return getIntValue('settingsOffsetX');
		}
		public static function set settingsOffsetX(value:int):void
		{
			setIntValue('settingsOffsetX', value);
		}
		public static function get settingsOffsetY():int
		{
			return getIntValue('settingsOffsetY');
		}
		public static function set settingsOffsetY(value:int):void
		{
			setIntValue('settingsOffsetY', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get inspectOffsetX():int
		{
			return getIntValue('inspectOffsetX');
		}
		public static function set inspectOffsetX(value:int):void
		{
			setIntValue('inspectOffsetX', value);
		}
		public static function get inspectOffsetY():int
		{
			return getIntValue('inspectOffsetY');
		}
		public static function set inspectOffsetY(value:int):void
		{
			setIntValue('inspectOffsetY', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get commonDialogOffsetX():int
		{
			return getIntValue('commonDialogOffsetX');
		}
		public static function set commonDialogOffsetX(value:int):void
		{
			setIntValue('commonDialogOffsetX', value);
		}
		public static function get commonDialogOffsetY():int
		{
			return getIntValue('commonDialogOffsetY');
		}
		public static function set commonDialogOffsetY(value:int):void
		{
			setIntValue('commonDialogOffsetY', value);
		}
		///////////////////////////////////////////////////////////////////////
		public static function get uploadPaths():Array
		{
			return _instance._sharedObject == null ? null : _instance._sharedObject.data['uploadPaths'];
		}
		public static function set uploadPaths(value:Array):void
		{
			if (_instance._sharedObject != null)
			{
				if (value == null)
				{
					delete _instance._sharedObject.data['uploadPaths'];
				}
				else
				{
					_instance._sharedObject.data['uploadPaths'] = value;
				}
				
				dispatchEvent(new SettingsEvent(SettingsEvent.UPLOAD_PATHS_CHANGED));
			}
		}
		///////////////////////////////////////////////////////////////////////
		private var _exportSettings:ExportSettings;
		public static function get exportSettings():ExportSettings
		{
			return _instance._exportSettings;
		}
		private function restoreExportSettings():void
		{
			_exportSettings = new ExportSettings().fromRawData(_sharedObject.data['exportSettings']);
		}
		public static function saveExportSettings():void
		{
			_instance._sharedObject.data['exportSettings'] = _instance._exportSettings.toRawData();
			_instance._sharedObject.flush();
			dispatchEvent(new SettingsEvent(SettingsEvent.EXPORT_SETTINGS_CHANGED));
		}
		///////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////
		
		private static function getUintValue(key:String):uint
		{
			return _instance._sharedObject == null ? 0 : Math.max(0, _instance._sharedObject.data[key]);
		}
		private static function setUintValue(key:String, value:uint):void
		{
			if (_instance._sharedObject != null)
			{
				if (value <= 0)
				{
					delete _instance._sharedObject.data[key];
				}
				else
				{
					_instance._sharedObject.data[key] = value;
				}
				
				_instance._sharedObject.flush();
			}
		}
		
		private static function getIntValue(key:String):int
		{
			return _instance._sharedObject == null ? 0 : _instance._sharedObject.data[key];
		}
		private static function setIntValue(key:String, value:int):void
		{
			if (_instance._sharedObject != null)
			{
				if (value == 0)
				{
					delete _instance._sharedObject.data[key];
				}
				else
				{
					_instance._sharedObject.data[key] = value;
				}
				
				_instance._sharedObject.flush();
			}
		}
		
		private static function getNumberValue(key:String):Number
		{
			return _instance._sharedObject == null ? 0 : ParseUtils.readFloat(_instance._sharedObject.data[key]);
		}
		private static function setNumberValue(key:String, value:Number):void
		{
			if (_instance._sharedObject != null)
			{
				if (isNaN(value) || value == 0)
				{
					delete _instance._sharedObject.data[key];
				}
				else
				{
					_instance._sharedObject.data[key] = value;
				}
				
				_instance._sharedObject.flush();
			}
		}
		
		private static function getStringValue(key:String):String
		{
			return _instance._sharedObject == null ? null : _instance._sharedObject.data[key];
		}
		private static function setStringValue(key:String, value:String):void
		{
			if (_instance._sharedObject != null)
			{
				if (value == null)
				{
					delete _instance._sharedObject.data[key];
				}
				else
				{
					_instance._sharedObject.data[key] = value;
				}
				
				_instance._sharedObject.flush();
			}
		}
		
		private static function hasKey(key:String):Boolean
		{
			if (_instance._sharedObject == null)
			{
				return false;
			}
			
			return _instance._sharedObject.data[key] !== undefined;
		}
		
		private function fixSettings():void
		{
			if (windowX > NativeWindow.systemMaxSize.x)
			{
				windowX = 0;
			}
			if (windowY > NativeWindow.systemMaxSize.y)
			{
				windowY = 0;
			}
			if (windowWidth > NativeWindow.systemMaxSize.x)
			{
				windowWidth = 0;
			}
			if (windowHeight > NativeWindow.systemMaxSize.y)
			{
				windowHeight = 0;
			}
		}
		
		////////////////////////////////
		
		public static function dispatchEvent(e:Event):void
		{
			_instance._eventDispatcher.dispatchEvent(e);
		}
		
		public static function addEventListener(type:String, listener:Function):void
		{
			_instance._eventDispatcher.addEventListener(type, listener);
		}
		
		public static function removeEventListener(type:String, listener:Function):void
		{
			_instance._eventDispatcher.removeEventListener(type, listener);
		}
	}
}