package ru.kennel32.editor.view.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class HBox extends Sprite
	{
		private var _space:int;
		
		public function HBox(space:int = 5)
		{
			super();
			
			_space = space;
		}
		
		public function resize():void
		{
			var maxHeight:int;
			for (var i:int = 0; i < numChildren; i++)
			{
				maxHeight = Math.max(maxHeight, getChildAt(i).height);
			}
			
			var currentX:int;
			for (i = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				child.x = currentX;
				currentX += child.width + _space;
				
				child.y = int((maxHeight - child.height) / 2);
			}
		}
		
		public function get space():int
		{
			return _space;
		}
		public function set space(value:int):void
		{
			_space = value;
			resize();
		}
	}
}