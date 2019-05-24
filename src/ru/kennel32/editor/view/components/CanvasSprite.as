package ru.kennel32.editor.view.components 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.interfaces.ICustomSizeable;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	
	[Event(name="resize", type="flash.events.Event")]
	public class CanvasSprite extends Sprite implements ICustomSizeable
	{
		public function CanvasSprite(stopChildEvents:Boolean = false)
		{
			super();
			scrollRect = new Rectangle(0, 0, 0, 0);
			
			if (stopChildEvents)
			{
				addEventListener(Event.RESIZE, onChildResize, false, int.MAX_VALUE);
			}
		}
		
		protected var _width:int;
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			setSize(value, -1);
		}
		
		protected var _height:int;
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			setSize(-1, value);
		}
		
		private var _minWidth:int;
		public function get minWidth():int
		{
			return _minWidth;
		}
		public function set minWidth(value:int):void
		{
			_minWidth = value;
		}
		
		private var _maxWidth:int = int.MAX_VALUE;
		public function get maxWidth():int
		{
			return _maxWidth;
		}
		public function set maxWidth(value:int):void
		{
			_maxWidth = value;
		}
		
		private var _minHeight:int;
		public function get minHeight():int
		{
			return _minHeight;
		}
		public function set minHeight(value:int):void
		{
			_minHeight = value;
		}
		
		private var _maxHeight:int = int.MAX_VALUE;
		public function get maxHeight():int
		{
			return _maxHeight;
		}
		public function set maxHeight(value:int):void
		{
			_maxHeight = value;
		}
		
		public function setSize(width:int = -1, height:int = -1):void
		{
			var newWidth:int = Math.min(_maxWidth, Math.max(_minWidth, width <= -1 ? _width : width));
			var newHeight:int = Math.min(_maxHeight, Math.max(_minHeight, height <= -1 ? _height : height));
			
			if (newWidth == _width && newHeight == _height)
			{
				return;
			}
			
			_width = newWidth;
			_height = newHeight;
			
			scrollRect = new Rectangle(0, 0, _width, _height);
			
			dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		private function onChildResize(e:Event):void
		{
			if (e.target != this)
			{
				e.stopImmediatePropagation();
			}
		}
		
		public function fitToContent():void
		{
			var width:int;
			var height:int;
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				width = Math.max(width, child.x + child.width + 1);
				height = Math.max(height, child.y + child.height + 1);
			}
			
			setSize(width, height);
		}
		
		public function alignChildren(align:Align, gap:Number = NaN, autoGap:Boolean = false, offset:int = 0):void
		{
			switch (align)
			{
				case Align.H_LEFT:
				case Align.H_CENTER:
				case Align.H_RIGHT:
					var isVerticalGap:Boolean = true;
					break;
			}
			if (autoGap)
			{
				var childrenSize:int;
				for (var i:int = 0; i < numChildren; i++)
				{
					var child:DisplayObject = getChildAt(i);
					
					childrenSize += isVerticalGap ? child.height : child.width;
				}
				gap = ((isVerticalGap ? _height : _width) - 2 * offset - childrenSize) / (numChildren - 1);
			}
			
			for (i = 0; i < numChildren; i++)
			{
				child = getChildAt(i);
				
				switch (align)
				{
					case Align.H_LEFT:
						child.x = offset;
						break;
					
					case Align.H_CENTER:
						child.x = offset + int((_width - 2 * offset - child.width) / 2);
						break;
					
					case Align.H_RIGHT:
						child.x = offset + int(_width - 2 * offset - child.width);
						break;
					
					case Align.V_TOP:
						child.y = offset;
						break;
					
					case Align.V_CENTER:
						child.y = offset + int((_height - 2 * offset - child.height) / 2);
						break;
					
					case Align.V_BOTTOM:
						child.y = int(_width - 2 * offset - child.width);
						break;
				}
			}
			
			var currentPos:int = offset;
			if (!isNaN(gap))
			{
				for (i = 0; i < numChildren; i++)
				{
					child = getChildAt(i);
					if (isVerticalGap)
					{
						child.y = currentPos;
						currentPos += gap + child.height;
					}
					else
					{
						child.x = currentPos;
						currentPos += gap + child.width;
					}
				}
			}
		}
		
		public function removeAllChildren(reset:Boolean = false, onReleaseCallback:Function = null):void
		{
			while (numChildren > 0)
			{
				var child:DisplayObject = removeChildAt(0);
				if (child is IDisposable)
				{
					(child as IDisposable).dispose();
				}
				
				if (onReleaseCallback != null)
				{
					onReleaseCallback(child);
				}
			}
		}
	}
}