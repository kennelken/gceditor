package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Assets;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.helper.UploadPathData;
	import ru.kennel32.editor.data.serialize.SerializerType;
	import ru.kennel32.editor.data.settings.ExportSettingsEntry;
	import ru.kennel32.editor.data.settings.ProjectSettings;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.data.utils.ParseUtils;
	import ru.kennel32.editor.view.components.buttons.BtnAdd;
	import ru.kennel32.editor.view.components.HBox;
	import ru.kennel32.editor.view.components.buttons.LabeledButton;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.components.interfaces.IModalForm;
	import ru.kennel32.editor.view.components.tooltip.TooltipManager;
	import ru.kennel32.editor.view.components.windows.ModalBack;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.interfaces.ICustomPositionable;
	import ru.kennel32.editor.view.interfaces.ICustomSizeable;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class SettingsDialogContent extends BaseDialogContent implements IDisposable, ICustomSizeable, ICustomPositionable, IModalForm
	{
		private static const WIDTH:int = 980;
		
		private var _rowWidth:int = 980;
		
		private var _btnReset:LabeledButton;
		
		private var _boxButtons:HBox;
		private var _btnOk:LabeledButton;
		private var _btnCancel:LabeledButton;
		
		private var _boxUploadPaths:Sprite;
		private var _scrollableCanvasUploadPaths:ScrollableCanvas;
		private var _boxUploadPathsRows:Sprite;
		
		private var _boxExportSettings:Sprite;
		private var _scrollableCanvasExportSettings:ScrollableCanvas;
		private var _boxExportSettingsRows:Sprite;
		
		private var _tfTableScale:TextField;
		
		private var _exapleScriptInfo:LabeledButton;
		
		public function SettingsDialogContent()
		{
			super();
			
			var tfExportSettingsLabel:TextField = TextUtils.getText(Texts.textExportSettings, Color.FONT, 16);
			addChild(tfExportSettingsLabel);
			
			_boxExportSettings = new Sprite();
			_boxExportSettings.graphics.beginFill(Color.WHITE, 1);
			_boxExportSettings.graphics.lineStyle(1, Color.BORDER_LIGHT, 1);
			_boxExportSettings.graphics.drawRect(0, 0, WIDTH, 138);
			_boxExportSettings.y = int(tfExportSettingsLabel.y + tfExportSettingsLabel.textHeight + 3);
			attachContextMenu(_boxExportSettings, false);
			addChild(_boxExportSettings);
			
			var leftRightSpace:int = 5;
			_rowWidth = _boxExportSettings.width - 2 * leftRightSpace;
			
			var columnsNamesExportSettings:ExportSettingRow = new ExportSettingRow(_rowWidth, false, true);
			columnsNamesExportSettings.x = leftRightSpace;
			columnsNamesExportSettings.data = new ExportSettingsEntry(Texts.textSuffix, 0, false);
			_boxExportSettings.addChild(columnsNamesExportSettings);
			
			_scrollableCanvasExportSettings = new ScrollableCanvas(false, true);
			_scrollableCanvasExportSettings.x = leftRightSpace;
			_scrollableCanvasExportSettings.y = 21;
			_boxExportSettings.addChild(_scrollableCanvasExportSettings);
			_scrollableCanvasExportSettings.setSize(_rowWidth, _boxExportSettings.height - _scrollableCanvasExportSettings.y - 5);
			
			_boxExportSettingsRows = new Sprite();
			_scrollableCanvasExportSettings.setContent(_boxExportSettingsRows);
			_scrollableCanvasExportSettings.init();
			
			/////////////////////////////
			
			var tfUploadPathLabel:TextField = TextUtils.getText(Texts.textUploadPaths, Color.FONT, 16);
			tfUploadPathLabel.y = _scrollableCanvasExportSettings.y + _scrollableCanvasExportSettings.height + 40;
			addChild(tfUploadPathLabel);
			
			_exapleScriptInfo = new LabeledButton("i");
			_exapleScriptInfo.setSize(20, 20);
			_exapleScriptInfo.x = tfUploadPathLabel.x + tfUploadPathLabel.textWidth + 10;
			_exapleScriptInfo.y = tfUploadPathLabel.y + 0;
			TooltipManager.registerTooltip(_exapleScriptInfo, Texts.phpCodeExample);
			_exapleScriptInfo.addEventListener(MouseEvent.CLICK, onExampleScriptInfoClick);
			addChild(_exapleScriptInfo);
			
			_boxUploadPaths = new Sprite();
			_boxUploadPaths.graphics.beginFill(Color.WHITE, 1);
			_boxUploadPaths.graphics.lineStyle(1, Color.BORDER_LIGHT, 1);
			_boxUploadPaths.graphics.drawRect(0, 0, WIDTH, 137);
			_boxUploadPaths.y = int(tfUploadPathLabel.y + tfUploadPathLabel.textHeight + 3);
			attachContextMenu(_boxUploadPaths, false);
			addChild(_boxUploadPaths);
			
			var columnsNamesUploadPaths:UploadPathRow = new UploadPathRow(_rowWidth, false);
			columnsNamesUploadPaths.x = leftRightSpace;
			columnsNamesUploadPaths.data = new UploadPathData(Texts.textUploadPathName, Texts.textUploadPathUrl, Texts.textUploadPathKey, 0);
			_boxUploadPaths.addChild(columnsNamesUploadPaths);
			
			_scrollableCanvasUploadPaths = new ScrollableCanvas(false, true);
			_scrollableCanvasUploadPaths.x = leftRightSpace;
			_scrollableCanvasUploadPaths.y = 20;
			_boxUploadPaths.addChild(_scrollableCanvasUploadPaths);
			_scrollableCanvasUploadPaths.setSize(_rowWidth, _boxUploadPaths.height - _scrollableCanvasUploadPaths.y - 5);
			
			_boxUploadPathsRows = new Sprite();
			_scrollableCanvasUploadPaths.setContent(_boxUploadPathsRows);
			_scrollableCanvasUploadPaths.init();
			
			/////////////////////////////
			
			drawExportSettingsRows();
			drawUploadPathsRows();
			
			/////////////////////////////
			
			var valuesWidth:int = 630;
			var ySpace:int = 10;
			
			var tfTableScaleLabel:TextField = TextUtils.getText(Texts.textTableScale, Color.FONT, 18);
			tfTableScaleLabel.y = int(_boxUploadPaths.y + _boxUploadPaths.height + ySpace);
			addChild(tfTableScaleLabel);
			
			_tfTableScale = TextUtils.getInputText(Color.FONT, 18, valuesWidth);
			_tfTableScale.restrict = "0-9.";
			_tfTableScale.x = WIDTH - valuesWidth;
			_tfTableScale.y = tfTableScaleLabel.y;
			addChild(_tfTableScale);
			_tfTableScale.text = Settings.tableScale.toString();
			
			_btnReset = new LabeledButton(Texts.btnResetSettings);
			_btnReset.width = 220;
			_btnReset.scaleX = _btnReset.scaleY = 0.7;
			_btnReset.x = int((WIDTH - _btnReset.width * _btnReset.scaleX) / 2);
			_btnReset.y = int(tfTableScaleLabel.y + tfTableScaleLabel.height + ySpace + 30);
			_btnReset.addEventListener(MouseEvent.CLICK, onBtnReset);
			addChild(_btnReset);
			
			_boxButtons = new HBox();
			
			_btnOk = new LabeledButton(Texts.btnApply);
			_btnOk.addEventListener(MouseEvent.CLICK, onBtnOkClick);
			_boxButtons.addChild(_btnOk);
			
			_btnCancel = new LabeledButton(Texts.btnCancel);
			_btnCancel.addEventListener(MouseEvent.CLICK, onBtnCancelClick);
			_boxButtons.addChild(_btnCancel);
			
			_boxButtons.resize();
			_boxButtons.x = int((WIDTH - _boxButtons.width) / 2);
			_boxButtons.y = int(_btnReset.y + _btnReset.height + 30);
			addChild(_boxButtons);
			
			cacheAsBitmap = true;
		}
		
		private function drawUploadPathsRows():void
		{
			var paths:Array = Settings.uploadPaths;
			if (paths != null && paths.length > 0)
			{
				for (var i:int = 0; i < paths.length; i++)
				{
					var row:UploadPathRow = addRowUploadPath();
					row.data = UploadPathData.fromRawData(paths[i]);
				}
			}
			
			updateRowsPositions();
		}
		
		private function drawExportSettingsRows():void
		{
			var i:int = 0;
			for each (var setting:ExportSettingsEntry in Settings.exportSettings.entries)
			{
				var row:ExportSettingRow = addRowExportSetting(i++ > 0);
				row.data = setting;
			}
			_scrollableCanvasExportSettings.updateControls(false);
			updateRowsPositions();
		}
		
		private function onBtnOkClick(e:Event):void
		{
			var uploadPaths:Array = new Array();
			for (var i:int = 0; i < _boxUploadPathsRows.numChildren; i++)
			{
				var rowUploadPath:UploadPathRow = _boxUploadPathsRows.getChildAt(i) as UploadPathRow;
				if (!rowUploadPath.isEmpty)
				{
					uploadPaths.push(UploadPathData.toRawData(rowUploadPath.data));
				}
			}
			
			Settings.uploadPaths = uploadPaths.length > 0 ? uploadPaths : null;
			
			var exportSettings:Vector.<ExportSettingsEntry> = new Vector.<ExportSettingsEntry>();
			for (i = 0; i < _boxExportSettingsRows.numChildren; i++)
			{
				var rowExportSetting:ExportSettingRow = _boxExportSettingsRows.getChildAt(i) as ExportSettingRow;
				if (!rowExportSetting.isEmpty)
				{
					exportSettings.push(rowExportSetting.data);
				}
			}
			Settings.exportSettings.entries = exportSettings;
			Settings.saveExportSettings();
			
			Settings.tableScale = ParseUtils.readFloat(_tfTableScale.text);
			
			_parentForm.close();
		}
		
		private function onBtnCancelClick(e:Event):void
		{
			_parentForm.close();
		}
		
		private function onBtnReset(e:Event):void
		{
			DialogFormParams.create()
				.addButton(Texts.btnYes, onResetConfirm, null, Keyboard.ENTER)
				.addButton(Texts.btnCancel)
				.setText(Texts.textConfirmResetSettings)
				.show();
		}
		
		private function onResetConfirm():void
		{
			_parentForm.close();
			Settings.resetSavedSettings();
		}
		
		public function dispose():void
		{
			clearContextMenu(_boxUploadPaths);
			clearContextMenu(_boxExportSettings);
			
			while (_boxUploadPathsRows.numChildren > 0)
			{
				clearContextMenu(_boxUploadPathsRows.removeChildAt(0) as InteractiveObject);
			}
			while (_boxExportSettingsRows.numChildren > 0)
			{
				clearContextMenu(_boxExportSettingsRows.removeChildAt(0) as InteractiveObject);
			}
			
			_scrollableCanvasUploadPaths.dispose();
			_scrollableCanvasExportSettings.dispose();
			
			TooltipManager.unregisterTooltip(_exapleScriptInfo);
		}
		
		private function updateRowsPositions():void
		{
			for (var i:int = 0; i < _boxUploadPathsRows.numChildren; i++)
			{
				_boxUploadPathsRows.getChildAt(i).y = i * 23;
			}
			for (i = 0; i < _boxExportSettingsRows.numChildren; i++)
			{
				_boxExportSettingsRows.getChildAt(i).y = i * 23;
			}
			
			_scrollableCanvasUploadPaths.updateControls(false);
			_scrollableCanvasExportSettings.updateControls(false);
		}
		
		//////////////////////////////////
		
		private function attachContextMenu(target:InteractiveObject, allowDelete:Boolean):void
		{
			var contextMenu:ContextMenu = new ContextMenu();
			
			var contextMenuItemAdd:ContextMenuItem = new ContextMenuItem(Texts.textAdd);
			contextMenu.customItems.push(contextMenuItemAdd);
			contextMenuItemAdd.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemAdd);
			
			var contextMenuItemDelete:ContextMenuItem = new ContextMenuItem(Texts.textDelete);
			contextMenu.customItems.push(contextMenuItemDelete);
			contextMenuItemDelete.enabled = allowDelete;
			contextMenuItemDelete.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemDelete);
			
			target.contextMenu = contextMenu;
		}
		
		private function clearContextMenu(target:InteractiveObject):void
		{
			target.contextMenu = null;
		}
		
		private function onContextMenuItemAdd(e:ContextMenuEvent):void
		{
			if (_boxUploadPaths.contains(e.contextMenuOwner))
			{
				addRowUploadPath();
				updateRowsPositions();
				_scrollableCanvasUploadPaths.updateControls(false);
			}
			else if (_boxExportSettings.contains(e.contextMenuOwner))
			{
				addRowExportSetting();
				updateRowsPositions();
				_scrollableCanvasExportSettings.updateControls(false);
			}
		}
		
		private function addRowUploadPath():UploadPathRow
		{
			var row:UploadPathRow = new UploadPathRow(_rowWidth);
			row.data = new UploadPathData('', '', '', SerializerType.ALL[0]);
			
			_boxUploadPathsRows.addChild(row);
			attachContextMenu(row, true);
			attachContextMenu(row.tfName, true);
			attachContextMenu(row.tfName, true);
			attachContextMenu(row.tfPath, true);
			attachContextMenu(row.tfSerializer, true);
			
			return row;
		}
		
		private function addRowExportSetting(allowDelete:Boolean = true):ExportSettingRow
		{
			var row:ExportSettingRow = new ExportSettingRow(_rowWidth, true, !allowDelete);
			row.data = new ExportSettingsEntry('', SerializerType.ALL[0], false);
			_boxExportSettingsRows.addChild(row);
			attachContextMenu(row, allowDelete);
			attachContextMenu(row.tfSuffix, allowDelete);
			attachContextMenu(row.tfSerializer, allowDelete);
			attachContextMenu(row.tfExportOnSave, allowDelete);
			
			return row;
		}
		
		private function onContextMenuItemDelete(e:ContextMenuEvent):void
		{
			var rowUploadPath:UploadPathRow = e.contextMenuOwner as UploadPathRow;
			if (rowUploadPath == null && (e.contextMenuOwner as DisplayObject).parent is UploadPathRow)
			{
				rowUploadPath = (e.contextMenuOwner as DisplayObject).parent as UploadPathRow;
			}
			if (rowUploadPath != null)
			{
				clearContextMenu(rowUploadPath);
				_boxUploadPathsRows.removeChild(rowUploadPath);
				
				updateRowsPositions();
				_scrollableCanvasUploadPaths.updateControls(false);
			}
			else
			{
				var rowExportSetting:ExportSettingRow = e.contextMenuOwner as ExportSettingRow;
				if (rowExportSetting == null && (e.contextMenuOwner as DisplayObject).parent is ExportSettingRow)
				{
					rowExportSetting = (e.contextMenuOwner as DisplayObject).parent as ExportSettingRow;
				}
				if (rowExportSetting != null)
				{
					clearContextMenu(rowExportSetting);
					_boxExportSettingsRows.removeChild(rowExportSetting);
					
					updateRowsPositions();
					_scrollableCanvasExportSettings.updateControls(false);
				}
			}
		}
		
		private function onExampleScriptInfoClick(e:Event):void
		{
			var doCopyToClipboard:Function = function():void
			{
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, Assets.phpScriptExmaple, true);
				DialogFormParams.create()
					.setText(Texts.copiedToClipboard)
					.show();
			}
			
			DialogFormParams.create()
				.setText(Texts.phpCodeExample + '\n\n' + Assets.phpScriptExmaple)
				.setTextSize(7)
				.setTextAlign(TextFormatAlign.LEFT)
				.addButton(Texts.copy, doCopyToClipboard)
				.show();
		}
		
		override public function get width():Number 
		{
			return _boxUploadPaths.width;
		}
		
		override public function get height():Number 
		{
			return _boxButtons.y + _boxButtons.height + 1;
		}
		
		public function onPosOffsetChanged(x:int, y:int):void
		{
			Settings.settingsOffsetX = x;
			Settings.settingsOffsetY = y;
		}
		public function get posOffsetX():int
		{
			return Settings.settingsOffsetX;
		}
		public function get posOffsetY():int
		{
			return Settings.settingsOffsetY;
		}
		
		public function get modalBack():ModalBack
		{
			return null;
		}
		public function get isModal():Boolean
		{
			return false;
		}
	}
}


import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.ui.ContextMenu;
import ru.kennel32.editor.assets.Texts;
import ru.kennel32.editor.data.helper.UploadPathData;
import ru.kennel32.editor.data.serialize.SerializerType;
import ru.kennel32.editor.data.settings.ExportSettingsEntry;
import ru.kennel32.editor.view.components.controls.CheckBox;
import ru.kennel32.editor.view.components.selectbox.SelectBoxValue;
import ru.kennel32.editor.view.components.selectbox.SelectValueBox;
import ru.kennel32.editor.view.enum.Color;
import ru.kennel32.editor.view.enum.Filter;
import ru.kennel32.editor.view.utils.TextUtils;
import ru.kennel32.editor.view.utils.ViewUtils;

internal class UploadPathRow extends Sprite
{
	public var tfName:TextField;
	public var tfPath:TextField;
	public var tfKey:TextField;
	
	public var tfSerializer:TextField;
	public var selectSerializerBox:SelectValueBox;
	
	public function UploadPathRow(width:int, editable:Boolean = true)
	{
		var space:int = 2;
		width = width - 3 * space;
		
		tfName = TextUtils.getInputText(Color.FONT, 12, int(0.12 * width), false, 0, editable);
		tfName.height = 21;
		addChild(tfName);
		
		tfPath = TextUtils.getInputText(Color.FONT, 12, int(0.49 * width), false, 0, editable);
		tfPath.height = 21;
		addChild(tfPath);
		tfPath.x = tfName.x + tfName.width + space;
		
		tfKey = TextUtils.getInputText(Color.FONT, 12, 0.13 * width, false, 0, editable);
		tfKey.height = 21;
		addChild(tfKey);
		tfKey.x = tfPath.x + tfPath.width + space;
		
		tfSerializer = TextUtils.getInputText(Color.FONT, 12, width - tfName.width - tfPath.width - tfKey.width, false, 0, editable);
		tfSerializer.height = 21;
		tfSerializer.text = Texts.textUploadPathSerializerType;
		tfSerializer.mouseEnabled = false;
		tfSerializer.background = false;
		tfSerializer.x = tfKey.x + tfKey.width + space;
		
		selectSerializerBox = new SelectValueBox(tfSerializer.width, 22);
		selectSerializerBox.x = tfSerializer.x;
		
		if (!editable)
		{
			tfName.mouseEnabled = false;
			tfName.background = false;
			
			tfPath.mouseEnabled = false;
			tfPath.background = false;
			
			tfKey.mouseEnabled = false;
			tfKey.background = false;
			
			addChild(tfSerializer);
		}
		else
		{
			addChild(selectSerializerBox);
		}
		
		(tfName.contextMenu as ContextMenu).clipboardMenu = false;
		(tfPath.contextMenu as ContextMenu).clipboardMenu = false;
		(tfKey.contextMenu as ContextMenu).clipboardMenu = false;
		(tfSerializer.contextMenu as ContextMenu).clipboardMenu = false;
		
		tfName.addEventListener(Event.CHANGE, onTfChanged);
		tfPath.addEventListener(Event.CHANGE, onTfChanged);
		
		onTfChanged(null);
	}
	
	public function get data():UploadPathData
	{
		if (isEmpty)
		{
			return null;
		}
		
		return new UploadPathData(tfName.text, tfPath.text, tfKey.text, int(selectSerializerBox.value));
	}
	
	public function set data(value:UploadPathData):void
	{
		tfName.text = value == null ? '' : value.name;
		tfPath.text = value == null ? '' : value.path;
		tfKey.text = value == null ? '' : value.key;
		
		selectSerializerBox.setValue(value == null ? 0 : value.serializerType, SelectBoxValue.wrapToList(SerializerType.ALL, ViewUtils.serializersNames(SerializerType.ALL)));
		
		onTfChanged(null);
	}
	
	private function onTfChanged(e:Event):void
	{
		filters = isEmpty ? [Filter.INACTIVE_RED] : null;
	}
	
	public function get isEmpty():Boolean
	{
		return tfName.text.length <= 0 ||
			tfPath.text.length <= 0;
	}
}



internal class ExportSettingRow extends Sprite
{
	private var _isSystem:Boolean;
	private var _editable:Boolean;
	
	public var tfSuffix:TextField;
	
	public var tfSerializer:TextField;
	public var selectSerializerBox:SelectValueBox;
	
	public var tfExportOnSave:TextField;
	public var checkBoxExportOnSave:CheckBox;
	
	public function ExportSettingRow(width:int, editable:Boolean = true, isSystem:Boolean = false)
	{
		_isSystem = isSystem;
		_editable = editable;
		
		var space:int = 2;
		width = width - 3 * space;
		
		tfSuffix = TextUtils.getInputText(Color.FONT, 16, int(0.44 * width), false, 0, !isSystem);
		tfSuffix.height = 21;
		addChild(tfSuffix);
		
		tfSerializer = TextUtils.getInputText(Color.FONT, 16, int(0.40 * width), false, 0, !isSystem);
		tfSerializer.height = 21;
		tfSerializer.text = Texts.textUploadPathSerializerType;
		tfSerializer.mouseEnabled = false;
		tfSerializer.background = false;
		tfSerializer.x = tfSuffix.x + tfSuffix.width + space;
		
		selectSerializerBox = new SelectValueBox(tfSerializer.width, 22);
		selectSerializerBox.x = tfSerializer.x;
		
		tfExportOnSave = TextUtils.getInputText(Color.FONT, 16, width - tfSuffix.width - tfSerializer.width, false, 0, !isSystem);
		tfExportOnSave.height = 21;
		tfExportOnSave.text = Texts.exportOnSave;
		tfExportOnSave.mouseEnabled = false;
		tfExportOnSave.background = false;
		tfExportOnSave.x = tfSerializer.x + tfSerializer.width + space;
		
		checkBoxExportOnSave = new CheckBox(20);
		checkBoxExportOnSave.x = tfExportOnSave.x + int((tfExportOnSave.width - checkBoxExportOnSave.width) / 2);
		
		if (!_editable)
		{
			tfSuffix.mouseEnabled = false;
			tfSuffix.background = false;
			
			addChild(tfSerializer);
			addChild(tfExportOnSave);
		}
		else
		{
			addChild(selectSerializerBox);
			addChild(checkBoxExportOnSave);
		}
		
		(tfSuffix.contextMenu as ContextMenu).clipboardMenu = false;
		(tfSerializer.contextMenu as ContextMenu).clipboardMenu = false;
		(tfExportOnSave.contextMenu as ContextMenu).clipboardMenu = false;
		
		tfSuffix.mouseEnabled = !isSystem;
		checkBoxExportOnSave.enabled = !isSystem;
		
		tfSuffix.addEventListener(Event.CHANGE, onTfChanged);
		
		onTfChanged(null);
	}
	
	public function get data():ExportSettingsEntry
	{
		if (isEmpty)
		{
			return null;
		}
		
		return new ExportSettingsEntry(tfSuffix.text, int(selectSerializerBox.value), checkBoxExportOnSave.checked);
	}
	
	public function set data(value:ExportSettingsEntry):void
	{
		tfSuffix.text = value == null ? '' : value.suffix;
		checkBoxExportOnSave.checked = value.exportOnSave;
		
		var values:Vector.<int> = _isSystem ? SerializerType.ALL_DESERIALIZABLE : SerializerType.ALL;
		selectSerializerBox.setValue(value == null ? 0 : value.serializerType, SelectBoxValue.wrapToList(values, ViewUtils.serializersNames(values)));
		
		onTfChanged(null);
	}
	
	private function onTfChanged(e:Event):void
	{
		filters = isEmpty ? [Filter.INACTIVE_RED] : null;
	}
	
	public function get isEmpty():Boolean
	{
		return !_isSystem && tfSuffix.text.length <= 0;
	}
}