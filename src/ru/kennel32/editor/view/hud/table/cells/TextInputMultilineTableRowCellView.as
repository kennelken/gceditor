package ru.kennel32.editor.view.hud.table.cells
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.commands.ChangeFloatValueCommand;
	import ru.kennel32.editor.data.commands.ChangeIntValueCommand;
	import ru.kennel32.editor.data.commands.ChangeStringValueCommand;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class TextInputMultilineTableRowCellView extends BaseTableRowCellView
	{
		private static const VERTICAL_HEIGHT:int = 192;
		
		private var _tf:TextField;
		private var _oldText:String;
		private var _currentNumLines:int;
		private var _canvas:ScrollableCanvas;
		
		public function TextInputMultilineTableRowCellView()
		{
			super();
			
			_canvas = new ScrollableCanvas();
			_canvas.x = 2;
			_canvas.y = 2;
			addChild(_canvas);
			
			_tf = TextUtils.getText('', Color.FONT, 16, null, true, -3);
			_tf.selectable = true;
			_tf.autoSize = TextFieldAutoSize.NONE;
			_tf.height = DEFAULT_TF_HEIGHT;
			
			_tf.backgroundColor = Color.INPUT_TEXT_BACKGROUND;
			
			_canvas.setContent(_tf);
			
			_type = TableColumnDescriptionType.STRING_MULTILINE;
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_canvas.setSize(_width - _canvas.x * 2, _height - _canvas.y * 2);
			
			_tf.width = _canvas.width - 12;
			updateHeight(true);
			_canvas.updateControls(false);
		}
		
		private function onFocusIn(e:Event):void
		{
			if (_tf.type != TextFieldType.INPUT)
			{
				return;
			}
			
			_currentNumLines = _tf.numLines;
			_oldText = _tf.text;
		}
		
		private function onFocusOut(e:Event):void
		{
			if (_tf.type != TextFieldType.INPUT)
			{
				return;
			}
			
			if (_oldText == _tf.text)
			{
				return;
			}
			
			var oldText:String = _oldText;
			_oldText = _tf.text;
			
			updateHeight();
			Main.instance.commandsHistory.addCommandAndExecute(new ChangeStringValueCommand(_tableRow, _columnIndex, oldText, _tf.text));
		}
		
		private function onTextChanged(e:Event):void
		{
			if (_tf.numLines != _currentNumLines)
			{
				updateHeight(false);
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			//2017.11.16 runtime does not fire text changed event for last deleted new line symbol
			if ((e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.BACKSPACE) && _tf.selectionEndIndex == _tf.text.length)
			{
				updateHeight(false);
			}
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			onEnterFrame();
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (ViewUtils.isSpecialKey(e))
			{
				return;
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			onEnterFrame();
		}
		
		private function onEnterFrame(e:Event = null):void
		{
			var end:Rectangle = _tf.getCharBoundaries(_tf.selectionEndIndex - 1);
			if (end == null)
			{
				var lineIndex:int = _tf.getLineIndexOfChar(_tf.selectionEndIndex - 1);
				end = new Rectangle(0, lineIndex * (_tf.defaultTextFormat.size + 6 + _tf.defaultTextFormat.leading), 30, 30);
			}
			if (end != null)
			{
				var visibleRect:Rectangle = new Rectangle(-_tf.x, -_tf.y, _canvas.width, _canvas.height);
				if (!visibleRect.containsRect(end))
				{
					_tf.x = -end.x;
					_tf.y = -end.y;
					_canvas.updateControls(false);
				}
			}
		}
		
		override public function updateValue():void 
		{
			super.updateValue();
			
			var text:String = _tableRow.data[_columnIndex];
			_tf.text = text != null ? text : '';
			
			var enabled:Boolean = !locked;
			_tf.background = enabled;
			_tf.type = enabled ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			
			updateHeight();
			
			_oldText = _tf.text;
			
			_canvas.init();
			
			_tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_tf.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_tf.addEventListener(Event.CHANGE, onTextChanged);
			_tf.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_tf.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function updateHeight(silent:Boolean = true):void
		{
			var newNumLines:int = Math.max(_tf.numLines, 1);
			if (_currentNumLines != newNumLines || _oldText == null || _oldText.length == 0)
			{
				_currentNumLines = newNumLines;
				
				var maxTextHeight:int = VERTICAL_HEIGHT - _canvas.y * 2;
				var tfHeight:int = _tf.textHeight + 6;
				_tf.height = tfHeight;
				
				_contentHeight = _isVertical ? VERTICAL_HEIGHT : Math.min(VERTICAL_HEIGHT, _tf.height + 4);
				
				if (silent)
				{
					_canvas.updateControls(false);
				}
				else
				{
					dispatchHeightChanged();
				}
			}
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
		
		override public function dispose():void 
		{
			super.dispose();
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_currentNumLines = 0;
			_oldText = null;
			_tf.text = '';
			
			_tf.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_tf.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_tf.removeEventListener(Event.CHANGE, onTextChanged);
			_tf.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_tf.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			_canvas.dispose();
		}
	}
}