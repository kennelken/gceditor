package ru.kennel32.editor.view.interfaces
{
	import flash.display.DisplayObject;
	
	public interface IDraggable
	{
		function get canDrag():Boolean;
		function get ctrlKey():Boolean;
		function get dragTarget():DisplayObject;
		function get dragX():Boolean;
		function get dragY():Boolean;
	}
}