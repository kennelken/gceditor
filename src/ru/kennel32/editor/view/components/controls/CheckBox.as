package ru.kennel32.editor.view.components.controls
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.enum.Filter;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class CheckBox extends Sprite
	{
		private var _size:int;
		private var _btnChecked:SimpleButton;
		private var _btnNotChecked:SimpleButton;
		private var _checked:Boolean;
		private var _boxTf:Sprite;
		private var _tf:TextField;
		
		public function CheckBox(size:int)
		{
			super();
			
			_size = size;
			
			_btnChecked = drawButton(size, true);
			addChild(_btnChecked);
			
			_btnNotChecked = drawButton(size, false);
			addChild(_btnNotChecked);
			
			_boxTf = new Sprite();
			_boxTf.mouseChildren = false;
			_boxTf.mouseEnabled = false;
			
			_tf = TextUtils.getText('', Color.FONT, size - 2);
			_tf.y = -2;
			_tf.x = size + 3;
			_boxTf.addChild(_tf);
			
			cacheAsBitmap = true;
			enabled = true;
			
			_checked = true;
			checked = false;
			
			addEventListener(MouseEvent.CLICK, onClick, false, int.MAX_VALUE);
			buttonMode = true;
		}
		
		public function get checked():Boolean
		{
			return _checked;
		}
		
		public function set checked(value:Boolean):void
		{
			if (_checked == value)
			{
				return;
			}
			
			_checked = value;
			
			_btnChecked.visible = _checked;
			_btnNotChecked.visible = !_checked;
		}
		
		public function set text(value:String):void
		{
			_tf.text = value;
			ViewUtils.setParent(_boxTf, this, value != null && value.length > 0);
		}
		public function get text():String
		{
			return _tf.text;
		}
		
		private var _enabled:Boolean;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			
			mouseChildren = mouseEnabled = enabled;
			
			filters = enabled ? null : [Filter.INACTIVE_COLOR];
		}
		
		private function drawButton(size:int, checked:Boolean):SimpleButton
		{
			var upState:Shape = drawState(size, 1, checked);
			var overState:Shape = drawState(size, 0.85, checked);
			var downState:Shape = drawState(size, 0.85, checked);
			var hitState:Shape = drawState(size, 1, false);
			
			var res:SimpleButton = new SimpleButton(upState, overState, downState, hitState);
			
			return res;
		}
		
		private function drawState(size:int, scale:Number, checked:Boolean):Shape
		{
			var realSize:Number = size * scale;
			var offset:Number = size * (1 - scale) / 2;
			
			var res:Shape = new Shape();
			res.graphics.beginFill(Color.BUTTON_BODY, 1);
			res.graphics.lineStyle(1, Color.BORDER);
			res.graphics.drawRect(offset, offset, realSize, realSize);
			res.graphics.endFill();
			
			res.graphics.lineStyle(realSize / 5, Color.FONT);
			
			if (checked)
			{
				res.graphics.moveTo(offset,					offset + realSize / 2);
				res.graphics.lineTo(offset + realSize / 2,	offset + realSize);
				res.graphics.lineTo(offset + realSize,		offset);
			}
			
			return res;
		}
		
		private function onClick(e:Event):void
		{
			if (ViewUtils.isSpecialKey(e))
			{
				return;
			}
			
			checked = !_checked;
			e.preventDefault();
			e.stopImmediatePropagation();
			
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}