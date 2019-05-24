package ru.kennel32.editor.view.components.canvas
{
	import flash.display.Sprite;
	import ru.kennel32.editor.view.interfaces.ICustomSizeable;
	
	public class DelegateSizeCanvas extends Sprite implements ICustomSizeable
	{
		private var _width:Function;
		private var _height:Function;
		
		public function DelegateSizeCanvas(width:Function, height:Function)
		{
			_width = width;
			_height = height;
			super();
		}
		
		override public function get width():Number 
		{
			return _width();
		}
		
		override public function get height():Number 
		{
			return _height();
		}
	}
}