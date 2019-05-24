package ru.kennel32.editor.view.components.controls 
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.interfaces.IDraggable;
	import ru.kennel32.editor.view.utils.DragManager;
	
	public class ScrollBar extends Sprite implements IDraggable, IDisposable
	{
		public static const HEIGHT:int = 12;
		private static const BAR_HEIGHT:int = 8;
		private static const MIN_BAR_WIDTH:int = 5;
		
		public function ScrollBar()
		{
			super();
			
			_base = new Sprite();
			_base.cacheAsBitmap = true;
			addChild(_base);
			
			_bar = new Sprite();
			_bar.cacheAsBitmap = true;
			_bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarMouseDown, false, int.MAX_VALUE);
			_bar.buttonMode = true;
			_bar.y = (HEIGHT - BAR_HEIGHT) / 2;
			addChild(_bar);
		}
		
		private var _base:Sprite;
		private var _bar:Sprite;
		
		private var _baseSize:int;
		public function get baseSize():int
		{
			return _baseSize;
		}
		
		private var _barSize:int;
		
		private var _value:Number;
		public function get value():Number
		{
			return _value;
		}
		public function set value(value:Number):void
		{
			_value = Math.max(0, Math.min(1, value));
			
			update();
		}
		
		private function update():void
		{
			var barMinX:Number = (HEIGHT - BAR_HEIGHT) / 2;
			var barMaxX:Number = _baseSize - barMinX - _bar.width;
			
			_bar.x = barMinX + _value * (barMaxX - barMinX); 
		}
		
		public function setSize(baseSize:int, barSize:int):void
		{
			_baseSize = baseSize;
			_barSize = Math.min(_baseSize, Math.max(MIN_BAR_WIDTH, barSize));
			
			var baseGraphics:Graphics = _base.graphics;
			
			baseGraphics.clear();
			baseGraphics.beginFill(Color.SCROLLBAR_BASE, 1);
			baseGraphics.drawRect(0, 0, _baseSize, HEIGHT);
			baseGraphics.endFill();
			
			var barGraphics:Graphics = _bar.graphics;
			
			barGraphics.clear();
			barGraphics.beginFill(Color.SCROLLBAR_BAR, 1);
			barGraphics.drawRect(0, 0, _barSize, BAR_HEIGHT);
			barGraphics.endFill();
			
			update();
		}
		
		public function setSizeByContentSize(canvasSize:int, contentSize:int):void
		{
			setSize(canvasSize, canvasSize * canvasSize / contentSize);
		}
		
		private var _startMouseX:int;
		private var _startBarX:int;
		private var _startValue:Number;
		
		private var _stage:Stage;
		
		private function onBarMouseDown(e:Event):void
		{
			_startValue = _value;
			_startMouseX = mouseX;
			_startBarX = _bar.x;
		}
		
		private function onMouseMove(...args):void
		{
			var barMinX:Number = (HEIGHT - BAR_HEIGHT) / 2;
			var barMaxX:Number = _baseSize - barMinX - _bar.width;
			
			value = _startValue + (mouseX - _startMouseX) / (barMaxX - barMinX);
			dispatchEvent(new Event(Event.CHANGE, false));
		}
		
		public function init():void
		{
			DragManager.register(this, onMouseMove);
		}
		
		public function dispose():void
		{
			DragManager.unregister(this);
		}
		
		public function get canDrag():Boolean
		{
			return visible;
		}
		public function get ctrlKey():Boolean
		{
			return false;
		}
		public function get dragTarget():DisplayObject
		{
			return _bar;
		}
		
		public function get dragX():Boolean
		{
			return true;
		}
		public function get dragY():Boolean
		{
			return false;
		}
	}
}