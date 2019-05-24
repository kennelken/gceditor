package ru.kennel32.editor.view.mouse 
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	
	public class MouseUtils 
	{
		private static const CUSTOM_ICONS_SIZE:int = 28;
		
		public static function init():void
		{
			registerExpandHCursor();
			registerExpandVCursor();
			registerExpandHVCursor();
		}
		
		public static function setModeExpandH():void
		{
			Mouse.cursor = 'expandH';
		}
		public static function setModeExpandV():void
		{
			Mouse.cursor = 'expandV';
		}
		public static function setModeExpandHV():void
		{
			Mouse.cursor = 'expandHV';
		}
		public static function setModeDrag():void
		{
			Mouse.cursor = MouseCursor.HAND;
		}
		public static function reset():void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private static function registerExpandHCursor():void
		{
			var icon:Sprite = drawExpandIcon(0);
			var bitmapData:BitmapData = new BitmapData(icon.width + 1, icon.height + 1, true, 0);
			bitmapData.draw(icon, null, null, null, null, true);
			
			var cursorData:MouseCursorData = new MouseCursorData();
			cursorData.data = Vector.<BitmapData>([bitmapData]);
			cursorData.hotSpot = new Point(int(bitmapData.width / 2), int(bitmapData.height / 2));
			
			Mouse.registerCursor('expandH', cursorData);
		}
		
		private static function registerExpandVCursor():void
		{
			var icon:Sprite = drawExpandIcon(90);
			var bitmapData:BitmapData = new BitmapData(icon.width + 1, icon.height + 1, true, 0);
			bitmapData.draw(icon, null, null, null, null, true);
			
			var cursorData:MouseCursorData = new MouseCursorData();
			cursorData.data = Vector.<BitmapData>([bitmapData]);
			cursorData.hotSpot = new Point(int(bitmapData.width / 2), int(bitmapData.height / 2));
			
			Mouse.registerCursor('expandV', cursorData);
		}
		
		private static function registerExpandHVCursor():void
		{
			var icon1:Sprite = drawExpandIcon(0);
			var icon2:Sprite = drawExpandIcon(90);
			var bitmapData:BitmapData = new BitmapData(Math.max(icon1.width, icon2.width) + 1, Math.max(icon1.height, icon2.height) + 1, true, 0);
			
			var m1:Matrix = new Matrix();
			m1.ty = int((icon2.height - icon1.height) / 2)
			bitmapData.draw(icon1, m1, null, null, null, true);
			
			var m2:Matrix = new Matrix();
			m2.tx = int((icon1.width - icon2.width) / 2)
			bitmapData.draw(icon2, m2, null, null, null, true);
			
			var cursorData:MouseCursorData = new MouseCursorData();
			cursorData.data = Vector.<BitmapData>([bitmapData]);
			cursorData.hotSpot = new Point(int(bitmapData.width / 2), int(bitmapData.height / 2));
			
			Mouse.registerCursor('expandHV', cursorData);
		}
		
		private static function drawExpandIcon(rotation:Number):Sprite
		{
			var box:Sprite = new Sprite();
			
			var cont:Sprite = new Sprite();
			box.addChild(cont);
			
			var res:Shape = new Shape();
			res.graphics.lineStyle(1, 0x515151, 1);
			
			var width:Number = CUSTOM_ICONS_SIZE;
			var height:Number = width / 3;
			
			res.graphics.beginFill(0xFFFFFF, 1);
			res.graphics.moveTo(0, height / 2);
			res.graphics.lineTo(width / 3, 0);
			res.graphics.lineTo(width / 3, height);
			res.graphics.lineTo(0, height / 2);
			res.graphics.endFill();
			
			res.graphics.beginFill(0xFFFFFF, 1);
			res.graphics.moveTo(width * 2 / 3, 0);
			res.graphics.lineTo(width, height / 2);
			res.graphics.lineTo(width * 2 / 3, height);
			res.graphics.lineTo(width * 2 / 3, 0);
			res.graphics.endFill();
			
			res.x = -int(width / 2) + 0.5;
			res.y = -int(height / 2) + 0.5;
			cont.rotation = rotation;
			
			cont.addChild(res);
			
			var rect:Rectangle = cont.getRect(box);
			cont.x = -rect.x;
			cont.y = -rect.y;
			
			return box;
		}
		
		public static function get isCustomMode():Boolean
		{
			return Mouse.cursor != MouseCursor.AUTO;
		}
	}
}