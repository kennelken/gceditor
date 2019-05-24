package ru.kennel32.editor.view.components 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.components.controls.ScrollBar;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.interfaces.IDraggable;
	import ru.kennel32.editor.view.mouse.MouseUtils;
	import ru.kennel32.editor.view.utils.DragManager;
	import ru.kennel32.editor.view.utils.MouseWheelManager;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	[Event(name="resize", type="ru.kennel.editor.data.events")]
	public class ScrollableCanvas extends CanvasSprite implements IDisposable, IDraggable
	{
		private var SCROLL_STEP_WITH_MOUSE_WHEEL:int = 30;
		
		private var _hScroll:Boolean;
		private var _vScroll:Boolean;
		
		private var _content:DisplayObject;
		private var _canvas:Sprite;
		private var _scrollBarH:ScrollBar;
		private var _scrollBarV:ScrollBar;
		
		private var _keepYConstForY:Number;
		private var _keepYConstFor:DisplayObject;
		
		private var _scale:Number;
		private var _receiveMouseWheel:Boolean;
		
		public function ScrollableCanvas(hScroll:Boolean = true, vScroll:Boolean = true)
		{
			super();
			
			_hScroll = hScroll;
			_vScroll = vScroll;
			
			_canvas = new Sprite();
			addChild(_canvas);
			
			_scrollBarH = new ScrollBar();
			_scrollBarH.addEventListener(Event.CHANGE, onScrollBarHChange);
			addChild(_scrollBarH);
			
			_scrollBarV = new ScrollBar();
			_scrollBarV.rotation = 90;
			_scrollBarV.addEventListener(Event.CHANGE, onScrollBarVChange);
			addChild(_scrollBarV);
			
			cacheAsBitmap = true;
		}
		
		public function init():void
		{
			_receiveMouseWheel = true;
			_scrollBarH.init();
			_scrollBarV.init();
		}
		
		public function dispose():void
		{
			MouseWheelManager.getInstance().unregisterArea(this);
			DragManager.unregister(this);
			_receiveMouseWheel = false;
			
			_scrollBarH.dispose();
			_scrollBarV.dispose();
			
			keepYConstFor = null;
		}
		
		public function get keepYConstFor():DisplayObject
		{
			return _keepYConstFor;
		}
		
		public function set keepYConstFor(value:DisplayObject):void
		{
			_keepYConstFor = value;
			_keepYConstForY = NaN;
		}
		
		override public function setSize(width:int = -1, height:int = -1):void
		{
			super.setSize(width, height);
			
			_scrollBarV.x = _width;
			_scrollBarH.y = _height - ScrollBar.HEIGHT;
			
			updateControls(false);
		}
		
		public function setContent(content:DisplayObject):void
		{
			if (content == _content)
			{
				return;
			}
			
			DragManager.unregister(this);
			
			if (_content != null && _content.parent == _canvas)
			{
				_content.x = 0;
				_content.y = 0;
				updateKeepConstY();
				
				_canvas.removeChild(_content);
			}
			
			keepYConstFor = null;
			
			_content = content;
			
			if (content != null)
			{
				_content.x = 0;
				_content.y = 0;
				updateKeepConstY();
				_canvas.addChild(_content);
				
				DragManager.register(this, onDragged);
			}
			
			updateControls(true);
		}
		
		public function setContentPosition(x:int, y:int):void
		{
			_content.x = x;
			_content.y = y;
			updateKeepConstY();
			updateControls(false);
		}
		
		private function onDragged(draggable:IDraggable):void
		{
			updateControls();
		}
		
		public function updateControls(resetScrollBars:Boolean = false):void
		{
			var scrollRect:Rectangle = new Rectangle(0, 0, _width, _height);
			
			_scrollBarH.visible = false;
			_scrollBarV.visible = false;
			
			if (_content == null)
			{
				return;
			}
			
			if (_hScroll && contentWidth > scrollRect.width)
			{
				_scrollBarH.visible = true;
				scrollRect.height -= ScrollBar.HEIGHT;
			}
			
			if (_vScroll && contentHeight > scrollRect.height)
			{
				_scrollBarV.visible = true;
				scrollRect.width -= ScrollBar.HEIGHT;
				
				if (_hScroll && !_scrollBarH.visible && contentWidth > scrollRect.width)
				{
					_scrollBarH.visible = true;
					scrollRect.height -= ScrollBar.HEIGHT;
				}
			}
			
			if (_scrollBarH.visible)
			{
				_scrollBarH.setSizeByContentSize(scrollRect.width, contentWidth);
			}
			
			if (_scrollBarV.visible)
			{
				_scrollBarV.setSizeByContentSize(scrollRect.height, contentHeight);
			}
			
			if (scrollRect.width > contentWidth + _content.x)
			{
				_content.x = Math.min(0, scrollRect.width - contentWidth);
			}
			if (scrollRect.height > contentHeight + _content.y)
			{
				_content.y = Math.min(0, scrollRect.height - contentHeight);
			}
			
			if (_content.x > 0)
			{
				_content.x = 0;
			}
			if (_content.y > 0)
			{
				_content.y = 0;
			}
			
			_scrollBarH.value = -_content.x / (contentWidth - scrollRect.width);
			_scrollBarV.value = -_content.y / (contentHeight - scrollRect.height);
			updateKeepConstY();
			
			if (resetScrollBars)
			{
				_scrollBarH.value = 0;
				_scrollBarV.value = 0;
			}
			
			_canvas.scrollRect = scrollRect;
			
			if (canDrag)
			{
				MouseWheelManager.getInstance().registerArea(this, onMouseWheel);
			}
			else
			{
				MouseWheelManager.getInstance().unregisterArea(this);
			}
		}
		
		private function onScrollBarHChange(e:Event):void
		{
			_content.x = _scrollBarH.value * (_canvas.scrollRect.width - contentWidth);
			updateKeepConstY();
		}
		
		private function onScrollBarVChange(e:Event):void
		{
			_content.y = _scrollBarV.value * (_canvas.scrollRect.height - contentHeight); 
			updateKeepConstY();
		}
		
		public function get contentWidth():int
		{
			return ViewUtils.getContentWidth(_content) * _content.scaleX;
		}
		
		public function get contentHeight():int
		{
			return ViewUtils.getContentHeight(_content) * _content.scaleY;
		}
		
		private function updateKeepConstY():void
		{
			if (stage == null || _keepYConstFor == null || _keepYConstFor.stage == null)
			{
				return;
			}
			
			if (isNaN(_keepYConstForY))
			{
				_keepYConstForY = _keepYConstFor.parent.localToGlobal(new Point(_keepYConstFor.x, _keepYConstFor.y)).y;;
			}
			_keepYConstFor.y = _keepYConstFor.parent.globalToLocal(new Point(0, _keepYConstForY)).y;
		}
		
		private function onMouseWheel(step:int):void
		{
			if (_vScroll)
			{
				var stepAbs:int = Math.abs(step);
				var stepDirection:int = step > 0 ? 1 : -1;
				var distance:int = Math.min(_canvas.height / 2, stepAbs * SCROLL_STEP_WITH_MOUSE_WHEEL);
				_content.y += stepDirection * distance;
				updateControls(false);
			}
		}
		
		public function focusOn(dobj:DisplayObject, onlyY:Boolean = true):void
		{
			var rect:Rectangle = dobj.getRect(_content);
			if (!onlyY)
			{
				_content.x = -rect.x + int((_width - rect.width) / 2);
			}
			_content.y = -rect.y + int((_height - rect.height) / 2);
			updateControls(false);
			
			Main.instance.mainUI.playAttentionEffect(dobj);
		}
		
		public function get canDrag():Boolean
		{
			return _receiveMouseWheel &&
				(_scrollBarH.visible || _scrollBarV.visible);
		}
		public function get ctrlKey():Boolean
		{
			return true;
		}
		public function get dragTarget():DisplayObject
		{
			return _content;
		}
		public function get dragX():Boolean
		{
			return _hScroll;
		}
		public function get dragY():Boolean
		{
			return _vScroll;
		}
	}
}