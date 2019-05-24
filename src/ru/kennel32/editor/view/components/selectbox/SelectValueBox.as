package ru.kennel32.editor.view.components.selectbox 
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.enum.Filter;
	import ru.kennel32.editor.view.forms.SelectValueForm;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class SelectValueBox extends CanvasSprite 
	{
		protected var _tfCurrentItem:TextField;
		
		protected var _currentValue:SelectBoxValue;
		protected var _values:Vector.<SelectBoxValue>;
		private var _border:Boolean;
		
		public function SelectValueBox(width:int = -1, height:int = -1, allowToCreateNewValue:Boolean = false, border:Boolean = true) 
		{
			width = width <= 0 ? 140 : width;
			height = height <= 0 ? 21 : height;
			
			super();
			
			_allowToCreateNewValue = allowToCreateNewValue;
			
			_tfCurrentItem = TextUtils.getText('', Color.FONT, 16);
			_tfCurrentItem.mouseEnabled = false;
			addChild(_tfCurrentItem);
			
			enabled = true;
			cacheAsBitmap = true;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			_currentValue = null;
			_border = border;
			
			setSize(width, height);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			redraw();
			
			_tfCurrentItem.x = _height;
			_tfCurrentItem.y = ((_height - 20) / 2) - 3;
		}
		
		private function redraw():void
		{
			var graphics:Graphics = this.graphics;
			
			graphics.clear();
			
			graphics.beginFill(Color.INPUT_TEXT_BACKGROUND, 1);
			if (_border)
			{
				graphics.lineStyle(1, Color.BORDER_LIGHT, 1);
			}
			graphics.drawRect(0, 0, _width - 1, _height - 1);
			graphics.endFill();
			
			graphics.beginFill(Color.BORDER, 1);
			graphics.lineStyle(0, 0, 0);
			graphics.drawCircle(_height / 2, _height / 2, _height / 4);
			graphics.endFill();
		}
		
		private var _enabled:Boolean;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			buttonMode = value;
			
			filters = _enabled ? null : [Filter.INACTIVE_COLOR];
		}
		
		private var _allowToCreateNewValue:Boolean;
		public function get allowToCreateNewValue():Boolean
		{
			return allowToCreateNewValue;
		}
		public function set allowToCreateNewValue(value:Boolean):void
		{
			_allowToCreateNewValue = value;
		}
		
		public function get value():Object
		{
			return _currentValue == null ? null : _currentValue.value;
		}
		
		public function setValue(value:Object, values:Vector.<SelectBoxValue>):void
		{
			_values = values;
			_currentValue = getItemByValue(value);
			
			_tfCurrentItem.text = _currentValue == null ? Texts.textEmpty : _currentValue.name;
		}
		
		protected function getItemByValue(value:Object):SelectBoxValue
		{
			for each (var val:SelectBoxValue in _values)
			{
				if (val.value == value)
				{
					return val;
				}
			}
			
			return null;
		}
		
		private var _openedSelectValueForm:SelectValueForm;
		protected function onMouseClick(e:Event):void
		{
			if (!_enabled)
			{
				return;
			}
			
			if (_openedSelectValueForm != null)
			{
				_openedSelectValueForm.removeEventListener(Event.CLOSE, onSelectWindowClosed);
				_openedSelectValueForm.removeEventListener(SelectBoxEvent.CREATE_NEW_ITEM, onCreateNewItem);
				_openedSelectValueForm.close();
				_openedSelectValueForm = null;
			}
			else
			{
				var values:Vector.<SelectBoxValue> = _values.filter(filterValues);
				
				_openedSelectValueForm = SelectValueForm.show(this, values, onItemSelected, _allowToCreateNewValue);
				_openedSelectValueForm.addEventListener(Event.CLOSE, onSelectWindowClosed);
				_openedSelectValueForm.addEventListener(SelectBoxEvent.CREATE_NEW_ITEM, onCreateNewItem);
			}
		}
		
		private function filterValues(v:SelectBoxValue, ...args):Boolean
		{
			return v.alwaysShown || !v.hidden;
		}
		
		private function onItemSelected(value:Object):void
		{
			if (value == this.value)
			{
				return;
			}
			
			setValue(value, _values);
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onSelectWindowClosed(e:Event):void
		{
			_openedSelectValueForm.removeEventListener(Event.CLOSE, onSelectWindowClosed);
			_openedSelectValueForm.removeEventListener(SelectBoxEvent.CREATE_NEW_ITEM, onCreateNewItem);
			_openedSelectValueForm = null;
		}
		
		private function onCreateNewItem(e:Event):void
		{
			dispatchEvent(e.clone());
		}
	}
}