package ru.kennel32.editor.view.hud.table.cells
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.ChangeFloatValueCommand;
	import ru.kennel32.editor.data.commands.ChangeIntValueCommand;
	import ru.kennel32.editor.data.commands.ChangeStringValueCommand;
	import ru.kennel32.editor.data.commands.InspectRowCommand;
	import ru.kennel32.editor.data.utils.ParseUtils;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.dialog.content.InspectRowDialogContent;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class TextInputTableRowCellView extends BaseTableRowCellView
	{
		private var _tf:TextField;
		private var _oldText:String;
		private var _isInnerTableCell:Boolean;
		
		public function TextInputTableRowCellView()
		{
			super();
			
			_tf = TextUtils.getText('', Color.FONT, 16);
			_tf.selectable = true;
			_tf.autoSize = TextFieldAutoSize.NONE;
			_tf.height = DEFAULT_TF_HEIGHT;
			
			_tf.backgroundColor = Color.INPUT_TEXT_BACKGROUND;
			
			addChild(_tf);
			
			_type = TableColumnDescriptionType.STRING_VALUE;
			
			addEventListener(MouseEvent.CLICK, onMouseClick, false, int.MAX_VALUE);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_tf.x = 3;
			_tf.y = (_height - _tf.height) / 2 - 1;
			_tf.width = _width - _tf.x * 2 - 1;
		}
		
		public function get isInnerTableCell():Boolean
		{
			return _isInnerTableCell;
		}
		public function set isInnerTableCell(value:Boolean):void
		{
			_isInnerTableCell = value;
		}
		
		private function onFocusIn(e:Event):void
		{
			if (_tf.type != TextFieldType.INPUT)
			{
				return;
			}
			
			_oldText = _tf.text;
		}
		
		private function onFocusOut(e:Event):void
		{
			if (_tf.type != TextFieldType.INPUT)
			{
				return;
			}
			
			if (_isInnerTableCell)
			{
				var text:String = _tf.text;
				while (text.length != (text = text.replace(';', '')).length) {}
				while (text.length != (text = text.replace(',', '')).length) {}
				_tf.text = text;
			}
			
			if (_oldText == _tf.text)
			{
				return;
			}
			
			var oldText:String = _oldText;
			_oldText = _tf.text;
			
			switch(_columnData.type)
			{
				case TableColumnDescriptionType.INT_VALUE:
					if (!dispatchChangeInnerTableValue(int(_tf.text)))
					{
						Main.instance.commandsHistory.addCommandAndExecute(new ChangeIntValueCommand(_tableRow, _columnIndex, int(oldText), int(_tf.text)));
					}
					break;
				
				case TableColumnDescriptionType.FLOAT_VALUE:
					if (!dispatchChangeInnerTableValue(ParseUtils.readFloat(_tf.text)))
					{
						Main.instance.commandsHistory.addCommandAndExecute(new ChangeFloatValueCommand(_tableRow, _columnIndex, ParseUtils.readFloat(oldText), ParseUtils.readFloat(_tf.text)));
					}
					break;
					
				case TableColumnDescriptionType.STRING_VALUE:
					if (!dispatchChangeInnerTableValue(_tf.text))
					{
						Main.instance.commandsHistory.addCommandAndExecute(new ChangeStringValueCommand(_tableRow, _columnIndex, oldText, _tf.text));
					}
					break;
			}
		}
		
		override public function updateValue():void 
		{
			super.updateValue();
			
			_tf.text = _tableRow.data[_columnIndex];
			_oldText = _tf.text;
			
			var enabled:Boolean = !locked;
			_tf.background = enabled;
			_tf.type = enabled ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			
			switch (_columnData.type)
			{
				case TableColumnDescriptionType.INT_VALUE:
					_tf.restrict = '0-9\\-';
					_tf.maxChars = 10;
					break;
				
				case TableColumnDescriptionType.FLOAT_VALUE:
					_tf.restrict = '0-9.\\-';
					_tf.maxChars = 20;
					break;
					
				case TableColumnDescriptionType.STRING_VALUE:
					if (_isInnerTableCell)
					{
						_tf.restrict = "^;,";
					}
					else
					{
						_tf.restrict = null;
					}
					_tf.maxChars = 1000;
					break;
			}
			
			_tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			_tf.text = '';
			_oldText = null;
			
			_tf.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_tf.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
		
		override protected function doBeforeSave(e:Event):void 
		{
			super.doBeforeSave(e);
			
			ViewUtils.removeFocusFromDobj(this);
			
			if (_oldText != _tf.text)
			{
				onFocusOut(null);
			}
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (!ViewUtils.isForInspect(e))
			{
				return;
			}
			
			if (_tableRow.parent == Main.instance.rootTable.cache.localizationTable && _columnData.useAsName)
			{
				var row:TableRow = Main.instance.rootTable.cache.getDataRowByLocalizationKey(_tableRow.data[_columnIndex]);
				
				e.preventDefault();
				e.stopImmediatePropagation();
				
				if (row != null)
				{
					InspectRowDialogContent.showRow(row);
				}
			}
		}
	}
}