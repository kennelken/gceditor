package ru.kennel32.editor.view.components.buttons 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import ru.kennel32.editor.view.enum.Color;
	
	public class BtnExpand extends SimpleButton
	{
		private var _collapse:Boolean;
		
		public function BtnExpand(size:int, collapse:Boolean = false)
		{
			_collapse = collapse;
			
			var upState:Shape = drawState(size, 1);
			var overState:Shape = drawState(size, 0.85);
			var downState:Shape = drawState(size, 0.85);
			var hitState:Shape = drawState(size, 1);
			
			cacheAsBitmap = true;
			
			super(upState, overState, downState, hitState);
		}
		
		private function drawState(size:int, scale:Number):Shape
		{
			var realSize:Number = size * scale;
			var offset:Number = size * (1 - scale) / 2;
			
			var res:Shape = new Shape();
			res.graphics.beginFill(Color.BUTTON_BODY, 1);
			res.graphics.lineStyle(1, Color.BORDER);
			res.graphics.drawRect(offset, offset, realSize, realSize);
			res.graphics.endFill();
			
			res.graphics.lineStyle(realSize / 5, Color.FONT);
			
			res.graphics.moveTo(offset + realSize / 4,		offset + realSize / 2);
			res.graphics.lineTo(offset + 3 * realSize / 4,	offset + realSize / 2);
			if (!_collapse)
			{
				res.graphics.moveTo(offset + realSize / 2,	offset + realSize / 4);
				res.graphics.lineTo(offset + realSize / 2,	offset + 3 * realSize / 4);
			}
			
			return res;
		}
	}
}