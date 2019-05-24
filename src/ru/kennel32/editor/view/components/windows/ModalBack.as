package ru.kennel32.editor.view.components.windows 
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.BaseForm;
	
	public class ModalBack extends Shape 
	{
		private var _parentForm:BaseForm;
		public function get parentForm():BaseForm
		{
			return _parentForm;
		}
		
		public function ModalBack(parentForm:BaseForm) 
		{
			super();
			
			_parentForm = parentForm;
			cacheAsBitmap = true;
		}
		
		public function redraw():void
		{
			var width:int = Main.stage.stageWidth;
			var height:int = Main.stage.stageHeight;
			
			var graphics:Graphics = this.graphics;
			
			graphics.clear();
			
			if (width > 0 && height > 0)
			{
				graphics.beginFill(Color.MODAL_BACK, 0.1);
				graphics.drawRect(0, 0, width, height);
				graphics.endFill();
			}
		}
	}
}