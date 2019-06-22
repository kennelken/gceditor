package ru.kennel32.editor
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import ru.kennel32.editor.assets.Assets;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.commands.BaseCommand;
	import ru.kennel32.editor.data.commands.ChangeStringValueCommand;
	import ru.kennel32.editor.data.commands.CommandsHistory;
	import ru.kennel32.editor.data.commands.DeleteRowsCommand;
	import ru.kennel32.editor.data.events.AppEvent;
	import ru.kennel32.editor.data.events.CommandEvent;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.serialize.ITableSerializer;
	import ru.kennel32.editor.data.serialize.JsonAssociativeReducedSerializer;
	import ru.kennel32.editor.data.serialize.JsonAssociativeSerializer;
	import ru.kennel32.editor.data.serialize.JsonIndexedBeautifiedSerializer;
	import ru.kennel32.editor.data.serialize.JsonIndexedSerializer;
	import ru.kennel32.editor.data.serialize.SerializerParams;
	import ru.kennel32.editor.data.serialize.SerializerType;
	import ru.kennel32.editor.data.settings.ExportSettingsEntry;
	import ru.kennel32.editor.data.settings.ProjectSettings;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.NewTableBuilder;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.utils.DelayUtils;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.view.MainUI;
	import ru.kennel32.editor.view.components.tooltip.SimpleTooltipView;
	import ru.kennel32.editor.view.components.tooltip.TooltipManager;
	import ru.kennel32.editor.view.factory.ObjectsPool;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.forms.dialog.content.FindDialogContent;
	import ru.kennel32.editor.view.forms.dialog.content.WarningsDialogContent;
	import ru.kennel32.editor.view.menu.AppMenu;
	import ru.kennel32.editor.view.mouse.MouseUtils;
	import ru.kennel32.editor.view.utils.DragManager;
	import ru.kennel32.editor.view.utils.MouseWheelManager;
	import ru.kennel32.editor.view.utils.ViewUtils;
	import ru.kennel32.editor.view.utils.draganddrop.ColumnDragAndDropManager;
	
	[SWF (width="1400", height="1000", frameRate="60")]
	public class Main extends Sprite
	{
		private static const COMMANDS_HISTORY_SIZE:int = 200;
		
		private var _rootTable:ContainerTable;
		
		private var _selectedTable:BaseTable;
		public function get selectedTable():BaseTable
		{
			return _selectedTable;
		}
		public function set selectedTable(value:BaseTable):void
		{
			_selectedTable = value;
			dispatchEvent(new TableEvent(TableEvent.TABLE_SELECTION_CHANGED, _selectedTable));
		}
		
		private var _appMenu:AppMenu;
		
		private var _mainUI:MainUI;
		public function get mainUI():MainUI
		{
			return _mainUI;
		}
		
		private var _file:File;
		public function get file():File
		{
			return _file;
		}
		
		public function get rootTable():ContainerTable
		{
			return _rootTable;
		}
		
		private var _commandsHistory:CommandsHistory;
		public function get commandsHistory():CommandsHistory
		{
			return _commandsHistory;
		}
		
		private var _serializersByType:Vector.<ITableSerializer>;
		
		public function Main() 
		{
			super();
			
			_instance = this;
			
			new Assets();
			MouseUtils.init();
			MouseWheelManager.getInstance().init('not_designed_to_run_in_browser', stage, false);
			ColumnDragAndDropManager.init();
			DragManager.init(stage);
			ObjectsPool.init();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, onWindowMoved);
			stage.nativeWindow.addEventListener(Event.CLOSING, onAppClosing);
			
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightButtonMouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDown);
			
			Settings.init();
			
			_commandsHistory = new CommandsHistory(COMMANDS_HISTORY_SIZE);
			_commandsHistory.addEventListener(CommandEvent.BEFORE_COMMAND_EXECUTED, onBeforeCommandExecuted);
			_commandsHistory.addEventListener(CommandEvent.COMMAND_EXECUTED, onCommandExecuted);
			
			prepareSerializers();
			
			_mainUI = new MainUI();
			addChild(_mainUI);
			
			_appMenu = new AppMenu();
			
			var file:File = getLastFile();
			if (file != null)
			{
				openFile(file);
			}
			
			_appMenu.init();
			
			var tooltipsLayer:Sprite = new Sprite();
			addChild(tooltipsLayer);
			TooltipManager.init(tooltipsLayer, 10, 20, 200, SimpleTooltipView);
			
			_mainUI.init();
			onStageResize(null);
			
			FindDialogContent.init();
			WarningsDialogContent.init();
			
			DelayUtils.execute(delayedRestoreWindow, 0);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private var _allowedFilesExtensions:Vector.<String>;
		public function get allowedFilesExtensions():Vector.<String>
		{
			return _allowedFilesExtensions;
		}
		private function prepareSerializers():void
		{
			_serializersByType = new Vector.<ITableSerializer>(SerializerType.ALL.length);
			_serializersByType[SerializerType.JSON_INDEXED_BEAUTIFIED] =				new JsonIndexedBeautifiedSerializer();
			_serializersByType[SerializerType.JSON_INDEXED] =							new JsonIndexedSerializer();
			_serializersByType[SerializerType.JSON_ASSOCIATIVE] =						new JsonAssociativeSerializer();
			_serializersByType[SerializerType.JSON_ASSOCIATIVE_REDUCED] =				new JsonAssociativeReducedSerializer();
			
			_allowedFilesExtensions = new Vector.<String>();
			for each (var serializer:ITableSerializer in _serializersByType)
			{
				if (_allowedFilesExtensions.indexOf(serializer.fileExtension) <= -1)
				{
					_allowedFilesExtensions.push(serializer.fileExtension);
				}
			}
		}
		
		private function onRightButtonMouseDown(e:MouseEvent):void
		{
			dispatchInterruptCurrentAction();
		}
		private function onKeyboardDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE || ViewUtils.isSpecialKey(e))
			{
				dispatchInterruptCurrentAction();
			}
		}
		private function dispatchInterruptCurrentAction():void
		{
			dispatchEvent(new AppEvent(AppEvent.INTERRUPT_ACTIONS));
		}
		private function dispatchBeforeSaveEvent():void
		{
			dispatchEvent(new AppEvent(AppEvent.BEFORE_SAVE));
		}
		private function dispatchBeforeCommandEvent():void
		{
			dispatchEvent(new AppEvent(AppEvent.BEFORE_COMMAND));
		}
		
		private function delayedRestoreWindow():void
		{
			if (Settings.windowWidth > 50)
			{
				stage.nativeWindow.width = Settings.windowWidth;
			}
			if (Settings.windowHeight > 50)
			{
				stage.nativeWindow.height = Settings.windowHeight;
			}
			if (Settings.windowX > 0)
			{
				stage.nativeWindow.x = Settings.windowX;
			}
			if (Settings.windowY > 0)
			{
				stage.nativeWindow.y = Settings.windowY;
			}
		}
		
		private static var _instance:Main;
		public static function get instance():Main
		{
			return _instance;
		}
		
		public static function get stage():Stage
		{
			return _instance.stage;
		}
		
		public function newTable():void
		{
			resetCurrentFile();
			
			_rootTable = NewTableBuilder.create();
			
			_unsavedFile = true;
			
			onTableChanged();
		}
		
		public function saveTable():void
		{
			if (_file == null)
			{
				saveTableAs();
				return;
			}
			
			var toPlayEffect:Boolean = hasUnsavedChanges;
			for each (var entry:ExportSettingsEntry in Settings.exportSettings.entries)
			{
				if (entry.exportOnSave)
				{
					exportTable(entry, toPlayEffect);
					toPlayEffect = false;
				}
			}
		}
		
		public function exportTable(setting:ExportSettingsEntry, toPlayEffect:Boolean = true):void
		{
			dispatchBeforeSaveEvent();
			
			var source:String = rootToString(setting.serializerType);
			
			var url:String = _file.url;
			var path:String = _file.url.substr(0, _file.url.lastIndexOf("/") + 1);
			var fileWithSuffix:File = new File(path + getExportFileName(setting));
			
			var stream:FileStream = new FileStream();
			stream.open(fileWithSuffix, FileMode.WRITE);
			stream.writeUTFBytes(source);
			stream.close();
			
			if (setting == Settings.exportSettings.entries[0])
			{
				_unsavedFile = false;
				_commandsHistory.updateSavePos();
			}
			
			if (toPlayEffect)
			{
				_mainUI.playAttentionEffect(_mainUI.mainHUD.tablesTreeView);
			}
		}
		
		public function getExportFileName(setting:ExportSettingsEntry):String
		{
			var name:String = _file.name;
			if (name.lastIndexOf(".") > -1)
			{
				name = name.substr(0, name.lastIndexOf("."));
			}
			return name + setting.suffix + '.' + _serializersByType[setting.serializerType].fileExtension;
		}
		
		public function rootToString(serializerType:int):String
		{
			return _serializersByType[serializerType].serializeTable(_rootTable).source;
		}
		
		public function saveTableAs():void
		{
			var file:File = getLastFile(true);
			if (!file.isDirectory)
			{
				file = file.parent;
			}
			file = file.resolvePath('NewTable.' + _serializersByType[Settings.exportSettings.entries[0].serializerType].fileExtension);
			
			file.addEventListener(Event.SELECT, onSaveAsFileSelected);
			file.addEventListener(Event.CANCEL, onSaveAsCanceled);
			file.browseForSave(Texts.textSaveAs);
		}
		
		private function onSaveAsFileSelected(e:Event):void
		{
			_file = e.currentTarget as File;
			saveTable();
			
			onSaveAsCanceled(e);
			
			saveLastFile(_file);
			
			dispatchFileChanged();
		}
		
		private function onSaveAsCanceled(e:Event):void
		{
			(e.currentTarget as File).removeEventListener(Event.SELECT, onSaveAsFileSelected);
			(e.currentTarget as File).removeEventListener(Event.CANCEL, onSaveAsCanceled);
		}
		
		public function getLastFile(forBrowse:Boolean = false):File
		{
			var file:File = Settings.lastFile == null ? null : new File(Settings.lastFile);
			while (file != null && !file.exists)
			{
				if (!forBrowse)
				{
					file = null;
					break;
				}
				else
				{
					file = file.parent;
				}
			}
			
			if (forBrowse && file == null)
			{
				file = File.desktopDirectory;
			}
			
			return file;
		}
		
		public function openFile(file:File):void
		{
			resetCurrentFile();
			
			_file = file;
			_file.addEventListener(Event.COMPLETE, openFileLoaded); 
			_file.load();
			
			saveLastFile(_file);
			dispatchFileChanged();
		}
		
		private function openFileLoaded(e:Event):void
		{
			var file:File = e.currentTarget as File;
			
			if (_file != file)
			{
				return;
			}
			
			_file.removeEventListener(Event.COMPLETE, openFileLoaded);
			var text:String = file.data.readUTFBytes(file.data.length);
			
			if (!initWithExternalConfig(text))
			{
				resetCurrentFile();
				DialogFormParams.create().setText(Texts.parsingError).show();
			}
		}
		
		public function initWithExternalConfig(source:String = null, rawData:Object = null, unsavedFile:Boolean = false, compareWithCurrentTable:Boolean = false):Boolean
		{
			var params:SerializerParams = new SerializerParams(source, rawData);
			
			deserializeTable(params);
			
			if (params.table == null)
			{
				newTable();
				return false;
			}
			
			_rootTable = params.table as ContainerTable;
			
			Settings.exportSettings.entries[0].serializerType = params.serializerType;
			Settings.saveExportSettings();
			
			_unsavedFile = unsavedFile;
			
			onTableChanged();
			
			return true;
		}
		
		public function serializeCurrentTable(serializerType:int, onlyBasic:Boolean = false):SerializerParams
		{
			if (_rootTable != null)
			{
				try
				{
					return _serializersByType[serializerType].serializeTable(_rootTable, onlyBasic);
				}
				catch (e:Error)
				{
				}
			}
			
			return null;
		}
		
		public function deserializeTable(params:SerializerParams, onlyBasic:Boolean = false):SerializerParams
		{
			var cacheRawDataByBasicType:Object = new Object();
			
			var deserializableTypes:Vector.<int> = SerializerType.ALL;
			var off:int = Math.max(0, deserializableTypes.indexOf(Settings.exportSettings.entries[0].serializerType));
			for (var i:int = 0; i < deserializableTypes.length; i++)
			{
				var type:int = deserializableTypes[(i + off) % deserializableTypes.length];
				
				var basicType:int = _serializersByType[type].basicType;
				
				if (cacheRawDataByBasicType[basicType] === null)
				{
					continue;
				}
				else if (cacheRawDataByBasicType[basicType] !== undefined)
				{
					params.rawData = cacheRawDataByBasicType[basicType];
				}
/*				try
				{*/
					_serializersByType[type].deserializeTable(params, onlyBasic);
/*				}
				catch (e:Error)
				{
					if (params.serializerType > -1)
					{
						DialogFormParams.create().setText("parsing error: " + e.message + "\n" + e.getStackTrace()).show();
						params.serializerType = -1;
					}
					continue;
				}*/
				
				if (params.basicSerializerType > -1)
				{
					cacheRawDataByBasicType[params.basicSerializerType] = params.rawData;
				}
				
				if (params.serializerType > -1 && onlyBasic)
				{
					return params;
				}
				if (params.table != null)
				{
					return params;
				}
			}
			
			return null;
		}
		
		private function resetCurrentFile():void
		{
			if (_file != null)
			{
				_file.removeEventListener(Event.COMPLETE, openFileLoaded);
				_file = null;
				dispatchFileChanged();
			}
		}
		
		private function onStageResize(e:Event):void
		{
			if (e != null && e.target != stage)
			{
				return;
			}
			
			_mainUI.setSize(stage.stageWidth, stage.stageHeight);
			
			DelayUtils.execute(saveWindowSizeAndPosition, 250, true);
			TooltipManager.instance.contentRegion = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
		private function onWindowMoved(e:Event):void
		{
			DelayUtils.execute(saveWindowSizeAndPosition, 250, true);
		}
		
		private function onAppClosing(e:Event):void
		{
			if (hasUnsavedChanges)
			{
				var confirmClose:Function = function():void
				{
					NativeApplication.nativeApplication.exit();
				}
				
				DialogFormParams.create()
					.setText(Texts.textConfirmCloseApp)
					.addButton(Texts.btnYes, confirmClose, null, Keyboard.ENTER)
					.addButton(Texts.btnCancel)
					.show();
				
				e.preventDefault();
				e.stopImmediatePropagation();
			}
		}
		
		private function saveWindowSizeAndPosition():void
		{
			Settings.windowWidth = stage.nativeWindow.width;
			Settings.windowHeight = stage.nativeWindow.height;
			Settings.windowX = stage.nativeWindow.x;
			Settings.windowY = stage.nativeWindow.y;
		}
		
		private function saveLastFile(file:File):void
		{
			Settings.lastFile = file.nativePath;
		}
		
		private function dispatchFileChanged():void
		{
			dispatchEvent(new TableEvent(TableEvent.FILE_CHANGED, _rootTable));
		}
		
		private function onTableChanged():void
		{
			_commandsHistory.clear();
			
			if (_rootTable != null)
			{
				_rootTable.cache.builder.build();
			}
			
			selectedTable = null;
			dispatchEvent(new TableEvent(TableEvent.TREE_CHANGED, _rootTable));
		}
		
		private function onBeforeCommandExecuted(e:CommandEvent):void
		{
			dispatchBeforeCommandEvent();
		}
		
		private function onCommandExecuted(e:CommandEvent):void
		{
			ProjectSettings.clearCache();
			
			var command:BaseCommand = e.cmd;
			
			var changeStringValueCommand:ChangeStringValueCommand = command as ChangeStringValueCommand;
			if (changeStringValueCommand != null)
			{
				if (changeStringValueCommand.tableRow.parent.meta.counterId == Counter.LOCALIZATION)
				{
					var keysToDelete:Vector.<String> = new Vector.<String>();
					if (changeStringValueCommand.columnIndex < Hardcode.LOCALIZTION_TABLE_NUM_SYSTEM_COLUMNS)
					{
						if (e.undo)
						{
							keysToDelete.push(changeStringValueCommand.newValue);
						}
						else
						{
							keysToDelete.push(changeStringValueCommand.oldValue);
						}
					}
					var rowsToUpdate:Vector.<TableRow> = Vector.<TableRow>([changeStringValueCommand.tableRow]);
				}
			}
			
			var deleteRowsCommand:DeleteRowsCommand = command as DeleteRowsCommand;
			if (deleteRowsCommand != null)
			{
				if (deleteRowsCommand.table.meta.counterId == Counter.LOCALIZATION)
				{
					if (e.undo)
					{
						rowsToUpdate = deleteRowsCommand.tableRows;
					}
					else
					{
						keysToDelete = new Vector.<String>();
						for each (var row:TableRow in deleteRowsCommand.tableRows)
						{
							keysToDelete.push(row.name);
						}
					}
				}
			}
			
			if (keysToDelete != null || rowsToUpdate != null)
			{
				Main.instance.rootTable.cache.builder.updateLocalizations(rowsToUpdate, keysToDelete);
				
				for each (row in rowsToUpdate)
				{
					cachedRow = _rootTable.cache.getDataRowByLocalizationKey(row.name);
					if (cachedRow != null)
					{
						cachedRow.dispatchChange();
					}
				}
				
				// clear cached table rows names
				// find any rows with same name as deleted and set localiztion to them
				rowsToUpdate = new Vector.<TableRow>();
				
				for each (var key:String in keysToDelete)
				{
					var cachedRow:TableRow = _rootTable.cache.getDataRowByLocalizationKey(key);
					if (cachedRow != null)
					{
						cachedRow.dispatchChange();
					}
					
					var localizatioinRows:Vector.<TableRow> = _rootTable.cache.localizationTable.rows;
					for each (row in localizatioinRows)
					{
						if (row.name == key)
						{
							rowsToUpdate.push(row);
						}
					}
				}
				Main.instance.rootTable.cache.builder.updateLocalizations(rowsToUpdate);
			}
			
			if (e.cmd.isImportant)
			{
				_rootTable.cache.builder.updateErrors();
			}
		}
		
		private var _unsavedFile:Boolean;
		public function get hasUnsavedChanges():Boolean
		{
			return _commandsHistory.hasUnsavedChanges || _unsavedFile;
		}
		
		private var _pressedKeys:Object = new Object();
		private function onKeyDown(e:KeyboardEvent):void
		{
			_pressedKeys[e.keyCode] = true;
		}
		private function onKeyUp(e:KeyboardEvent):void
		{
			delete _pressedKeys[e.keyCode];
		}
		public function isKeyDown(keyCode:uint):Boolean
		{
			return _pressedKeys[keyCode];
		}
	}
}