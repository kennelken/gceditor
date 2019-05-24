package ru.kennel32.editor.view.components.tooltip
{
	import flash.geom.Rectangle;
	
	public interface ICustomTooltipView
	{
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function get width():Number;
		function set width(value:Number):void;
		
		function get height():Number;
		function set height(value:Number):void;
		
		function get tooltipData():*;
		function set tooltipData(value:*):void;
		
		function update():void;
	}
}