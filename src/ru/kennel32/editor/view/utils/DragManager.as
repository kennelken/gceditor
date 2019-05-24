package ru.kennel32.editor.view.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import ru.kennel32.editor.view.components.canvas.DraggableCanvas;
	import ru.kennel32.editor.view.interfaces.IDraggable;
	import ru.kennel32.editor.view.mouse.MouseUtils;
	public class DragManager
	{
		private static var _instance:DragManager;
		
		private var _stage:Stage;
		private var _registered:Dictionary;
		private var _callbacks:Dictionary;
		private var _dragTargetByDobj:Dictionary;
		
		public function DragManager(stage:Stage)
		{
			_stage = stage;
			_callbacks = new Dictionary();
			_dragTargetByDobj = new Dictionary();
		}
		
		public static function init(stage:Stage):void
		{
			_instance = new DragManager(stage);
		}
		
		public static function register(target:DisplayObject, callback:Function = null):void
		{
			var draggable:IDraggable = target as IDraggable;
			if (draggable == null)
			{
				draggable = new DraggableCanvas(target);
			}
			_instance.reg(draggable, callback);
		}
		
		public static function unregister(target:DisplayObject):void
		{
			_instance.unreg(_instance._dragTargetByDobj[target] as IDraggable);
		}
		
		private function reg(draggable:IDraggable, callback:Function = null):void
		{
			if (_callbacks[draggable.dragTarget] != null && _callbacks[draggable.dragTarget] != callback)
			{
				throw new Error("Already registered with another callback");
			}
			_callbacks[draggable.dragTarget] = callback;
			
			draggable.dragTarget.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_dragTargetByDobj[draggable.dragTarget] = draggable;
		}
		
		private function unreg(draggable:IDraggable):void
		{
			if (draggable == null)
			{
				return;
			}
			
			delete _callbacks[draggable.dragTarget];
			delete _dragTargetByDobj[draggable.dragTarget];
			
			draggable.dragTarget.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			if (_draggable == draggable)
			{
				stopDragContent();
			}
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			var draggable:IDraggable = _dragTargetByDobj[e.currentTarget] as IDraggable;
			if (e.ctrlKey != draggable.ctrlKey || !draggable.canDrag)
			{
				return;
			}
			
			_isDragging = false;
			
			var parent:DisplayObject = e.target as DisplayObject;
			while (parent != e.currentTarget)
			{
				var registeredDragTarget:IDraggable = _dragTargetByDobj[parent] as IDraggable;
				if (registeredDragTarget != null && registeredDragTarget.canDrag && registeredDragTarget.ctrlKey == e.ctrlKey)
				{
					return;
				}
				var tf:TextField = parent as TextField;
				if (!e.ctrlKey && tf != null && tf.selectable && tf.mouseEnabled)
				{
					return;
				}
				parent = parent.parent;
			}
			
			e.stopImmediatePropagation();
			e.preventDefault();
			
			_draggable = _dragTargetByDobj[e.currentTarget] as IDraggable;
			
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true, int.MAX_VALUE);
			
			_startDragMouseX = _stage.mouseX;
			_startDragMouseY = _stage.mouseY;
		}
		
		private var _startDragMouseX:int;
		private var _startDragMouseY:int;
		private var _startDragContentX:int;
		private var _startDragContentY:int;
		private var _isDragging:Boolean;
		private var _draggable:IDraggable;
		
		private function onMouseMove(e:Event):void
		{
			if (!_isDragging)
			{
				if (Point.distance(new Point(_startDragMouseX, _startDragMouseY), new Point(_stage.mouseX, _stage.mouseY)) > 2)
				{
					startDragContent();
				}
				return;
			}
			
			_draggable.dragTarget.x = _draggable.dragX ? _startDragContentX + _stage.mouseX - _startDragMouseX : _draggable.dragTarget.x;
			_draggable.dragTarget.y = _draggable.dragY ? _startDragContentY + _stage.mouseY - _startDragMouseY : _draggable.dragTarget.y;
			_stage.focus = null;
			
			if (_callbacks[_draggable.dragTarget] != null)
			{
				_callbacks[_draggable.dragTarget](_draggable);
			}
		}
		
		private function onMouseUp(e:Event):void
		{
			stopDragContent();
			
			e.preventDefault();
			e.stopImmediatePropagation();
		}
		
		private function startDragContent(...args):void
		{
			_isDragging = true;
			_startDragMouseX = _stage.mouseX;
			_startDragMouseY = _stage.mouseY;
			_startDragContentX = _draggable.dragTarget.x;
			_startDragContentY = _draggable.dragTarget.y;
			
			if (_draggable.dragTarget is InteractiveObject)
			{
				(_draggable.dragTarget as InteractiveObject).mouseEnabled = false;
			}
			if (_draggable.dragTarget is DisplayObjectContainer)
			{
				(_draggable.dragTarget as DisplayObjectContainer).mouseChildren = false;
			}
			_stage.mouseChildren = false;
			
			if (_draggable.dragTarget is TextField)
			{
				_stage.focus = null;
			}
			
			MouseUtils.setModeDrag();
		}
		
		private function stopDragContent(...args):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			
			if (_isDragging)
			{
				_isDragging = false;
				
				if (_draggable.dragTarget is InteractiveObject)
				{
					(_draggable.dragTarget as InteractiveObject).mouseEnabled = true;
				}
				if (_draggable.dragTarget is DisplayObjectContainer)
				{
					(_draggable.dragTarget as DisplayObjectContainer).mouseChildren = true;
				}
				_stage.mouseChildren = true;
				
				MouseUtils.reset();
			}
			
			_draggable = null;
		}
	}
}