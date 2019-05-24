package ru.kennel32.editor.view.hud.table.cells
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.ChangeFloatValueCommand;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.settings.ProjectSettings;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class DateTableRowCellView extends BaseTableRowCellView
	{
		private var DIVIDER_PARTS:String = ' ';
		private var DIVIDER_DATE:String = '.';
		private var DIVIDER_TIME:String = ':';
		
		private var ALL_DIVIDERS:Vector.<String> = Vector.<String>([DIVIDER_PARTS, DIVIDER_DATE, DIVIDER_TIME]);
		
		private var _tf:TextField;
		private var _oldText:String;
		private var _oldSelectionBeginIndex:int;
		private var _oldSelectionEndIndex:int;
		private var _oldValue:Number;
		
		public function DateTableRowCellView()
		{
			super();
			
			_tf = TextUtils.getText('', Color.FONT, 16);
			_tf.restrict = "0-9.: ";
			_tf.selectable = true;
			_tf.autoSize = TextFieldAutoSize.NONE;
			_tf.height = DEFAULT_TF_HEIGHT;
			
			_tf.backgroundColor = Color.INPUT_TEXT_BACKGROUND;
			
			addChild(_tf);
			
			_tf.text = getDateStringByTs(0);
			
			_type = TableColumnDescriptionType.DATE;
		}
		
		override public function init(rowData:TableRow, columnIndex:int):void 
		{
			super.init(rowData, columnIndex);
			
			_tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_tf.addEventListener(Event.CHANGE, onChange);
			_tf.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			_tf.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_tf.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			Settings.addEventListener(SettingsEvent.TIMEZONE_CHANGED, onTimezoneChanged);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_tf.x = 3;
			_tf.y = (_height - _tf.height) / 2 - 1;
			_tf.width = _width - _tf.x * 2 - 1;
		}
		
		private function onTextInput(e:TextEvent):void
		{
			if (_tf.text.substring(_tf.selectionBeginIndex, _tf.selectionEndIndex) == e.text)
			{
				e.preventDefault();
				moveCaretIfRequired(1);
			}
		}
		
		private function onChange(e:Event):void
		{
			if (!fixValues() && restoreOldText())
			{
				return;
			}
			
			moveCaretIfRequired();
			
			_oldText = _tf.text;
		}
		
		private function restoreOldText():Boolean
		{
			_tf.text = _oldText;
			_tf.setSelection(_oldSelectionBeginIndex, _oldSelectionEndIndex);
			
			return true;
		}
		
		private function onMouseDown(e:Event):void
		{
			Main.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseUp(e:Event):void
		{
			moveCaretIfRequired();
			_oldSelectionBeginIndex = _tf.selectionBeginIndex;
			_oldSelectionEndIndex = _tf.selectionEndIndex;
			
			Main.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			var up:Boolean = e.keyCode == Keyboard.UP || e.keyCode == Keyboard.NUMPAD_8;
			var down:Boolean = e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.NUMPAD_2;
			
			if (up || down)
			{
				e.preventDefault();
				
				return;
			}
			
			var left:Boolean = e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.NUMPAD_4;
			var right:Boolean = e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.NUMPAD_6;
			
			if (left || right)
			{
				e.preventDefault();
				
				moveCaretIfRequired(left ? -1 : 1);
				
				return;
			}
			
			var backspace:Boolean = e.keyCode == Keyboard.BACKSPACE;
			var del:Boolean = e.keyCode == Keyboard.DELETE;
			
			if (backspace || del)
			{
				_tf.replaceSelectedText('0');
				
				if (!fixValues() && restoreOldText())
				{
					return;
				}
				
				if (backspace)
				{
					moveCaretIfRequired(-2);
				}
				else
				{
					moveCaretIfRequired(-1);
				}
				
				e.preventDefault();
			}
		}
		
		private function onFocusIn(e:Event):void
		{
			if (_tf.type != TextFieldType.INPUT)
			{
				return;
			}
			
			_oldValue = getTsByDateString(_tf.text);
			_oldText = _tf.text;
		}
		
		private function onFocusOut(e:Event):void
		{
			if (_tf.type != TextFieldType.INPUT)
			{
				return;
			}
			
			var newValue:Number = getTsByDateString(_tf.text);
			_tf.text = getDateStringByTs(newValue);
			
			if (_oldValue == newValue)
			{
				return;
			}
			
			if (!dispatchChangeInnerTableValue(newValue))
			{
				Main.instance.commandsHistory.addCommandAndExecute(new ChangeFloatValueCommand(_tableRow, _columnIndex, _oldValue, newValue));
			}
			
			_oldValue = newValue;
		}
		
		override public function updateValue():void 
		{
			super.updateValue();
			
			_oldValue = _tableRow.data[_columnIndex];
			_tf.text = getDateStringByTs(_oldValue);
			
			var enabled:Boolean = !locked;
			_tf.background = enabled;
			_tf.type = enabled ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			Settings.removeEventListener(SettingsEvent.TIMEZONE_CHANGED, onTimezoneChanged);
			Main.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onTimezoneChanged(e:Event):void
		{
			updateValue();
		}
		
		private function getDateStringByTs(ts:Number):String
		{
			var date:Date = new Date(ts * 1000);
			
			var targetTimeZone:Number = ProjectSettings.timezone;
			var currentTimeZone:Number = -date.getTimezoneOffset() / 60;
			var hoursDiff:Number = targetTimeZone - currentTimeZone;
			
			var dateZero:Date = new Date(0);
			date = new Date((ts + hoursDiff * 60 * 60) * 1000);
			
			return TextUtils.prefixToLength(date.fullYear.toString(), 4, '0').substr(0, 4) + DIVIDER_DATE +
				TextUtils.prefixToLength((date.month + 1).toString(), 2, '0').substr(0, 2) + DIVIDER_DATE +
				TextUtils.prefixToLength(date.date.toString(), 2, '0').substr(0, 2) + DIVIDER_PARTS +
				TextUtils.prefixToLength(date.hours.toString(), 2, '0').substr(0, 2) + DIVIDER_TIME +
				TextUtils.prefixToLength(date.minutes.toString(), 2, '0').substr(0, 2) + DIVIDER_TIME +
				TextUtils.prefixToLength(date.seconds.toString(), 2, '0').substr(0, 2);
		}
		
		private function getTsByDateString(text:String):Number
		{
			if (text.length != 19 ||
				text.charAt(4) != DIVIDER_DATE ||
				text.charAt(7) != DIVIDER_DATE ||
				text.charAt(10) != DIVIDER_PARTS ||
				text.charAt(13) != DIVIDER_TIME ||
				text.charAt(16) != DIVIDER_TIME)
			{
				throw new Error('incorrect date format');
			}
			
			var year:int = int(text.substr(0, 4));
			var month:int = int(text.substr(5, 2));
			var day:int = Math.min(getNumDaysInMonth(year, month - 1), int(text.substr(8, 2)));
			var hours:int = int(text.substr(11, 2));
			var minutes:int = int(text.substr(14, 2));
			var seconds:int = int(text.substr(17, 2));
			
			var date:Date = new Date(year, month - 1, day, hours, minutes, seconds);
			
			var targetTimeZone:Number = ProjectSettings.timezone;
			var currentTimeZone:Number = -date.getTimezoneOffset() / 60;
			var hoursDiff:Number = targetTimeZone - currentTimeZone;
			
			return Math.max(0, (date.time - (hoursDiff * 60 * 60) * 1000) / 1000);
		}
		
		private function fixValues():Boolean
		{
			var text:String = _tf.text;
			var splitParts:Array = text.split(DIVIDER_PARTS);
			if (splitParts.length != 2)
			{
				return false;
			}
			
			var splitDate:Array = splitParts[0].split(DIVIDER_DATE);
			if (splitDate.length != 3)
			{
				return false;
			}
			
			var splitTime:Array = splitParts[1].split(DIVIDER_TIME);
			if (splitTime.length != 3)
			{
				return false;
			}
			
			splitDate[0] = TextUtils.postfixToLength(splitDate[0], 4, '0');
			splitDate[1] = TextUtils.postfixToLength(splitDate[1], 2, '0');
			splitDate[2] = TextUtils.postfixToLength(splitDate[2], 2, '0');
			
			splitTime[0] = TextUtils.postfixToLength(splitTime[0], 2, '0');
			splitTime[1] = TextUtils.postfixToLength(splitTime[1], 2, '0');
			splitTime[2] = TextUtils.postfixToLength(splitTime[2], 2, '0');
			
			if (int(splitDate[0]) < 1970)
			{
				splitDate[0] = '1970';
			}
			if (int(splitDate[0]) > 9999)
			{
				splitDate[0] = '9999';
			}
			
			if (int(splitDate[1]) < 1)
			{
				splitDate[1] = '01';
			}
			if (int(splitDate[1]) > 12)
			{
				splitDate[1] = '12';
			}
			
			if (int(splitDate[2] < 1))
			{
				splitDate[2] = '01';
			}
			if (int(splitDate[2] > 31))
			{
				splitDate[2] = '31';
			}
			
			if (int(splitTime[0] < 0))
			{
				splitTime[0] = '00';
			}
			if (int(splitTime[0] > 23))
			{
				splitTime[0] = '23';
			}
			
			if (int(splitTime[1] < 0))
			{
				splitTime[1] = '00';
			}
			if (int(splitTime[1] > 59))
			{
				splitTime[1] = '59';
			}
			
			if (int(splitTime[2] < 0))
			{
				splitTime[2] = '00';
			}
			if (int(splitTime[2] > 59))
			{
				splitTime[2] = '59';
			}
			
			_tf.text = splitDate[0] + DIVIDER_DATE + splitDate[1] + DIVIDER_DATE + splitDate[2] + DIVIDER_PARTS + splitTime[0] + DIVIDER_TIME + splitTime[1] + DIVIDER_TIME + splitTime[2];
			
			return true;
		}
		
		private function moveCaretIfRequired(offset:int = 0):void
		{
			var sbi:int = Math.max(0, _tf.selectionBeginIndex + offset);
			var sei:int = Math.max(0, offset == 0 ? _tf.selectionEndIndex : sbi);
			
			if (sei - sbi > 0)
			{
				_oldSelectionBeginIndex = _tf.selectionBeginIndex;
				_oldSelectionEndIndex = _tf.selectionEndIndex;
				return;
			}
			
			if (ALL_DIVIDERS.indexOf(_tf.text.charAt(sbi)) > -1)
			{
				sbi = sbi + (offset < 0 ? -1 : 1)
			}
			
			sbi = Math.max(0, Math.min(_tf.text.length - 1, sbi));
			
			_tf.setSelection(sbi, sbi + 1);
			
			_oldSelectionBeginIndex = _tf.selectionBeginIndex;
			_oldSelectionEndIndex = _tf.selectionEndIndex;
		}
		
		private function getNumDaysInMonth(year:int, month:int):int
		{
			return new Date(year, month + 1, 0).date;
		}
		
		override protected function doBeforeSave(e:Event):void 
		{
			super.doBeforeSave(e);
			
			var newValue:Number = getTsByDateString(_tf.text);
			
			if (_oldValue != newValue)
			{
				_oldValue = newValue;
				onFocusOut(null);
			}
		}
	}
}