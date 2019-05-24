package ru.kennel32.editor.view.utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	public class MouseWheelManager
	{
		static private var _instance:MouseWheelManager;
		static public function getInstance():MouseWheelManager
		{
			if (_instance == null)
			{
				_allowInstantion = true;
				_instance = new MouseWheelManager();
				_allowInstantion = false;
			}
			
			return _instance;
		}
		
		static private var _allowInstantion:Boolean = false;
		public function MouseWheelManager()
		{
			if (!_allowInstantion)
			{
				throw new Error('Use MouseWheelManager::getInstance()');
			}
		}
		
		private var _externalInterfaceFunctionName:String;
		private var _stage:Stage;
		public function init(externalInterfaceFunctionName:String, stage:Stage, lockScrollInsideGame:Boolean = false):void
		{
			if (externalInterfaceFunctionName == null || externalInterfaceFunctionName.length == 0)
			{
				throw new Error('externalInterfaceFunctionName should be not empty');
				return;
			}
			
			_externalInterfaceFunctionName = externalInterfaceFunctionName;
			_stage = stage;
			
			if (lockScrollInsideGame)
			{
				registerArea(stage, NULL_CALLBACK);
			}
		}
		
		public function get inited():Boolean
		{
			return _stage != null;
		}
		
		private var _enabled:Boolean = true;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			
			if (!_enabled)
			{
				cancelCurrent();
			}
		}
		
		public function registerArea(target:InteractiveObject, callback:Function):void
		{
			if (_externalInterfaceFunctionName == null)
			{
				throw new Error('do MouseWheelManager.init()');
				return;
			}
			
			if (target is Stage)
			{
				target.addEventListener(MouseEvent.MOUSE_MOVE, onStageOver);
				target.addEventListener(Event.MOUSE_LEAVE, onStageLeave);
			}
			else
			{
				target.addEventListener(MouseEvent.ROLL_OVER, onAreaRollOver);
				target.addEventListener(MouseEvent.ROLL_OUT, onAreaRollOut);
			}
			_callbackByTarget[target] = callback;
		}
		
		public function unregisterArea(target:InteractiveObject):void
		{
			if (target is Stage)
			{
				target.removeEventListener(MouseEvent.MOUSE_MOVE, onStageOver);
				target.removeEventListener(Event.MOUSE_LEAVE, onStageLeave);
			}
			else
			{
				target.removeEventListener(MouseEvent.ROLL_OVER, onAreaRollOver);
				target.removeEventListener(MouseEvent.ROLL_OUT, onAreaRollOut);
			}
			delete _callbackByTarget[target];
			
			if (_currentArea == target)
			{
				cancelCurrent();
			}
		}
		
		private var _callbackByTarget:Dictionary = new Dictionary();
		
		private function onAreaRollOver(e:MouseEvent):void
		{
			if (!_enabled)
				return;
			
			var target:InteractiveObject = e.currentTarget as InteractiveObject;
			
			if (_currentArea != null && target is DisplayObjectContainer && (target as DisplayObjectContainer).contains(_currentArea) &&
				_currentArea.visible && _currentArea.mouseEnabled)
			{
				return;
			}
			
			registerListeners(target);
			_currentArea = target;
			
			e.stopImmediatePropagation();
		}
		
		private function onAreaRollOut(e:MouseEvent):void
		{
			cancelCurrent();
			
			var target:InteractiveObject = e.currentTarget as InteractiveObject;
			
			var parent:DisplayObjectContainer = target.parent;
			while (parent != null)
			{
				if (_callbackByTarget[parent] != null && e.relatedObject != null && parent.contains(e.relatedObject) && (parent.mouseChildren || parent.mouseEnabled))
				{
					parent.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, false));
					break;
				}
				parent = parent.parent;
			}
			
			setTimeout(checkMouseOverInNextFrame, 0);
		}
		
		private function checkMouseOverInNextFrame():void
		{
			if (_currentArea != null)
			{
				return;
			}
			
			var objects:Array = _stage.getObjectsUnderPoint(new Point(_stage.mouseX, _stage.mouseY));
			for (var i:int = objects.length - 1; i >= 0 ; i--)
			{
				if (_callbackByTarget[objects[i]] != null)
				{
					var interactiveObject:InteractiveObject = objects[i];
					if (interactiveObject.visible && interactiveObject.mouseEnabled)
					{
						interactiveObject.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, false));
						return;
					}
				}
			}
		}
		
		private var _mouseOverStage:Boolean;
		
		private function onStageOver(...args):void
		{
			if (_currentArea != null)
			{
				return;
			}
			
			if (!_enabled)
			{
				return;
			}
			
			_mouseOverStage = true;
			registerListeners(_stage);
			_currentArea = _stage;
		}
		
		private function onStageLeave(e:Event):void
		{
			_mouseOverStage = false;
			cancelCurrent();
		}
		
		private var _currentArea:InteractiveObject;
		
		private function registerListeners(target:InteractiveObject):void
		{
			if (ExternalInterface.available && !fullscreen)
			{
				ExternalInterface.call(_externalInterfaceFunctionName, 'onExternalWheel');
				ExternalInterface.addCallback('onExternalWheel', onExternalWheel);
			}
			else
			{
				_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
		}
		
		private function unregisterListeners():void
		{
			if (!inited)
			{
				return;
			}
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call(_externalInterfaceFunctionName, null);
				ExternalInterface.addCallback('onExternalWheel', NULL_CALLBACK);
			}
			_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			_currentArea = null;
			
			if (_mouseOverStage)
			{
				onStageOver();
			}
		}
		
		public function cancelCurrent():void
		{
			unregisterListeners();
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			onExternalWheel(e.delta);
			
			_stage.focus = null;
		}
		
		private function onExternalWheel(delta:int):void
		{
			if (_currentArea != null && _callbackByTarget[_currentArea] != null)
			{
				_callbackByTarget[_currentArea](delta);
			}
			else
			{
				trace('MouseWheelManager.onExternalWheel() no current target');
			}
		}
		
		private function get fullscreen():Boolean
		{
			return _stage != null ? (_stage.displayState == StageDisplayState.FULL_SCREEN || _stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) : false;
		}
		
		private function NULL_CALLBACK(...args):void
		{
		}
	}
}

/*
// JS CODE EXAMPLE

window.setMouseWheelFlashCallback = function(value)
{
    window.mouseWheelFlashCallback = value;
    
    if (value && !window.mouseWheelEventListenersInited)
    {
        registerMouseWheelEventListeners();
    }
}

function registerMouseWheelEventListeners()
{
    if (window.addEventListener)
    {
        window.addEventListener('mousewheel', wheelHandler, true);
        window.addEventListener('DOMMouseScroll', wheelHandler, true);
        window.addEventListener('scroll', wheelHandler, true);
    }
    else
    {
        window.onmousewheel = wheelHandler;
        document.onmousewheel = wheelHandler;
    }
    
    window.mouseWheelEventListenersInited = true;
}

window.mouseWheelEventListenersInited = false;
window.mouseWheelFlashCallback = null;
function wheelHandler(event)
{
    if (!event)
    {
        event = window.event;
    }
    var delta = deltaFilter(event);
    if (window.mouseWheelFlashCallback && event)
    {
        try
        {
            window.getFlashContent()[mouseWheelFlashCallback](delta);
            
            if (event.preventDefault)
            {
                event.preventDefault()
            }
            else
            {
                event.returnValue = false
            }
        }
        catch (e)
        {
        }
    }
}
function deltaFilter(event)
{
    var delta = 0;
    if (event && event.wheelDelta)
    {
        delta = event.wheelDelta / 40;
        if (window.opera)
        {
            delta = -delta;
        }
    }
    else if (event && event.detail)
    {
        delta = -event.detail;
    }
    return delta;
}
*/