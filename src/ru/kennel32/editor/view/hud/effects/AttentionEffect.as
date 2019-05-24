package ru.kennel32.editor.view.hud.effects
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	public class AttentionEffect extends Shape
	{
		private var _target:DisplayObject;
		private var _container:DisplayObjectContainer;
		private var _error:Boolean;
		
		public function AttentionEffect(target:DisplayObject, container:DisplayObjectContainer)
		{
			super();
			
			_target = target;
			_container = container;
			
			cacheAsBitmap = true;
		}
		
		private var _startMs:int;
		public function play(skipFrame:Boolean = true, error:Boolean = false):void
		{
			if (skipFrame)
			{
				setTimeout(play, 100, false, error);
				return;
			}
			
			if (_target.stage == null)
			{
				return;
			}
			
			_error = error;
			_startMs = getTimer();
			
			_container.addChild(this);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			onEnterFrame(null);
		}
		
		private function onEnterFrame(e:Event):void
		{
			alpha = 0.7 - (getTimer() - _startMs) / 400;
			
			var rect:Rectangle = _target.getBounds(_container);
			x = rect.x;
			y = rect.y;
			
			graphics.clear();
			graphics.beginFill(_error ? 0xC72812 : 0x097DFF, 0.4);
			graphics.drawRect(0, 0, rect.width, rect.height);
			graphics.endFill();
			
			if (alpha <= 0 || _target.stage == null)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				parent.removeChild(this);
			}
		}
	}
}