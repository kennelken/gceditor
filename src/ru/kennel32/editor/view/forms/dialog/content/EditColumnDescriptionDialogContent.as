package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.commands.AddColumnCommand;
	import ru.kennel32.editor.data.commands.EditColumnCommand;
	import ru.kennel32.editor.data.utils.ParseUtils;
	import ru.kennel32.editor.view.components.controls.CheckBox;
	import ru.kennel32.editor.view.components.HBox;
	import ru.kennel32.editor.view.components.buttons.LabeledButton;
	import ru.kennel32.editor.view.components.selectbox.SelectBoxValue;
	import ru.kennel32.editor.view.components.selectbox.SelectItemBox;
	import ru.kennel32.editor.view.components.selectbox.SelectValueBox;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.interfaces.IAllowCommandsHistoryChange;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.FormsUtils;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class EditColumnDescriptionDialogContent extends BaseDialogContent implements IAllowCommandsHistoryChange, IDisposable
	{
		private static const ROWS_HEIGHT:int = 26;
		private static const INPUT_WIDTH:int = 350;
		
		private var _table:BaseTable;
		private var _srcDescription:TableColumnDescription;
		private var _description:TableColumnDescription;
		
		private var _tfInputName:TextField;
		private var _selectTypeBox:SelectValueBox;
		private var _checkBoxLock:CheckBox;
		private var _checkBoxMustBeNonEmpty:CheckBox;
		private var _tfInputTag:TextField;
		private var _tfInputDescription:TextField;
		private var _tfInputDefaultValue:TextField;
		
		private var _boxSelectCounter:Sprite;
		private var _selectCounterBox:SelectItemBox;
		
		private var _boxUseAsName:Sprite;
		private var _checkBoxUseAsName:CheckBox;
		
		private var _boxTextPattern:Sprite;
		private var _tfInputTextPattern:TextField;
		
		private var _boxFilePath:Sprite;
		private var _tfFilePath:TextField;
		private var _tfFileExtension:TextField;
		private var _tfFileImageSizeWidth:TextField;
		private var _tfFileImageSizeHeight:TextField;
		
		private var _boxSelectMeta:Sprite;
		private var _selectMetaBox:SelectValueBox;
		
		private var _boxButtons:HBox;
		private var _btnOk:LabeledButton;
		private var _btnCancel:LabeledButton;
		
		public function EditColumnDescriptionDialogContent(table:BaseTable, srcDescription:TableColumnDescription)
		{
			super();
			
			_table = table;
			_srcDescription = srcDescription;
			
			if (_srcDescription != null)
			{
				_description = new TableColumnDescription();
				_description.copyFrom(_srcDescription);
			}
			else
			{
				_description = TableColumnDescription.create(TableColumnDescriptionType.INT_VALUE, "newColumnTag", false, 0, false);
				_description.name = "new column";
				_description.description = "new column\ndescription";
				_description.defaultValue = TableColumnDescription.getDefaultValue(int(_description.type));
			}
			
			var rightColumnX:int = 0;
			
			var tfName:TextField = TextUtils.getText(Texts.textName, Color.FONT, 16);
			tfName.height = tfName.textHeight + 4;
			addChild(tfName);
			rightColumnX = Math.max(rightColumnX, tfName.width);
			
			var tfType:TextField = TextUtils.getText(Texts.textType, Color.FONT, 16);
			tfType.height = tfType.textHeight + 4;
			tfType.y = tfName.y + ROWS_HEIGHT;
			addChild(tfType);
			rightColumnX = Math.max(rightColumnX, tfType.width);
			
			var tfLock:TextField = TextUtils.getText(Texts.textLock, Color.FONT, 16);
			tfLock.height = tfLock.textHeight + 4;
			tfLock.y = tfType.y + ROWS_HEIGHT;
			addChild(tfLock);
			rightColumnX = Math.max(rightColumnX, tfLock.width);
			
			var tfMustBeNonEmpty:TextField = TextUtils.getText(Texts.textMustBeNonEmpty, Color.FONT, 16);
			tfMustBeNonEmpty.height = tfMustBeNonEmpty.textHeight + 4;
			tfMustBeNonEmpty.y = tfLock.y + ROWS_HEIGHT;
			addChild(tfMustBeNonEmpty);
			rightColumnX = Math.max(rightColumnX, tfMustBeNonEmpty.width);
			
			var tfTag:TextField = TextUtils.getText(Texts.textTag, Color.FONT, 16);
			tfTag.height = tfTag.textHeight + 4;
			tfTag.y = tfMustBeNonEmpty.y + ROWS_HEIGHT;
			addChild(tfTag);
			rightColumnX = Math.max(rightColumnX, tfTag.width);
			
			var tfDescription:TextField = TextUtils.getText(Texts.textDescription, Color.FONT, 16);
			tfDescription.height = tfDescription.textHeight + 4;
			tfDescription.y = tfTag.y + ROWS_HEIGHT;
			addChild(tfDescription);
			rightColumnX = Math.max(rightColumnX, tfDescription.width);
			
			var tfDefaultValue:TextField = TextUtils.getText(Texts.textDefaultValue, Color.FONT, 16);
			tfDefaultValue.height = tfDefaultValue.textHeight + 4;
			tfDefaultValue.y = tfDescription.y + ROWS_HEIGHT + 80;
			addChild(tfDefaultValue);
			rightColumnX = Math.max(rightColumnX, tfDefaultValue.width);
			
			_boxSelectCounter = new Sprite();
			_boxSelectCounter.y = tfDefaultValue.y + ROWS_HEIGHT;
			addChild(_boxSelectCounter);
			
			var tfCounter:TextField = TextUtils.getText(Texts.textCounter, Color.FONT, 16);
			tfCounter.height = tfCounter.textHeight + 4;
			_boxSelectCounter.addChild(tfCounter);
			rightColumnX = Math.max(rightColumnX, tfCounter.width);
			
			_boxUseAsName = new Sprite();
			_boxUseAsName.y = _boxSelectCounter.y;
			addChild(_boxUseAsName);
			
			var tfUseAsName:TextField = TextUtils.getText(Texts.textUseAsName, Color.FONT, 16);
			tfUseAsName.height = tfUseAsName.textHeight + 4;
			_boxUseAsName.addChild(tfUseAsName);
			rightColumnX = Math.max(rightColumnX, tfUseAsName.width);
			
			_boxTextPattern = new Sprite();
			_boxTextPattern.y = _boxSelectCounter.y + ROWS_HEIGHT;
			addChild(_boxTextPattern);
			
			var tfTextPattern:TextField = TextUtils.getText(Texts.textTextPattern, Color.FONT, 16);
			tfTextPattern.height = tfTextPattern.textHeight + 4;
			_boxTextPattern.addChild(tfTextPattern);
			rightColumnX = Math.max(rightColumnX, tfTextPattern.width);
			
			_boxFilePath = new Sprite();
			_boxFilePath.y = _boxSelectCounter.y + ROWS_HEIGHT;
			addChild(_boxFilePath);
			
			var tfFilePath:TextField = TextUtils.getText(Texts.textFilePath, Color.FONT, 16);
			tfFilePath.height = tfFilePath.textHeight + 4;
			_boxFilePath.addChild(tfFilePath);
			rightColumnX = Math.max(rightColumnX, tfFilePath.width);
			
			var tfFileExtension:TextField = TextUtils.getText(Texts.textFileExtension, Color.FONT, 16);
			tfFileExtension.height = tfFileExtension.textHeight + 4;
			tfFileExtension.y = ROWS_HEIGHT;
			_boxFilePath.addChild(tfFileExtension);
			rightColumnX = Math.max(rightColumnX, tfFileExtension.width);
			
			var tfFileImageSize:TextField = TextUtils.getText(Texts.textFileImageSize, Color.FONT, 16);
			tfFileImageSize.height = tfFileImageSize.textHeight + 4 + 1;
			tfFileImageSize.y = ROWS_HEIGHT * 2;
			_boxFilePath.addChild(tfFileImageSize);
			rightColumnX = Math.max(rightColumnX, tfFileImageSize.width);
			
			_boxSelectMeta = new Sprite();
			_boxSelectMeta.y = _boxFilePath.y;
			addChild(_boxSelectMeta);
			
			var tfSelectMeta:TextField = TextUtils.getText(Texts.textSelectMeta, Color.FONT, 16);
			tfSelectMeta.height = tfSelectMeta.textHeight + 4;
			_boxSelectMeta.addChild(tfSelectMeta);
			rightColumnX = Math.max(rightColumnX, tfSelectMeta.width);
			
			rightColumnX += 50;
			
			_tfInputName = TextUtils.getInputText(Color.FONT, 16, INPUT_WIDTH);
			_tfInputName.x = rightColumnX;
			_tfInputName.y = tfName.y;
			_tfInputName.addEventListener(Event.CHANGE, onChange);
			_tfInputName.text = _description.name != null ? _description.name : '';
			addChild(_tfInputName);
			
			_selectTypeBox = new SelectValueBox(INPUT_WIDTH + 1, ROWS_HEIGHT - 3);
			_selectTypeBox.x = rightColumnX;
			_selectTypeBox.y = tfType.y;
			_selectTypeBox.addEventListener(Event.CHANGE, onTypeChange);
			addChild(_selectTypeBox);
			var typeValues:Vector.<uint>;
			switch (_description.type)
			{
				case TableColumnDescriptionType.ID:
				case TableColumnDescriptionType.COUNTER:
					typeValues = Vector.<uint>([_description.type]);
					break;
				
				default:
					typeValues = _table.meta.forInnerTable ? TableColumnDescriptionType.FOR_INNER_TABLE : TableColumnDescriptionType.ALL_BUT_SYSTEM;
					break;
			}
			_selectTypeBox.setValue(_description.type, SelectBoxValue.wrapToList(typeValues, FormsUtils.getTableColumnDescriptionTypesNames(typeValues)));
			
			_checkBoxLock = new CheckBox(18);
			_checkBoxLock.x = rightColumnX;
			_checkBoxLock.y = tfLock.y;
			_checkBoxLock.checked = _description.lock;
			_checkBoxLock.addEventListener(Event.CHANGE, onChange);
			addChild(_checkBoxLock);
			
			_checkBoxMustBeNonEmpty = new CheckBox(18);
			_checkBoxMustBeNonEmpty.x = rightColumnX;
			_checkBoxMustBeNonEmpty.y = tfMustBeNonEmpty.y;
			_checkBoxMustBeNonEmpty.checked = _description.mustBeNonEmpty;
			_checkBoxMustBeNonEmpty.addEventListener(Event.CHANGE, onChange);
			addChild(_checkBoxMustBeNonEmpty);
			
			_tfInputTag = TextUtils.getInputText(Color.FONT, 16, INPUT_WIDTH);
			_tfInputTag.x = rightColumnX;
			_tfInputTag.y = tfTag.y;
			_tfInputTag.addEventListener(Event.CHANGE, onChange);
			_tfInputTag.text = _description.tag != null ? _description.tag : '';
			addChild(_tfInputTag);
			
			_tfInputDescription = TextUtils.getInputText(Color.FONT, 16, INPUT_WIDTH, true, -2);
			_tfInputDescription.height = 100;
			_tfInputDescription.x = rightColumnX;
			_tfInputDescription.y = tfDescription.y;
			_tfInputDescription.addEventListener(Event.CHANGE, onChange);
			_tfInputDescription.text = _description.description != null ? _description.description : '';
			addChild(_tfInputDescription);
			
			_tfInputDefaultValue = TextUtils.getInputText(Color.FONT, 16, INPUT_WIDTH);
			_tfInputDefaultValue.x = rightColumnX;
			_tfInputDefaultValue.y = tfDefaultValue.y;
			_tfInputDefaultValue.addEventListener(FocusEvent.FOCUS_IN, onChange);
			_tfInputDefaultValue.addEventListener(FocusEvent.FOCUS_OUT, onChange);
			_tfInputDefaultValue.text = _description.defaultValue != null ? _description.defaultValue : '';
			addChild(_tfInputDefaultValue);
			
			_selectCounterBox = new SelectItemBox(INPUT_WIDTH + 1, ROWS_HEIGHT - 3);
			_selectCounterBox.setTableItem(_description.idFrom, Main.instance.rootTable.cache.countersTable.meta.counterId);
			_selectCounterBox.x = rightColumnX;
			_selectCounterBox.addEventListener(Event.CHANGE, onChange);
			_boxSelectCounter.addChild(_selectCounterBox);
			
			_checkBoxUseAsName = new CheckBox(18);
			_checkBoxUseAsName.x = rightColumnX;
			_checkBoxUseAsName.checked = _description.useAsName;
			_checkBoxUseAsName.addEventListener(Event.CHANGE, onChange);
			_boxUseAsName.addChild(_checkBoxUseAsName);
			
			_tfInputTextPattern = TextUtils.getInputText(Color.FONT, 16, INPUT_WIDTH);
			_tfInputTextPattern.x = rightColumnX;
			_tfInputTextPattern.addEventListener(Event.CHANGE, onChange);
			_tfInputTextPattern.text = _description.textPattern != null ? _description.textPattern : '';
			_boxTextPattern.addChild(_tfInputTextPattern);
			
			_tfFilePath = TextUtils.getInputText(Color.FONT, 16, INPUT_WIDTH);
			_tfFilePath.restrict = "0-9a-zA-Z._\\-/";
			_tfFilePath.height = _tfFilePath.textHeight + 4;
			_tfFilePath.x = rightColumnX;
			_tfFilePath.addEventListener(Event.CHANGE, onChange);
			_tfFilePath.text = _description.filePath != null ? _description.filePath : '';
			_boxFilePath.addChild(_tfFilePath);
			
			_tfFileExtension = TextUtils.getInputText(Color.FONT, 16, INPUT_WIDTH);
			_tfFileExtension.restrict = "0-9a-zA-Z";
			_tfFileExtension.maxChars = 6;
			_tfFileExtension.height = _tfFileExtension.textHeight + 4;
			_tfFileExtension.x = rightColumnX;
			_tfFileExtension.y = ROWS_HEIGHT;
			_tfFileExtension.addEventListener(Event.CHANGE, onChange);
			_tfFileExtension.text = _description.fileExtension != null ? _description.fileExtension : '';
			_boxFilePath.addChild(_tfFileExtension);
			
			var hWDelimer:int = 20;
			_tfFileImageSizeWidth = TextUtils.getInputText(Color.FONT, 16, (INPUT_WIDTH - hWDelimer) / 2);
			_tfFileImageSizeWidth.restrict = "0-9";
			_tfFileImageSizeWidth.maxChars = 4;
			_tfFileImageSizeWidth.height = _tfFileImageSizeWidth.textHeight + 4;
			_tfFileImageSizeWidth.x = rightColumnX;
			_tfFileImageSizeWidth.y = ROWS_HEIGHT * 2;
			_tfFileImageSizeWidth.addEventListener(Event.CHANGE, onChange);
			_tfFileImageSizeWidth.text = _description.fileImageSize != null && _description.fileImageSize.length > 0 ? _description.fileImageSize[0].toString() : '0';
			_boxFilePath.addChild(_tfFileImageSizeWidth);
			
			_tfFileImageSizeHeight = TextUtils.getInputText(Color.FONT, 16, (INPUT_WIDTH - hWDelimer) / 2);
			_tfFileImageSizeHeight.restrict = "0-9";
			_tfFileImageSizeHeight.maxChars = 4;
			_tfFileImageSizeHeight.height = _tfFileImageSizeHeight.textHeight + 4;
			_tfFileImageSizeHeight.x = _tfFileImageSizeWidth.x + _tfFileImageSizeWidth.width + hWDelimer;
			_tfFileImageSizeHeight.y = ROWS_HEIGHT * 2;
			_tfFileImageSizeHeight.addEventListener(Event.CHANGE, onChange);
			_tfFileImageSizeHeight.text = _description.fileImageSize != null && _description.fileImageSize.length > 1 ? _description.fileImageSize[1].toString() : '0';
			_boxFilePath.addChild(_tfFileImageSizeHeight);
			
			_selectMetaBox = new SelectValueBox(INPUT_WIDTH + 1, ROWS_HEIGHT - 3);
			_selectMetaBox.x = rightColumnX;
			_selectMetaBox.y = tfSelectMeta.y;
			_selectMetaBox.addEventListener(Event.CHANGE, onChange);
			_boxSelectMeta.addChild(_selectMetaBox);
			var listInnerTableMeta:Vector.<TableMeta> = Main.instance.rootTable.cache.listInnerTableMeta;
			var listItems:Vector.<SelectBoxValue> = new Vector.<SelectBoxValue>();
			for each (var meta:TableMeta in listInnerTableMeta)
			{
				listItems.push(new SelectBoxValue(meta.id, meta.id + '.' + meta.name, false));
			}
			_selectMetaBox.setValue(_description.metaId, listItems);
			
			_boxButtons = new HBox();
			
			_btnOk = new LabeledButton(table == null ? Texts.btnCreate : Texts.btnApply);
			_btnOk.addEventListener(MouseEvent.CLICK, onBtnOkClick);
			_boxButtons.addChild(_btnOk);
			
			_btnCancel = new LabeledButton(Texts.btnCancel);
			_btnCancel.addEventListener(MouseEvent.CLICK, onBtnCancelClick);
			_boxButtons.addChild(_btnCancel);
			
			_boxButtons.resize();
			_boxButtons.x = int((width - _boxButtons.width) / 2);
			_boxButtons.y = _boxFilePath.y + _boxFilePath.height + 20;
			addChild(_boxButtons);
			
			onChange(null);
			
			Main.instance.commandsHistory.addEventListener(Event.CHANGE, onChange);
		}
		
		public function get description():TableColumnDescription
		{
			return _description;
		}
		
		private function onTypeChange(e:Event):void
		{
			_tfInputDefaultValue.text = TableColumnDescription.getDefaultValue(int(_selectTypeBox.value));
			onChange(e);
		}
		
		private function onChange(e:Event):void
		{
			_description.name = _tfInputName.text;
			_description.type = uint(_selectTypeBox.value);
			_description.lock = _checkBoxLock.checked;
			_description.mustBeNonEmpty = _checkBoxMustBeNonEmpty.checked;
			_description.tag = _tfInputTag.text;
			_description.description = _tfInputDescription.text;
			_description.metaId = uint(_selectMetaBox.value);
			
			_description.defaultValue = ViewUtils.parseColumnDefaultValue(_description, _tfInputDefaultValue.text);
			
			if (_description.type == TableColumnDescriptionType.INNER_TABLE)
			{
				var dataTable:DataTable = Main.instance.rootTable.cache.getTableById(_description.metaId) as DataTable;
				if (dataTable != null)
				{
					_tfInputDefaultValue.text = ParseUtils.writeInnerTable(ParseUtils.readInnerTable(_tfInputDefaultValue.text, dataTable.meta.columns), dataTable.meta.columns);
				}
				else
				{
					_tfInputDefaultValue.text = '';
				}
				
				_description.defaultValue = _tfInputDefaultValue.text;
			}
			else
			{
				_tfInputDefaultValue.text = ParseUtils.writeValue(ParseUtils.readValue(_tfInputDefaultValue.text, _description.type), _description.type);
				_description.defaultValue = _tfInputDefaultValue.text;
			}
			
			_description.idFrom = int(_selectCounterBox.value);
			_description.useAsName = _checkBoxUseAsName.checked;
			_description.textPattern = _tfInputTextPattern.text;
			_description.filePath = _tfFilePath.text;
			_description.fileExtension = _tfFileExtension.text;
			_description.fileImageSize = Vector.<uint>([uint(_tfFileImageSizeWidth.text), uint(_tfFileImageSizeHeight.text)]);
			
			_boxSelectCounter.visible = _description.type == TableColumnDescriptionType.SELECT_SINGLE_ID;
			_boxUseAsName.visible = _description.type == TableColumnDescriptionType.STRING_VALUE || _description.type == TableColumnDescriptionType.TEXT_PATTERN;
			_boxTextPattern.visible = _description.type == TableColumnDescriptionType.TEXT_PATTERN;
			_boxFilePath.visible = _description.type == TableColumnDescriptionType.FILE_PATH;
			_boxSelectMeta.visible = _description.type == TableColumnDescriptionType.INNER_TABLE;
			
			var isValuable:Boolean = TableColumnDescriptionType.isValuable(_description.type);
			_checkBoxMustBeNonEmpty.enabled = isValuable;
			if (!isValuable)
			{
				_checkBoxMustBeNonEmpty.checked = false;
				_description.mustBeNonEmpty = false;
			}
			
			_selectCounterBox.setTableItem(_description.idFrom, Main.instance.rootTable.cache.countersTable.meta.counterId);
			
			_btnOk.enabled = true;
			if (_description.type == TableColumnDescriptionType.INNER_TABLE)
			{
				_btnOk.enabled = Main.instance.rootTable.cache.getTableById(_description.metaId) != null;
			}
		}
		
		private function onBtnOkClick(e:Event):void
		{
			_parentForm.close();
			
			if (_description.type != TableColumnDescriptionType.SELECT_SINGLE_ID)
			{
				_description.idFrom = 0;
			}
			if (_description.type != TableColumnDescriptionType.STRING_VALUE && _description.type != TableColumnDescriptionType.TEXT_PATTERN)
			{
				_description.useAsName = false;
			}
			if (_description.type != TableColumnDescriptionType.TEXT_PATTERN)
			{
				_description.textPattern = null;
			}
			if (_description.type != TableColumnDescriptionType.FILE_PATH)
			{
				_description.filePath = null;
			}
			if (_description.type != TableColumnDescriptionType.INNER_TABLE)
			{
				_description.metaId = 0;
			}
			
			if (_srcDescription == null || _srcDescription.type != _description.type)
			{
				_description.updateDefaultWidth();
			}
			
			if (_srcDescription == null)
			{
				Main.instance.commandsHistory.addCommandAndExecute(new AddColumnCommand(_table, _description));
			}
			else
			{
				Main.instance.commandsHistory.addCommandAndExecute(new EditColumnCommand(_table, _description, _srcDescription));
			}
		}
		
		private function onBtnCancelClick(e:Event):void
		{
			_parentForm.close();
		}
		
		override public function get height():Number 
		{
			return _boxButtons.y + _boxButtons.height + 1;
		}
		
		public function dispose():void
		{
			Main.instance.commandsHistory.removeEventListener(Event.CHANGE, onChange);
		}
	}
}