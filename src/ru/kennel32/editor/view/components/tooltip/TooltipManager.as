package ru.kennel32.editor.view.components.tooltip 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ru.kennel32.editor.view.utils.ViewUtils;
	import ru.kennel32.editor.view.components.tooltip.ICustomTooltipView;
	
	public class TooltipManager 
	{
		private static var _instance:TooltipManager;
		public static function get instance():TooltipManager
		{
			return _instance;
		}
		
		public static function init(cont:DisplayObjectContainer, offsetX:int, offsetY:int, delay:int, defaultTooltipClass:Class):void
		{
			if (_instance != null)
			{
				throw new Error("TooltipManager is already inited");
			}
			
			_instance = new TooltipManager();
			_instance.init(cont, offsetX, offsetY, delay, defaultTooltipClass);
		}
		
		private var _layer:DisplayObjectContainer;
		private var _offsetX:int;
		private var _offsetY:int;
		private var _delay:int;
		private var _defaultTolltipClass:Class;
		
		private var _rollOverTarget:InteractiveObject
		
		private function init(layer:DisplayObjectContainer, offsetX:int, offsetY:int, delay:int, defaultTooltipClass:Class):void
		{
			_layer = layer;
			_offsetX = offsetX;
			_offsetY = offsetY;
			_delay = delay;
			_defaultTolltipClass = defaultTooltipClass;
			
			_layer.mouseEnabled = false;
			_layer.mouseChildren = false;
		}
		
		private var _enabled:Boolean = true;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
		}
		
		public function hideAll():void
		{
			if(_tooltipCandidate != null)
			{
				hideHint(_tooltipCandidate);
			}
		}
		
		private var _contentRegion:Rectangle;
		public function get contentRegion():Rectangle
		{
			return _contentRegion;
		}
		public function set contentRegion(value:Rectangle):void
		{
			_contentRegion = value;
		}
		
		private function onTargetRollOver(e:MouseEvent):void
		{
			if (!_enabled)
				return;
			
			var target:InteractiveObject = e.currentTarget as InteractiveObject;
			
			if (_rollOverTarget == null || ViewUtils.getDepth(target) > ViewUtils.getDepth(_rollOverTarget))
			{
				_rollOverTarget = target;
			}
			setTimeout(showTopHint, 0);
		}
		
		private function showTopHint():void
		{
			if (_rollOverTarget == null)
			{
				return;
			}
			
			showHint(_rollOverTarget);
			_rollOverTarget = null;
		}
		
		private function onTargetRollOut(e:MouseEvent):void
		{
			var target:InteractiveObject = e.currentTarget as InteractiveObject;
			hideHint(target);
			
			_layer.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onTooltipLayerMouseMove);
			
			var parent:DisplayObjectContainer = target.parent;
			while (parent != null)
			{
				if (_classByTarget[parent] != null && e.relatedObject != null && parent.contains(e.relatedObject) && (parent.mouseChildren || parent.mouseEnabled))
				{
					parent.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, false));
					break;
				}
				parent = parent.parent;
			}
			
			if (_rollOverTarget == target)
			{
				_rollOverTarget = null;
			}
		}
		
		private function onTooltipLayerMouseMove(event:MouseEvent):void
		{
			if (_shownTooltip != null)
			{
				var targetRegion:Rectangle = _shownTooltip.getBounds(_layer);
				arrangeTooltipToCursor(targetRegion, _shownTooltip);
			}
		}
		
		private var _timeoutShowDelay:uint = 0;
		
		private var _tooltipCandidate:InteractiveObject;
		
		private var _shownTooltip:DisplayObject;
		
		private function showHint(target:InteractiveObject):void
		{
			_tooltipCandidate = target;
			if (_timeoutShowDelay == 0)
			{
				_timeoutShowDelay = setTimeout(doShowTooltip, _delay);
			}
		}
		
		private function hideHint(target:InteractiveObject):void
		{
			if (_tooltipCandidate === target)
			{
				hideCurrentHint();
				_tooltipCandidate = null;
			}
		}
		
		private function doShowTooltip():void
		{
			hideCurrentHint();
			if (_tooltipCandidate == null)
			{
				return;
			}
			
			_shownTooltip = createTooltip();
			if (_shownTooltip == null)
			{
				return;
			}
			
			_layer.stage.addEventListener(MouseEvent.MOUSE_MOVE, onTooltipLayerMouseMove);
			
			_layer.addChild(_shownTooltip);
		}
		
		private function hideCurrentHint():void
		{
			if (_timeoutShowDelay > 0)
			{
				clearTimeout(_timeoutShowDelay);
				_timeoutShowDelay = 0;
			}
			if (_shownTooltip != null)
			{
				if (_shownTooltip.parent != null)
				{
					_shownTooltip.parent.removeChild(_shownTooltip);
				}
				_shownTooltip = null;
			}
		}
		
		private function createTooltip():DisplayObject
		{
			var targetRegion:Rectangle = _tooltipCandidate.getBounds(_layer);
			
			var tooltipView:ICustomTooltipView = getTooltipByTarget(_tooltipCandidate);
			if (tooltipView != null)
			{
				var tooltipData:* = _tooltipDataByTarget[_tooltipCandidate];
				tooltipView.tooltipData = tooltipData;
				tooltipView.update();
				
				arrangeTooltipToCursor(targetRegion, tooltipView as DisplayObject);
				
				return tooltipView as DisplayObject;
			}
			
			return null;
		}
		
		private function arrangeTooltipToCursor(targetRegion:Rectangle, tooltip:DisplayObject):void
		{
			var fixedX:Boolean = true;
			
			var minX:Number = Math.ceil(_contentRegion.left);
			var maxX:Number = int(_contentRegion.right - tooltip.width);
			tooltip.x = int(_layer.mouseX + _offsetX);
			if (tooltip.x > maxX)
			{
				tooltip.x = int(_layer.mouseX - tooltip.width - _offsetX);
				if (tooltip.x < minX)
				{
					tooltip.x = Math.max(minX, Math.min(maxX, tooltip.x));
					fixedX = false;
				}
			}
			
			var minY:Number = Math.ceil(_contentRegion.top);
			var maxY:Number = int(_contentRegion.bottom - tooltip.height);
			tooltip.y = int(_layer.mouseY + _offsetY);
			if (tooltip.y > maxY)
			{
				tooltip.y = int(_layer.mouseY - tooltip.height - _offsetY);
				if (tooltip.y < minY && fixedX)
				{
					tooltip.y = Math.max(minY, Math.min(maxY, tooltip.y));
				}
			}
		}
		
		private var _classByTarget:Dictionary = new Dictionary();
		
		private var _instanceByClass:Dictionary = new Dictionary();
		
		private function getTooltipByTarget(target:InteractiveObject):ICustomTooltipView
		{
			if (target == null)
			{
				return null;
			}
			var cls:Class = _classByTarget[target];
			if (cls == null)
			{
				return null;
			}
			var tooltip:ICustomTooltipView = _instanceByClass[cls];
			if (tooltip == null)
			{
				tooltip = new cls();
				_instanceByClass[cls] = tooltip;
			}
			return tooltip;
		}
		
		private var _tooltipDataByTarget:Dictionary = new Dictionary();
		
		public static function registerTooltip(target:InteractiveObject, tooltipData:*, tooltipClass:Class = null):void
		{
			target.addEventListener(MouseEvent.ROLL_OVER, _instance.onTargetRollOver);
			target.addEventListener(MouseEvent.ROLL_OUT, _instance.onTargetRollOut);
			tooltipClass = tooltipClass == null ? _instance._defaultTolltipClass : tooltipClass;
			_instance._classByTarget[target] = tooltipClass;
			_instance._tooltipDataByTarget[target] = tooltipData;
		}
		
		public static function unregisterTooltip(target:InteractiveObject):void
		{
			delete _instance._classByTarget[target];
			delete _instance._tooltipDataByTarget[target];
			target.removeEventListener(MouseEvent.ROLL_OVER, _instance.onTargetRollOver);
			target.removeEventListener(MouseEvent.ROLL_OUT, _instance.onTargetRollOut);
		}
	}
}