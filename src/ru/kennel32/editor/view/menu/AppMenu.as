package ru.kennel32.editor.view.menu
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.ui.Keyboard;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.BaseCommand;
	import ru.kennel32.editor.data.commands.CommandsHistory;
	import ru.kennel32.editor.data.commands.SelectTableCommand;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.helper.ObjectsCompareResult;
	import ru.kennel32.editor.data.helper.UploadPathData;
	import ru.kennel32.editor.data.serialize.SerializerParams;
	import ru.kennel32.editor.data.serialize.SerializerType;
	import ru.kennel32.editor.data.settings.ExportSettingsEntry;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.components.windows.WindowsCanvas;
	import ru.kennel32.editor.view.forms.dialog.DialogForm;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.forms.dialog.content.FindDialogContent;
	import ru.kennel32.editor.view.forms.dialog.content.SettingsDialogContent;
	
	public class AppMenu
	{
		private var _menuItemNewFile:NativeMenuItem;
		private var _menuItemOpenFile:NativeMenuItem;
		private var _menuItemSaveFile:NativeMenuItem;
		private var _menuItemSaveFileAs:NativeMenuItem;
		
		private var _menuItemUndo:NativeMenuItem;
		private var _menuItemRedo:NativeMenuItem;
		
		private var _menuItemFind:NativeMenuItem;
		private var _menuItemFindInProject:NativeMenuItem;
		
		private var _menuItemExportConfig:NativeMenu;
		private var _menuItemUploadConfig:NativeMenu;
		private var _menuItemRemoveConfig:NativeMenu;
		private var _menuItemPullConfig:NativeMenu;
		private var _menuItemSettings:NativeMenuItem;
		
		public function AppMenu()
		{
			
		}
		
		public function init():void
		{
			createNativeMenu();
			
			Main.instance.commandsHistory.addEventListener(Event.CHANGE, onCommandsHistoryChange);
			onCommandsHistoryChange(null);
			
			Settings.addEventListener(SettingsEvent.UPLOAD_PATHS_CHANGED, onUploadPathsChanged);
			onUploadPathsChanged(null);
			
			Settings.addEventListener(SettingsEvent.EXPORT_SETTINGS_CHANGED, onExportSettingsChanged);
			Main.instance.addEventListener(TableEvent.FILE_CHANGED, onExportSettingsChanged);
			onExportSettingsChanged(null);
			
			_findContent = new FindDialogContent();
		}
		
		private function createNativeMenu():void
		{
			var menu:NativeMenu = new NativeMenu();
			
			var fileMenu:NativeMenu = new NativeMenu();
			menu.addSubmenu(fileMenu, Texts.menuFile);
			
			_menuItemNewFile = fileMenu.addItem(new NativeMenuItem(Texts.menuNewFile));
				_menuItemNewFile.keyEquivalent = 'n';
				_menuItemNewFile.addEventListener(Event.SELECT, onNewFileMenu);
			_menuItemOpenFile = fileMenu.addItem(new NativeMenuItem(Texts.menuOpen));
				_menuItemOpenFile.keyEquivalent = 'o';
				_menuItemOpenFile.addEventListener(Event.SELECT, onOpenFileMenu);
			fileMenu.addItem(new NativeMenuItem("", true));
				_menuItemSaveFile = fileMenu.addItem(new NativeMenuItem(Texts.menuSave));
				_menuItemSaveFile.keyEquivalent = 's';
				_menuItemSaveFile.addEventListener(Event.SELECT, onSaveFileMenu);
			_menuItemSaveFileAs = fileMenu.addItem(new NativeMenuItem(Texts.menuSaveAs));
				_menuItemSaveFileAs.keyEquivalent = 'S';
				_menuItemSaveFileAs.addEventListener(Event.SELECT, onSaveFileAsMenu);
			
			//
			
			var editMenu:NativeMenu = new NativeMenu();
			menu.addSubmenu(editMenu, Texts.menuEdit);
			
			_menuItemUndo = editMenu.addItem(new NativeMenuItem());
				_menuItemUndo.keyEquivalent = 'z';
				_menuItemUndo.addEventListener(Event.SELECT, onUndoMenu);
			_menuItemRedo = editMenu.addItem(new NativeMenuItem());
				_menuItemRedo.keyEquivalent = 'y';
				_menuItemRedo.addEventListener(Event.SELECT, onRedoMenu);
			
			//
			
			var searchMenu:NativeMenu = new NativeMenu();
			menu.addSubmenu(searchMenu, Texts.menuSearch);
			
			_menuItemFind = searchMenu.addItem(new NativeMenuItem(Texts.menuFind));
				_menuItemFind.keyEquivalent = 'f';
				_menuItemFind.addEventListener(Event.SELECT, onFind);
			
			_menuItemFindInProject = searchMenu.addItem(new NativeMenuItem(Texts.menuFindInProject));
				_menuItemFindInProject.keyEquivalent = 'F';
				_menuItemFindInProject.addEventListener(Event.SELECT, onFindInProject);
			
			//
			
			var toolsMenu:NativeMenu = new NativeMenu();
			menu.addSubmenu(toolsMenu, Texts.menuTools);
			
			_menuItemExportConfig = new NativeMenu();
				toolsMenu.addSubmenu(_menuItemExportConfig, Texts.menuExportConfig);
			
			toolsMenu.addItem(new NativeMenuItem("", true));
			
			_menuItemUploadConfig = new NativeMenu();
				toolsMenu.addSubmenu(_menuItemUploadConfig, Texts.menuUploadConfig);
			_menuItemRemoveConfig = new NativeMenu();
				toolsMenu.addSubmenu(_menuItemRemoveConfig, Texts.menuRemoveConfig);
			_menuItemPullConfig = new NativeMenu();
				toolsMenu.addSubmenu(_menuItemPullConfig, Texts.menuPullConfig);
			
			toolsMenu.addItem(new NativeMenuItem("", true));
			
			_menuItemSettings = toolsMenu.addItem(new NativeMenuItem(Texts.menuSettings));
				_menuItemSettings.addEventListener(Event.SELECT, onSettingsMenu);
			//
			
			if (NativeWindow.supportsMenu)
			{
				Main.stage.nativeWindow.menu = menu;
			}
			else
			{
				NativeApplication.nativeApplication.menu = menu;
			}
			
		}
		
		private function onNewFileMenu(e:Event):void
		{
			if (Main.instance.hasUnsavedChanges)
			{
				DialogFormParams.create().setText(Texts.textConfirmNewFile)
					.addButton(Texts.btnYes, onNewFileConfirmed, null, Keyboard.ENTER)
					.addButton(Texts.btnCancel)
					.show();
			}
			else
			{
				onNewFileConfirmed();
			}
		}
		
		private function onNewFileConfirmed():void
		{
			Main.instance.newTable();
		}
		
		private function onOpenFileMenu(e:Event):void
		{
			if (Main.instance.hasUnsavedChanges)
			{
				DialogFormParams.create().setText(Texts.textConfirmOpenFile)
					.addButton(Texts.btnYes, onOpenFileConfirmed, null, Keyboard.ENTER)
					.addButton(Texts.btnCancel)
					.show();
			}
			else
			{
				onOpenFileConfirmed();
			}
		}
		
		private function onOpenFileConfirmed():void
		{
			var file:File = Main.instance.getLastFile(true);
			if (file == null)
			{
				file = File.desktopDirectory;
			}
			
			var extensions:Vector.<String> = Main.instance.allowedFilesExtensions.concat();
			for (var i:int = 0; i < extensions.length; i++)
			{
				extensions[i] = "*." + extensions[i];
			}
			
			file.browseForOpen(Texts.textOpenTable, [new FileFilter(Texts.textConfig, extensions.join(";"))]);
			file.addEventListener(Event.SELECT, onOpenFileSelected);
			file.addEventListener(Event.CANCEL, onOpenFileCanceled);
		}
		
		private function onSaveFileMenu(e:Event):void
		{
			Main.instance.saveTable();
		}
		
		private function onSaveFileAsMenu(e:Event):void
		{
			Main.instance.saveTableAs();
		}
		
		private function onUndoMenu(e:Event):void
		{
			Main.instance.commandsHistory.undo();
		}
		
		private function onRedoMenu(e:Event):void
		{
			Main.instance.commandsHistory.redo();
		}
		
		private function onOpenFileSelected(e:Event):void
		{
			Main.instance.openFile(e.currentTarget as File);
			
			onOpenFileCanceled(e);
		}
		
		private function onOpenFileCanceled(e:Event):void
		{
			(e.currentTarget as File).addEventListener(Event.SELECT, onOpenFileSelected);
			(e.currentTarget as File).addEventListener(Event.CANCEL, onOpenFileCanceled);
		}
		
		private function onCommandsHistoryChange(e:Event):void
		{
			var prevCommand:BaseCommand = Main.instance.commandsHistory.getPrevCommand();
			_menuItemUndo.enabled = prevCommand != null;
			_menuItemUndo.label = Texts.menuUndo + (prevCommand == null ? '' : (' ' + prevCommand.description));
			
			var nextCommand:BaseCommand = Main.instance.commandsHistory.getNextCommand();
			_menuItemRedo.enabled = nextCommand != null;
			_menuItemRedo.label = Texts.menuRedo + (nextCommand == null ? '' : (' ' + nextCommand.description));
		}
		
		private function onSettingsMenu(e:Event):void
		{
			var settingsContent:SettingsDialogContent = new SettingsDialogContent();
			
			DialogFormParams.create().setContent(settingsContent).setText(Texts.menuSettings).show();
		}
		
		///////////////
		
		private function onExportSettingsChanged(e:Event):void
		{
			_menuItemExportConfig.removeAllItems();
			if (Main.instance.file == null)
			{
				return;
			}
			
			for each (var setting:ExportSettingsEntry in Settings.exportSettings.entries)
			{
				var item:NativeMenuItem = new NativeMenuItem(Main.instance.getExportFileName(setting));
				_menuItemExportConfig.addItem(item);
				item.addEventListener(Event.SELECT, onExportConfigSelected);
			}
		}
		
		private function onExportConfigSelected(e:Event):void
		{
			var exportConfigIndex:int = _menuItemExportConfig.getItemIndex(e.currentTarget as NativeMenuItem);
			Main.instance.exportTable(Settings.exportSettings.entries[exportConfigIndex]);
		}
		
		///////////////
		
		private function onUploadPathsChanged(e:Event):void
		{
			_menuItemUploadConfig.removeAllItems();
			_menuItemRemoveConfig.removeAllItems();
			_menuItemPullConfig.removeAllItems();
			
			for each (var pathInfo:Array in Settings.uploadPaths)
			{
				var item:NativeMenuItem = new NativeMenuItem(UploadPathData.fromRawData(pathInfo).name);
				_menuItemUploadConfig.addItem(item);
				item.addEventListener(Event.SELECT, onUploadConfigPathSelected);
				
				item = new NativeMenuItem(UploadPathData.fromRawData(pathInfo).name);
				_menuItemRemoveConfig.addItem(item);
				item.addEventListener(Event.SELECT, onRemoveConfigPathSelected);
				
				item = new NativeMenuItem(UploadPathData.fromRawData(pathInfo).name);
				_menuItemPullConfig.addItem(item);
				item.addEventListener(Event.SELECT, onPullConfigPathSelected);
			}
		}
		
		private var _uploadConfigIndex:int;
		private function onUploadConfigPathSelected(e:Event):void
		{
			_uploadConfigIndex = _menuItemUploadConfig.getItemIndex(e.currentTarget as NativeMenuItem);
			sendConfigRequest(_uploadConfigIndex, onPullConfigBeforeUploadComplete, onPullConfigError, false, true);
		}
		
		private function onPullConfigBeforeUploadComplete(e:Event):void
		{
			WindowsCanvas.instance.removeFormByClass(DialogForm);
			
			var data:Object = JSON.parse((e.currentTarget as URLLoader).data);
			var errorStatus:int = data['errorStatus'];
			switch (errorStatus)
			{
				case 0:
				case 2:
					var configSource:String = data['config'];
					compareRemoteConfigWithCurrent(configSource, onUploadConfigConfirmed, true)
					break;
				
				case 1:
					DialogFormParams.create().setText(Texts.errorInvalidKey).show();
					break;
				
				default:
					DialogFormParams.create().setText(Texts.errorUnexpectedError).show();
					break;
			}
		}
		
		private function onUploadConfigConfirmed():void
		{
			sendConfigRequest(_uploadConfigIndex, onUploadConfigComplete, onUploadConfigError, true);
		}
		
		private function onUploadConfigComplete(e:Event):void
		{
			WindowsCanvas.instance.removeFormByClass(DialogForm);
			DialogFormParams.create().setText(Texts.textUploadConfigComplete).show();
		}
		
		private function onUploadConfigError(e:Event):void
		{
			WindowsCanvas.instance.removeFormByClass(DialogForm);
			DialogFormParams.create().setText(Texts.textUploadConfigError).show();
		}
		
		///////////////
		
		private function onRemoveConfigPathSelected(e:Event):void
		{
			var configIndex:int = _menuItemRemoveConfig.getItemIndex(e.currentTarget as NativeMenuItem);
			
			DialogFormParams.create().setText(Texts.textConfirmRemoveConfig)
				.addButton(Texts.btnYes, onRemoveConfigConfirmed, [configIndex], Keyboard.ENTER)
				.addButton(Texts.btnCancel)
				.show();
		}
		
		private function onRemoveConfigConfirmed(configIndex:int):void
		{
			sendConfigRequest(configIndex, onRemoveConfigComplete, onRemoveConfigError);
		}
		
		private function onRemoveConfigComplete(e:Event):void
		{
			WindowsCanvas.instance.removeFormByClass(DialogForm);
			DialogFormParams.create().setText(Texts.textRemoveConfigComplete).show();
		}
		
		private function onRemoveConfigError(e:Event):void
		{
			WindowsCanvas.instance.removeFormByClass(DialogForm);
			DialogFormParams.create().setText(Texts.textRemoveConfigError).show();
		}
		
		///////////////
		
		private function onPullConfigPathSelected(e:Event):void
		{
			sendConfigRequest(_menuItemPullConfig.getItemIndex(e.currentTarget as NativeMenuItem), onPullConfigComplete, onPullConfigError, false, true);
		}
		
		private function onPullConfigComplete(e:Event):void
		{
			WindowsCanvas.instance.removeFormByClass(DialogForm);
			
			var data:Object = JSON.parse((e.currentTarget as URLLoader).data);
			var errorStatus:int = data['errorStatus'];
			switch (errorStatus)
			{
				case 0:
					var configRaw:String = data['config'];
					compareRemoteConfigWithCurrent(configRaw, onPullConfigConfirmed)
					break;
				
				case 1:
					DialogFormParams.create().setText(Texts.errorInvalidKey).show();
					break;
				
				case 2:
					DialogFormParams.create().setText(Texts.errorConfigDoesNotExist).show();
					break;
				
				default:
					DialogFormParams.create().setText(Texts.errorUnexpectedError).show();
					break;
			}
		}
		
		private function onPullConfigConfirmed(rawData:Object):void
		{
			if (rawData != null)
			{
				if (!Main.instance.initWithExternalConfig('', rawData, true, true))
				{
					DialogFormParams.create().setText(Texts.parsingError);
				}
			}
		}
		
		private function onPullConfigError(e:Event):void
		{
			WindowsCanvas.instance.removeFormByClass(DialogForm);
			DialogFormParams.create().setText(Texts.textPullConfigError).show();
		}
		
		///////////////
		
		private function compareRemoteConfigWithCurrent(configSource:String, yesCallback:Function, forUpload:Boolean = false):void
		{
			var remoteConfig:SerializerParams = Main.instance.deserializeTable(new SerializerParams(configSource), true);
			var currentTableRawData:Object = remoteConfig != null && remoteConfig.serializerType > -1 ? Main.instance.serializeCurrentTable(remoteConfig.serializerType).rawData : null;
			
			if (remoteConfig == null || remoteConfig.serializerType <= -1)
			{
				message = Texts.remoteConfigMissing;
				if (!forUpload)
				{
					yesCallback = null;
				}
			}
			else if (currentTableRawData == null)
			{
				message = Texts.currentConfigIsEmprty;
			}
			else
			{
				var compareResult:ObjectsCompareResult = ObjectsCompareResult.compare(
					forUpload ? remoteConfig.rawData : currentTableRawData,
					forUpload ? currentTableRawData : remoteConfig.rawData
				);
				
				if (!compareResult.hasChanges && _uploadPathData.serializerType == remoteConfig.serializerType)
				{
					message = Texts.textConfigUnmodified;
					yesCallback = null;
				}
				else
				{
					var message:String = 
						(_uploadPathData.serializerType != remoteConfig.serializerType ? 
							Texts.configHasDifferentSerializerType(Texts.serializerName(remoteConfig.serializerType), Texts.serializerName(_uploadPathData.serializerType)) + "\n\n" :
								"") +
						Texts.textNumAddedEntries + compareResult.numAddedProps + '\n' +
						Texts.textNumDeletedEntries + compareResult.numDeletedProps + '\n' +
						Texts.textNumChangedEntries + compareResult.numChangedProps + '\n\n' +
						(forUpload ? Texts.textConfirmUploadConfig : Texts.textConfirmPullConfig);
				}
			}
			
			var params:DialogFormParams = DialogFormParams.create().setText(message);
			if (yesCallback != null)
			{
				params.addButton(Texts.btnYes, yesCallback, !forUpload ? [remoteConfig.rawData] : null, Keyboard.ENTER);
				params.addButton(Texts.btnCancel);
			}
			params.show();
		}
		
		private var _uploadPathData:UploadPathData;
		private function sendConfigRequest(index:int, callbackOk:Function, callbackError:Function, toPush:Boolean = false, toPull:Boolean = false):void
		{
			if (toPush && toPull)
			{
				throw new Error('Can not push and pull simultaneously');
			}
			
			_uploadPathData = UploadPathData.fromRawData(Settings.uploadPaths[index]);
			
			var request:URLRequest = new URLRequest(_uploadPathData.path);
			request.method = URLRequestMethod.POST;
			var urlVars:URLVariables = new URLVariables;
			urlVars['key'] = _uploadPathData.key;
			if (toPush)
			{
				urlVars['config'] = Main.instance.rootToString(_uploadPathData.serializerType);
			}
			if (toPull)
			{
				urlVars['pull'] = true;
			}
			
			request.data = urlVars;
			
			DialogFormParams.create().setText(Texts.textPleaseWait).setImportant(true).show();
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, callbackOk);
			loader.addEventListener(IOErrorEvent.IO_ERROR, callbackError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, callbackError);
			loader.load(request);
		}
		
		////////////////////
		//
		private var _findContent:FindDialogContent;
		
		private function onFind(e:Event):void
		{
			FindDialogContent.openDialog(false);
		}
		
		private function onFindInProject(e:Event):void
		{
			FindDialogContent.openDialog(true);
		}
	}
}