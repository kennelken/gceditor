package ru.kennel32.editor.view.interfaces
{
	import flash.display.DisplayObject;
	
	public interface ICustomPositionable
	{
		function onPosOffsetChanged(x:int, y:int):void;
		function get posOffsetX():int;
		function get posOffsetY():int;
	}
}