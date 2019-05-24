package ru.kennel32.editor.view.forms 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.view.components.windows.WindowsCanvas;
	import ru.kennel32.editor.view.enum.Filter;
	import ru.kennel32.editor.view.interfaces.ICustomPositionable;
	
	public class BaseForm extends Sprite implements ICustomPositionable
	{
		private static const TIME_TO_REGISTER_CLOSE_LISTENERS:int = 10;
		private static const TIME_TO_CLOSE_BY_LISTENERS:int = 0;	//0 for just skip 1 frame
		
		protected var _important:Boolean;
		private var _closeTimer:uint;
		private var _registerListenersTimer:uint;
		
		public function BaseForm()
		{
		}
		
		public function show():void
		{
			WindowsCanvas.instance.showForm(this);
			
			_registerListenersTimer = setTimeout(registerCloseListeners, TIME_TO_REGISTER_CLOSE_LISTENERS);
			
			dispatchEvent(new Event(Event.OPEN));
			
			Main.instance.commandsHistory.addEventListener(Event.CHANGE, onHistoryChange);
		}
		
		private function registerCloseListeners():void
		{
			_registerListenersTimer = 0;
			
			Main.instance.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			Main.instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageClickForClose, true, int.MAX_VALUE);
			Main.instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageClickForSetFocus, true);
		}
		
		public function close():void
		{
			WindowsCanvas.instance.removeForm(this);
		}
		
		public function onClose():void
		{
			if (_registerListenersTimer > 0)
			{
				clearTimeout(_registerListenersTimer);
				_registerListenersTimer = 0;
			}
			
			if (_closeTimer > 0)
			{
				clearTimeout(_closeTimer);
				_closeTimer = 0;
			}
			
			Main.instance.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			Main.instance.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageClickForClose, true);
			Main.instance.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageClickForSetFocus, true);
			
			Main.instance.commandsHistory.removeEventListener(Event.CHANGE, onHistoryChange);
			
			dispatchEvent(new Event(Event.CLOSE));
			
			if (Main.instance.stage.focus != null && contains(Main.instance.stage.focus))
			{
				Main.instance.stage.focus = null;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE && !_important)
			{
				closeIfAtTop();
			}
		}
		
		private function onStageClickForClose(e:Event):void
		{
			var containsTarget:Boolean = contains(e.target as DisplayObject);
			if (!containsTarget && isModal && !_important)
			{
				closeIfAtTop();
			}
		}
		
		private function onStageClickForSetFocus(e:Event):void
		{
			var containsTarget:Boolean = contains(e.target as DisplayObject);
			setInFocus(containsTarget);
		}
		
		private function closeIfAtTop():void
		{
			if (parent == null || parent.getChildIndex(this) >= parent.numChildren - 1)
			{
				_closeTimer = setTimeout(close, TIME_TO_CLOSE_BY_LISTENERS);
				onClosedByUser();
			}
		}
		
		protected function onHistoryChange(e:Event):void
		{
			if (isModal)
			{
				close();
			}
			else
			{
				setInFocus(false);
			}
		}
		
		public function setInFocus(value:Boolean):void
		{
			filters = value ? null : [Filter.BLACK_WHITE_LIGHT_WHITE];
			alpha = value ? 1 : 0.8;
			if (value)
			{
				parent.setChildIndex(this, parent.numChildren - 1);
			}
		}
		
		protected function onClosedByUser():void
		{
			//to override
		}
		
		public function onPosOffsetChanged(x:int, y:int):void
		{
			_posOffsetX = x;
			_posOffsetY = y;
		}
		
		private var _posOffsetX:int = 0;
		private var _posOffsetY:int = 0;
		
		public function get posOffsetX():int
		{
			return _posOffsetX;
		}
		
		public function get posOffsetY():int
		{
			return _posOffsetY;
		}
		
		public function get isModal():Boolean
		{
			return true;
		}
	}
}