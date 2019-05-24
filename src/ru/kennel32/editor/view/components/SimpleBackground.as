package ru.kennel32.editor.view.components 
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import ru.kennel32.editor.view.enum.Color;
	
	public class SimpleBackground extends Shape 
	{
		private var _width:int;
		private var _height:int;
		private var _addHeader:Boolean;
		
		public function SimpleBackground(width:int = 0, height:int = 0, addHeader:Boolean = false) 
		{
			super();
			cacheAsBitmap = true;
			_addHeader = addHeader;
			setSize(width, height);
		}
		
		public function setSize(width:int, height:int):void
		{
			_width = width;
			_height = height;
			
			redraw();
		}
		
		private function redraw():void
		{
			var graphics:Graphics = this.graphics;
			
			graphics.clear();
			
			if (_width > 0 && _height > 0)
			{
				graphics.beginFill(Color.FORM_BODY, 1);
				graphics.lineStyle(1, Color.BORDER, 1);
				graphics.drawRoundRectComplex(0, 0, _width, _height, 10, 10, 10, 10);
				graphics.endFill();
			}
			
			if (_addHeader)
			{
				graphics.beginFill(Color.FORM_HEADER, 1);
				graphics.lineStyle(1, Color.BORDER, 1);
				graphics.drawRoundRectComplex(0, 0, _width, 28, 10, 10, 0, 0);
				graphics.endFill();
			}
		}
	}
}