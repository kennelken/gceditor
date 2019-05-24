package ru.kennel32.editor.view.components.canvas
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import ru.kennel32.editor.view.interfaces.IDraggable;
	
	public class DraggableCanvas implements IDraggable
	{
		private var _dragtarget:DisplayObject;
		
		public function DraggableCanvas(target:DisplayObject)
		{
			_dragtarget = target;
		}
		
		public function get canDrag():Boolean
		{
			return true;
		}
		
		public function get ctrlKey():Boolean
		{
			return false;
		}
		
		public function get dragTarget():DisplayObject
		{
			return _dragtarget;
		}
		
		public function get dragX():Boolean
		{
			return true;
		}
		
		public function get dragY():Boolean
		{
			return true;
		}
	}
}