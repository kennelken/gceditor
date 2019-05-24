package ru.kennel32.editor.view.components.buttons 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import ru.kennel32.editor.view.enum.Color;
	
	public class BtnClose extends SimpleButton
	{
		public function BtnClose(radius:int)
		{
			var upState:Shape = drawState(radius, 1);
			var overState:Shape = drawState(radius, 0.8);
			var downState:Shape = drawState(radius, 0.8);
			
			var hitState:Sprite = new Sprite();
			hitState.addChild(drawState(radius, 1));
			
			//cacheAsBitmap = true;	//prevents hitState from working
			
			super(upState, overState, downState, hitState);
		}
		
		private function drawState(radius:int, scale:Number):Shape
		{
			var realRadius:Number = radius * scale;
			var offset:Number = radius * (1 - scale);
			
			var res:Shape = new Shape();
			res.graphics.beginFill(Color.BUTTON_BODY, 1);
			res.graphics.lineStyle(null, 0, 0);
			res.graphics.drawCircle(offset + realRadius, offset + realRadius, realRadius);
			res.graphics.endFill();
			
			res.graphics.lineStyle(realRadius / 3.5, Color.FONT);
			res.graphics.moveTo(offset + realRadius / 2,		offset + realRadius / 2);
			res.graphics.lineTo(offset + 3 * realRadius / 2,	offset + 3 * realRadius / 2);
			res.graphics.moveTo(offset + 3 * realRadius / 2,	offset + realRadius / 2);
			res.graphics.lineTo(offset + realRadius / 2,		offset + 3 * realRadius / 2);
			
			return res;
		}
	}
}