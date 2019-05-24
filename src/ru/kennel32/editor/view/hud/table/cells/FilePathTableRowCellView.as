package ru.kennel32.editor.view.hud.table.cells
{
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.AddRowCommand;
	import ru.kennel32.editor.data.commands.ChangeStringValueCommand;
	import ru.kennel32.editor.data.commands.InspectRowCommand;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.data.utils.LocalizationUtils;
	import ru.kennel32.editor.view.components.buttons.BtnAdd;
	import ru.kennel32.editor.view.components.buttons.BtnDelete;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.dialog.DialogFormButtonParams;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class FilePathTableRowCellView extends BaseTableRowCellView
	{
		private static const IMAGE_EXTENSIONS:Object = {'png':true, 'jpg':true, 'jpeg':true, 'gif':true, 'swf':true};
		
		private static var MIN_IMAGE_HEIGHT:int = 100;
		private static var MAX_IMAGE_HEIGHT:int = 500;
		
		private var _btnDelete:BtnDelete;
		private var _btnUpload:BtnAdd;
		private var _tf:TextField;
		
		private var _fileUrl:String;
		private var _fileExists:Boolean;
		private var _file:File;
		
		private var _canvas:ScrollableCanvas;
		private var _loader:Loader;
		
		public function FilePathTableRowCellView()
		{
			super();
			
			_tf = TextUtils.getText('', Color.FONT, 11, null, true, -3);
			_tf.selectable = true;
			_tf.autoSize = TextFieldAutoSize.NONE;
			_tf.height = DEFAULT_TF_HEIGHT - 5;
			
			_canvas = new ScrollableCanvas();
			_canvas.x = 2;
			_canvas.y = DEFAULT_HEIGHT;
			
			_loader = new Loader();
			_canvas.setContent(_loader);
			
			_btnDelete = new BtnDelete(15);
			_btnDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
			
			_btnUpload = new BtnAdd(15);
			_btnUpload.addEventListener(MouseEvent.CLICK, onUploadClick);
			
			addChild(_tf);
			
			_type = TableColumnDescriptionType.FILE_PATH;
			
			addEventListener(MouseEvent.CLICK, onMouseClick, false, int.MAX_VALUE);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_btnUpload.x = _width - _btnUpload.width - 4;
			_btnDelete.x = _btnUpload.x - _btnDelete.width - 2;
			
			_tf.x = 3;
			_tf.y = _isVertical ? 2 : (_height - _tf.height) / 2 - 1;
			_tf.width = _btnDelete.x - _tf.x;
			
			_btnDelete.y = _tf.y + 1;
			_btnUpload.y = _btnDelete.y;
			
			updateHeight();
		}
		
		override public function updateValue():void 
		{
			super.updateValue();
			
			var url:String = _tableRow.getFullFilePath(_columnData);
			
			_file = new File();
			_file.url = url;
			_fileExists = _file.exists;
			
			if (url != _fileUrl || _toCheckImageSize)
			{
				if (_fileExists && (_isVertical || _toCheckImageSize))
				{
					if (_file.extension != null && IMAGE_EXTENSIONS[fileExtension(false)])
					{
						_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadingComplete);
						_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadingError);
						_loader.load(new URLRequest(url));
					}
					else
					{
						_loader.unloadAndStop();
					}
				}
				else
				{
					_loader.unloadAndStop();
				}
			}
			
			_canvas.init();
			updateHeight();
			
			ViewUtils.setParent(_canvas, this, _fileExists && _isVertical, 1);
			_fileUrl = url;
			_tf.alpha = _fileExists ? 1 : 0.5;
			
			ViewUtils.setParent(_btnUpload, this, true);
			ViewUtils.setParent(_btnDelete, this, _fileExists);
			
			_tf.text = url;
			
			_tf.setSelection(_tf.text.length - 1, _tf.text.length - 1);
			
			Settings.addEventListener(SettingsEvent.FILES_ROOT_CHANGED, onFilesRootChanged);
			addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragOver);
			addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDragDrop);
		}
		
		private function fileExtension(addDot:Boolean = true):String
		{
			return _file != null && _file.extension != null ? _file.extension.toLowerCase() : '';
		}
		
		private function updateHeight(silent:Boolean = true):void
		{
			if (_file == null)
			{
				return;
			}
			
			var imageHeight:int = Math.min(MAX_IMAGE_HEIGHT, Math.max(MIN_IMAGE_HEIGHT, _columnData.fileImageSize[1]));
			_contentHeight = DEFAULT_HEIGHT + (_isVertical && IMAGE_EXTENSIONS[fileExtension(false)] ? imageHeight + 3 : 0);
			_canvas.setSize(_width - _canvas.x * 2, imageHeight);
			
			if (silent)
			{
				_canvas.updateControls(false);
			}
			else
			{
				dispatchHeightChanged();
			}
		}
		
		private function onLoadingComplete(e:Event):void
		{
			onLoadingResult(true);
		}
		
		private function onLoadingError(e:Event):void
		{
			onLoadingResult(false);
		}
		
		private function onLoadingResult(result:Boolean):void
		{
			if (result && _toCheckImageSize)
			{
				if (_columnData.fileImageSize[0] > 0 && _loader.contentLoaderInfo.width != _columnData.fileImageSize[0] ||
					_columnData.fileImageSize[1] > 0 && _loader.contentLoaderInfo.height != _columnData.fileImageSize[1])
				{
					DialogFormParams.create()
						.setText(Texts.incorrectImageSize)
						.addButton(Texts.btnOk, null, null, Keyboard.ENTER)
						.setCloseCallback(new DialogFormButtonParams('', onIncorrectSizeMessageClosed))
						.show();
					
					result = false;
				}
			}
			
			if (_toCheckImageSize)
			{
				Main.instance.mainUI.playAttentionEffect(this, !result);
				_toCheckImageSize = false;
			}
			_canvas.updateControls(false);
		}
		
		private function onIncorrectSizeMessageClosed():void
		{
			Main.instance.mainUI.playAttentionEffect(this, true);
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (!ViewUtils.isForInspect(e))
			{
				return;
			}
			
			e.preventDefault();
			e.stopImmediatePropagation();
			
			if (_fileExists)
			{
				try
				{
					_file.openWithDefaultApplication();
				}
				catch (e:Error)
				{
					DialogFormParams.create()
						.setText(Texts.errorOpeningFile)
						.show();
				}
			}
		}
		
		private function onDeleteClick(e:MouseEvent):void
		{
			if (ViewUtils.isSpecialKey(e))
			{
				return;
			}
			
			DialogFormParams.create()
				.setText(Texts.confirmDeleteFile(_file.name + '.' + _file.extension))
				.addButton(Texts.btnYes, onDeleteConfirmed, [_file], Keyboard.ENTER)
				.addButton(Texts.btnCancel)
				.show();
		}
		
		private function onDeleteConfirmed(file:File):void
		{
			try
			{
				file.deleteFile();
				_tableRow.dispatchChange();
			}
			catch (e:Error)
			{
				DialogFormParams.create().setText(Texts.errorOccured).addButton(Texts.btnOk, null, null, Keyboard.ENTER).show();
				Main.instance.mainUI.playAttentionEffect(this, true);
			}
		}
		
		private function onUploadClick(e:MouseEvent):void
		{
			if (ViewUtils.isSpecialKey(e))
			{
				return;
			}
			
			var newFile:File = new File(_fileUrl)
			
			if (_columnData.fileExtension != null && _columnData.fileExtension.length > 0)
			{
				var filters:Array = [new FileFilter('*.' + _columnData.fileExtension + ' file', '*.' + _columnData.fileExtension)];
			}
			
			newFile.addEventListener(Event.SELECT, onFileSelected);
			newFile.browseForOpen(Texts.chooseFileForUpload, filters);
		}
		
		private var _toCheckImageSize:Boolean;
		private function onFileSelected(e:Event):void
		{
			uploadFile(e.currentTarget as File);
		}
		
		private function uploadFile(file:File):void
		{
			_toCheckImageSize = true;
			
			try
			{
				file.copyTo(_file, true);
				_tableRow.dispatchChange();
			}
			catch (e:Error)
			{
				DialogFormParams.create().setText(Texts.errorOccured).addButton(Texts.btnOk, null, null, Keyboard.ENTER).show();
				Main.instance.mainUI.playAttentionEffect(this, true);
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			_fileUrl = null;
			_canvas.dispose();
			
			Settings.removeEventListener(SettingsEvent.FILES_ROOT_CHANGED, onFilesRootChanged);
			removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragOver);
			removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDragDrop);
		}
		
		private function onFilesRootChanged(e:Event):void
		{
			updateValue();
		}
		
		private function onDragOver(e:NativeDragEvent):void
		{
			if (e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				var filesList:Vector.<File> = Vector.<File>(e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array);
				for each (var file:File in filesList)
				{
					if (_columnData.fileExtension == null || _columnData.fileExtension.length <= 0 || file.extension == _columnData.fileExtension)
					{
						NativeDragManager.acceptDragDrop(this);
						return;
					}
				}
			}
		}
		private function onDragDrop(e:NativeDragEvent):void
		{
			var filesList:Vector.<File> = Vector.<File>(e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array);
			for each (var file:File in filesList)
			{
				if (_columnData.fileExtension == null || _columnData.fileExtension.length <= 0 || file.extension == _columnData.fileExtension)
				{
					uploadFile(file);
					return;
				}
			}
		}
	}
}