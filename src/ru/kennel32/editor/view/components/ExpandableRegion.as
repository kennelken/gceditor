package ru.kennel32.editor.view.components 
{
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.mouse.MouseUtils;

	public class ExpandableRegion extends CanvasSprite implements IDisposable
	{
		public static const MOVE_ZONE:int = 5;
		
		private var _drawSides:RectSides;
		private var _expandableSides:RectSides;
		private var _style:ExpandableRegionStyle;
		
		public function ExpandableRegion(drawSides:RectSides = null, expandableSides:RectSides = null, style:ExpandableRegionStyle = null)
		{
			super();
			
			_drawSides = drawSides;
			if (_drawSides == null)
			{
				_drawSides = RectSides.SIDES_1111;
			}
			
			_expandableSides = expandableSides;
			if (_expandableSides == null)
			{
				_expandableSides = RectSides.SIDES_0000;
			}
			
			_style = style;
			if (_style == null)
			{
				_style = ExpandableRegionStyle.MAJOR;
			}
			
			mouseChildren = false;
			cacheAsBitmap = true;
		}
		
		public function init():void
		{
			if (!_expandableSides.isEmpty)
			{
				addEventListener(MouseEvent.MOUSE_MOVE, updateMouseCursorOnMouseMove);
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
				addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			}
		}
		
		public function dispose():void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, updateMouseCursorOnMouseMove);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			
			Main.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			graphics.clear();
		}
		
		override public function setSize(width:int = -1, height:int = -1):void
		{
			super.setSize(width, height);
			redraw();
		}
		
		public function redraw():void
		{
			var graphics:Graphics = this.graphics;
			
			graphics.clear();
			if (_width <= 0 || _height <= 0)
			{
				return;
			}
			
			graphics.lineStyle(NaN, 0, 0);
			graphics.beginFill(_style.fillColor, _style.fillAlpha);
			graphics.drawRect(0, 0, _width, _height);
			
			graphics.lineStyle(_style.borderThickness, _style.borderColor);
			
			var offset:Number = _style.borderThickness / 2;
			
			for each (var side:int in RectSides.ALL)
			{
				if (_drawSides[side])
				{
					switch (side)
					{
						case RectSides.LEFT:
							graphics.moveTo(offset, offset);
							graphics.lineTo(offset, _height - offset);
							break;
						
						case RectSides.RIGHT:
							graphics.moveTo(_width - offset, offset);
							graphics.lineTo(_width - offset, _height - offset);
							break;
						
						case RectSides.TOP:
							graphics.moveTo(offset, offset);
							graphics.lineTo(_width - offset, offset);
							break;
						
						case RectSides.BOTTOM:
							graphics.moveTo(offset, _height - offset);
							graphics.lineTo(_width - offset, _height - offset);
							break;
					}
				}
			}
		}
		
		private var _currentMoveSides:RectSides;
		private var _mouseStartPos:Point;
		private var _mouseStartSize:Point;
		
		private function onMouseDown(e:Event):void
		{
			var mouseNearBounds:RectSides = getMouseNearBounds();
			
			if (mouseNearBounds.isEmpty)
			{
				return;
			}
			
			_currentMoveSides = mouseNearBounds;
			_mouseStartPos = new Point(mouseX, mouseY);
			
			Main.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Main.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(e:Event):void
		{
			if (_currentMoveSides[RectSides.LEFT] || _currentMoveSides[RectSides.RIGHT])
			{
				var deltaX:int = mouseX - _mouseStartPos.x;
				var deltaWidth:int = (_currentMoveSides[RectSides.LEFT] ? -1 : 1) * deltaX;
				deltaWidth = Math.min(maxWidth, Math.max(minWidth, _width + deltaWidth)) - _width;
			}
			
			if (_currentMoveSides[RectSides.TOP] || _currentMoveSides[RectSides.BOTTOM])
			{
				var deltaY:int = mouseY - _mouseStartPos.y;
				var deltaHeight:int = (_currentMoveSides[RectSides.TOP] ? -1 : 1) * deltaY;
				deltaHeight = Math.min(maxHeight, Math.max(minHeight, _height + deltaHeight)) - _height;
			}
			
			if (deltaWidth == 0 && deltaHeight == 0)
			{
				return;
			}
			
			var oldPos:Point = new Point(x, y);
			var oldSize:Point = new Point(_width, _height);
			
			if (deltaWidth != 0)
			{
				_mouseStartPos.x = mouseX;
			}
			
			if (deltaHeight != 0)
			{
				_mouseStartPos.y = mouseY;
			}
			
			if (_currentMoveSides[RectSides.LEFT])
			{
				x -= deltaWidth;
			}
			if (_currentMoveSides[RectSides.TOP])
			{
				y -= deltaHeight
			}
			
			setSize(_width + deltaWidth, _height + deltaHeight);
		}
		
		private function updateMouseCursorOnMouseMove(e:Event):void
		{
			if (_currentMoveSides != null)
			{
				return;
			}
			
			var mouseNearBounds:RectSides = getMouseNearBounds();
			
			if (mouseNearBounds.left || mouseNearBounds.right)
			{
				if (mouseNearBounds.top || mouseNearBounds.bottom)
				{
					MouseUtils.setModeExpandHV();
				}
				else
				{
					MouseUtils.setModeExpandH();
				}
			}
			else if (mouseNearBounds.top || mouseNearBounds.bottom)
			{
				MouseUtils.setModeExpandV();
			}
			else
			{
				MouseUtils.reset();
			}
		}
		
		private function getMouseNearBounds():RectSides
		{
			if (_expandableSides[RectSides.LEFT] && mouseX <= MOVE_ZONE && mouseX >= 0)
			{
				var isLeft:Boolean = true;
			}
			if (_expandableSides[RectSides.RIGHT] && mouseX >= _width - MOVE_ZONE && mouseX <= _width)
			{
				var isRight:Boolean = true;
			}
			if (_expandableSides[RectSides.TOP] && mouseY <= MOVE_ZONE && mouseY >= 0)
			{
				var isTop:Boolean = true;
			}
			if (_expandableSides[RectSides.BOTTOM] && mouseY >= _height - MOVE_ZONE && mouseY <= _height)
			{
				var isBottom:Boolean = true;
			}
			
			return new RectSides(isLeft, isRight, isTop, isBottom);
		}
		
		private function onMouseOut(e:Event):void
		{
			if (_currentMoveSides != null)
			{
				return;
			}
			
			MouseUtils.reset();
		}
		
		private function onMouseUp(e:Event):void
		{
			_currentMoveSides = null;
			_mouseStartPos = null;
			
			Main.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			Main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			MouseUtils.reset();
		}
		
		private function onMouseOver(e:Event):void
		{
			if (_currentMoveSides != null)
			{
				return;
			}
			
			updateMouseCursorOnMouseMove(e);
		}
	}
}