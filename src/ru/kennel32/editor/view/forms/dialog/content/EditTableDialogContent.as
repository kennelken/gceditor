package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableType;
	import ru.kennel32.editor.data.commands.CreateTableCommand;
	import ru.kennel32.editor.data.commands.EditTableCommand;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.view.components.controls.CheckBox;
	import ru.kennel32.editor.view.components.HBox;
	import ru.kennel32.editor.view.components.buttons.LabeledButton;
	import ru.kennel32.editor.view.components.selectbox.SelectItemBox;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.interfaces.IAllowCommandsHistoryChange;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class EditTableDialogContent extends BaseDialogContent implements IAllowCommandsHistoryChange, IDisposable
	{
		private static const ROWS_HEIGHT:int = 23;
		private static const TF_WIDTH:int = 250;
		
		private var _table:BaseTable;
		private var _parentTable:ContainerTable;
		
		private var _meta:TableMeta;
		
		private var _tfInputName:TextField;
		private var _checkBoxForInnerTable:CheckBox;
		private var _checkBoxContainer:CheckBox;
		private var _checkBoxCounter:CheckBox;
		private var _selectCounterBox:SelectItemBox;
		private var _tfInputTag:TextField;
		private var _tfInputDescription:TextField;
		
		private var _boxButtons:HBox;
		private var _btnOk:LabeledButton;
		private var _btnCancel:LabeledButton;
		
		public function EditTableDialogContent(table:BaseTable, parentTable:ContainerTable)
		{
			super();
			
			_table = table;
			_parentTable = parentTable;
			
			if (table != null)
			{
				_meta = new TableMeta();
				_meta.copyFrom(table.meta);
			}
			else
			{
				var tablesCounter:Counter = Main.instance.rootTable.cache.getCounterById(Counter.TABLES);
				_meta = TableMeta.create(tablesCounter.getNextIndex(1), 0, '', 0);
				_meta.counterId = _parentTable.meta.counterId;
				_meta.name = "newTableName";
				_meta.tag = "newTableTag";
				_meta.description = "New table\ndescription";
			}
			
			var rightColumnX:int = 0;
			
			var tfName:TextField = TextUtils.getText(Texts.textName, Color.FONT, 16);
			tfName.height = tfName.textHeight + 4;
			addChild(tfName);
			rightColumnX = Math.max(rightColumnX, tfName.width);
			
			var tfForInnerTable:TextField = TextUtils.getText(Texts.textForInnerTable, Color.FONT, 16);
			tfForInnerTable.height = tfForInnerTable.textHeight + 4;
			tfForInnerTable.y = tfName.y + ROWS_HEIGHT;
			addChild(tfForInnerTable);
			rightColumnX = Math.max(rightColumnX, tfForInnerTable.width);
			
			var tfContainer:TextField = TextUtils.getText(Texts.textContainer, Color.FONT, 16);
			tfContainer.height = tfContainer.textHeight + 4;
			tfContainer.y = tfForInnerTable.y + ROWS_HEIGHT;
			addChild(tfContainer);
			rightColumnX = Math.max(rightColumnX, tfContainer.width);
			
			var tfCounter:TextField = TextUtils.getText(Texts.textCounter, Color.FONT, 16);
			tfCounter.height = tfCounter.textHeight + 4;
			tfCounter.y = tfContainer.y + ROWS_HEIGHT;
			addChild(tfCounter);
			rightColumnX = Math.max(rightColumnX, tfCounter.width);
			
			var tfTag:TextField = TextUtils.getText(Texts.textTag, Color.FONT, 16);
			tfTag.height = tfTag.textHeight + 4;
			tfTag.y = tfCounter.y + ROWS_HEIGHT;
			addChild(tfTag);
			rightColumnX = Math.max(rightColumnX, tfTag.width);
			
			var tfDescription:TextField = TextUtils.getText(Texts.textDescription, Color.FONT, 16);
			tfDescription.height = tfDescription.textHeight + 4;
			tfDescription.y = tfTag.y + ROWS_HEIGHT;
			addChild(tfDescription);
			rightColumnX = Math.max(rightColumnX, tfDescription.width);
			
			rightColumnX += 50;
			
			_tfInputName = TextUtils.getInputText(Color.FONT, 16, TF_WIDTH);
			_tfInputName.x = rightColumnX;
			_tfInputName.y = tfName.y;
			_tfInputName.addEventListener(Event.CHANGE, onChange);
			_tfInputName.text = _meta.name != null ? _meta.name : '';
			addChild(_tfInputName);
			
			_checkBoxForInnerTable = new CheckBox(18);
			_checkBoxForInnerTable.x = rightColumnX;
			_checkBoxForInnerTable.y = tfForInnerTable.y;
			_checkBoxForInnerTable.checked = _meta.forInnerTable;
			_checkBoxForInnerTable.addEventListener(Event.CHANGE, onChange);
			_checkBoxForInnerTable.enabled = _table == null && _parentTable.meta.counterId <= 0;
			addChild(_checkBoxForInnerTable);
			
			_checkBoxContainer = new CheckBox(18);
			_checkBoxContainer.x = rightColumnX;
			_checkBoxContainer.y = tfContainer.y;
			_checkBoxContainer.checked = _meta.type == TableType.CONTAINER;
			_checkBoxContainer.addEventListener(Event.CHANGE, onChange);
			_checkBoxContainer.enabled = !_meta.lock && _table == null;
			addChild(_checkBoxContainer);
			
			var dataTable:DataTable = _table as DataTable;
			var containerTable:ContainerTable = _table as ContainerTable;
			
			var canChangeCounter:Boolean = !_meta.lock &&
				_parentTable.meta.counterId <= 0 &&
				((dataTable == null && containerTable == null) || (dataTable != null && dataTable.rows.length <= 0) || (containerTable != null && containerTable.children.length <= 0));
			
			_checkBoxCounter = new CheckBox(18);
			_checkBoxCounter.x = rightColumnX;
			_checkBoxCounter.y = tfCounter.y;
			_checkBoxCounter.checked = _meta.counterId > 0;
			_checkBoxCounter.addEventListener(Event.CHANGE, onChange);
			_checkBoxCounter.enabled = canChangeCounter;
			addChild(_checkBoxCounter);
			
			_selectCounterBox = new SelectItemBox(TF_WIDTH - 24);
			_selectCounterBox.x = _checkBoxCounter.x + _checkBoxCounter.width + 3;
			_selectCounterBox.y = tfCounter.y - 1;
			_selectCounterBox.setTableItem(_meta.counterId, Main.instance.rootTable.cache.countersTable.meta.counterId);
			_selectCounterBox.addEventListener(Event.CHANGE, onChange);
			_selectCounterBox.enabled = canChangeCounter;
			addChild(_selectCounterBox);
			
			_tfInputTag = TextUtils.getInputText(Color.FONT, 16, TF_WIDTH);
			_tfInputTag.x = rightColumnX;
			_tfInputTag.y = tfTag.y;
			_tfInputTag.addEventListener(Event.CHANGE, onChange);
			_tfInputTag.text = _meta.tag != null ? _meta.tag : '';
			addChild(_tfInputTag);
			
			_tfInputDescription = TextUtils.getInputText(Color.FONT, 16, TF_WIDTH, true, -2);
			_tfInputDescription.height = 100;
			_tfInputDescription.x = rightColumnX;
			_tfInputDescription.y = tfDescription.y;
			_tfInputDescription.addEventListener(Event.CHANGE, onChange);
			_tfInputDescription.text = _meta.description != null ? _meta.description : '';
			addChild(_tfInputDescription);
			
			_boxButtons = new HBox();
			
			_btnOk = new LabeledButton(table == null ? Texts.btnCreate : Texts.btnApply);
			_btnOk.addEventListener(MouseEvent.CLICK, onBtnOkClick);
			_boxButtons.addChild(_btnOk);
			
			_btnCancel = new LabeledButton(Texts.btnCancel);
			_btnCancel.addEventListener(MouseEvent.CLICK, onBtnCancelClick);
			_boxButtons.addChild(_btnCancel);
			
			_boxButtons.resize();
			_boxButtons.x = int((width - _boxButtons.width) / 2);
			_boxButtons.y = _tfInputDescription.y + _tfInputDescription.height + 20;
			addChild(_boxButtons);
			
			onChange(null);
			
			Main.instance.commandsHistory.addEventListener(Event.CHANGE, onChange);
		}
		
		public function get meta():TableMeta
		{
			return _meta;
		}
		
		private function onChange(e:Event):void
		{
			if (!_checkBoxContainer.checked)
			{
				_checkBoxCounter.checked = true;
			}
			
			_meta.name = _tfInputName.text;
			_meta.type = _checkBoxContainer.checked ? TableType.CONTAINER : TableType.BASIC;
			_meta.forInnerTable = _checkBoxForInnerTable.checked;
			_meta.counterId = _checkBoxCounter.checked ? int(_selectCounterBox.value) : 0;
			_meta.tag = _tfInputTag.text;
			_meta.description = _tfInputDescription.text;
			
			var counter:Counter = _meta.counterId > 0 ? Main.instance.rootTable.cache.getCounterById(_meta.counterId) : null;
			
			_btnOk.enabled = Hardcode.isSystemMeta(_meta) ||
				(_meta.type == TableType.CONTAINER || _meta.counterId > 0) &&
				(_meta.counterId <= 0 || (counter != null && !counter.isSystem)) &&
				(!_meta.forInnerTable || _meta.type == TableType.BASIC && _parentTable.meta.counterId <= 0);
			
			_selectCounterBox.setTableItem(_meta.counterId, Main.instance.rootTable.cache.countersTable.meta.counterId);
		}
		
		private function onBtnOkClick(e:Event):void
		{
			_parentForm.close();
			
			if (_table == null)
			{
				var isContainer:Boolean = meta.type == TableType.CONTAINER;
				
				var newTable:BaseTable = isContainer ? new ContainerTable(_meta) : new DataTable(_meta);
				newTable.index = _parentTable.children.length;
				
				if (_parentTable.meta.counterId > 0)
				{
					_meta.updateParentColumnsForNewTable(_parentTable.meta);
				}
				else if ((!isContainer || _meta.counterId > 0))
				{
					var column:TableColumnDescription;
					
					column = TableColumnDescription.create(TableColumnDescriptionType.ID, "id", true, 0, false);
					column.name = "id";
					column.description = "id";
					_meta.addColumn(column, 0, true);
					
					column = TableColumnDescription.create(TableColumnDescriptionType.STRING_VALUE, "name", false, 0, false);
					column.name = "name";
					column.description = "name";
					column.useAsName = true;
					_meta.addColumn(column, 1, true);
				}
				
				Main.instance.commandsHistory.addCommandAndExecute(new CreateTableCommand(_parentTable, newTable));
			}
			else
			{
				Main.instance.commandsHistory.addCommandAndExecute(new EditTableCommand(_table, _meta));
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