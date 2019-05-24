package ru.kennel32.editor.view.components.buttons
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.enum.Filter;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class LabeledButton extends CanvasSprite
	{
		private var _enabled:Boolean;
		private var _tfLabel:TextField;
		
		public function LabeledButton(label:String = null)
		{
			super(true);
			
			_tfLabel = TextUtils.getTextCentered(label, Color.FONT, 16);
			_tfLabel.height = 20;
			_tfLabel.mouseEnabled = false;
			addChild(_tfLabel);
			
			cacheAsBitmap = true;
			
			enabled = true;
			
			setSize(120, 26);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			redraw();
			
			_tfLabel.x = 3;
			_tfLabel.width = _width - 2 * _tfLabel.x;
			_tfLabel.y = int((_height - _tfLabel.textHeight) / 2) - 2;
		}
		
		private function redraw():void
		{
			var graphics:Graphics = this.graphics;
			
			graphics.clear();
			
			var ellipse:Number = Math.min(_width, _height) / 2;
			
			graphics.lineStyle(1, Color.BORDER);
			graphics.beginFill(Color.BUTTON_BODY);
			graphics.drawRoundRect(0, 0, _width - 1, _height - 1, ellipse, ellipse);
			graphics.endFill();
			
			filters = _enabled ? null : [Filter.INACTIVE_COLOR];
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value)
			{
				return;
			}
			
			_enabled = value;
			buttonMode = _enabled;
			redraw();
			
			if (!_enabled)
			{
				addEventListener(MouseEvent.CLICK, onMouseClick, false, int.MAX_VALUE);
			}
			else
			{
				removeEventListener(MouseEvent.CLICK, onMouseClick);
			}
		}
		
		private function onMouseClick(e:Event):void
		{
			e.stopImmediatePropagation();
		}
	}
}