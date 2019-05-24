package ru.kennel32.editor.view.components.buttons 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.enum.Filter;
	
	public class BtnAdd extends SimpleButton
	{
		public function BtnAdd(size:int)
		{
			var upState:Shape = drawState(size, 1);
			var overState:Shape = drawState(size, 0.85);
			var downState:Shape = drawState(size, 0.85);
			var hitState:Shape = drawState(size, 1);
			
			enabled = true;
			
			cacheAsBitmap = true;
			
			super(upState, overState, downState, hitState);
		}
		
		private function drawState(size:int, scale:Number):Shape
		{
			var realSize:Number = size * scale;
			var offset:Number = size * (1 - scale) / 2;
			
			var res:Shape = new Shape();
			res.graphics.beginFill(Color.GREEN, 1);
			res.graphics.lineStyle(1, Color.BORDER);
			res.graphics.drawRect(offset, offset, realSize, realSize);
			res.graphics.endFill();
			
			res.graphics.lineStyle(realSize / 5, Color.WHITE);
			
			res.graphics.moveTo(offset + realSize / 4,		offset + realSize / 2);
			res.graphics.lineTo(offset + 3 * realSize / 4,	offset + realSize / 2);
			
			res.graphics.moveTo(offset + realSize / 2,	offset + realSize / 4);
			res.graphics.lineTo(offset + realSize / 2,	offset + 3 * realSize / 4);
			
			return res;
		}
		
		private var _enabled:Boolean;
		override public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		override public function set enabled(value:Boolean):void 
		{
			super.enabled = value;
			
			_enabled = value;
			filters = _enabled ? null : [Filter.INACTIVE_COLOR];
			if (_enabled)
			{
				removeEventListener(MouseEvent.CLICK, onMouseClick, false);
			}
			else
			{
				addEventListener(MouseEvent.CLICK, onMouseClick, false, int.MAX_VALUE);
			}
		}
		
		private function onMouseClick(e:Event):void
		{
			if (!_enabled)
			{
				e.stopImmediatePropagation();
			}
		}
	}
}