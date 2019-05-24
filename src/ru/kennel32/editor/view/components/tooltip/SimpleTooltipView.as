package ru.kennel32.editor.view.components.tooltip 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import ru.kennel32.editor.view.components.SimpleBackground;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class SimpleTooltipView extends Sprite implements ICustomTooltipView
	{
		private var _bg:SimpleBackground;
		private var _tf:TextField;
		
		public function SimpleTooltipView()
		{
			_bg = new SimpleBackground();
			addChild(_bg);
			
			_tf = TextUtils.getText('', Color.FONT, 14, null, true, -3);
			_tf.autoSize = TextFieldAutoSize.NONE;
			_tf.x = 2;
			_tf.y = 2;
			addChild(_tf);
		}
		
		private var _tooltipData:*;
		public function get tooltipData():*
		{
			return _tooltipData;
		}
		public function set tooltipData(value:*):void
		{
			_tooltipData = value;
		}
		
		private function get tooltipText():String
		{
			return _tooltipData == null ? '' : String(_tooltipData);
		}
		
		public function update():void
		{
			_tf.width = 500;
			_tf.text = tooltipText;
			
			_tf.width = _tf.textWidth + 6;
			_tf.height = _tf.textHeight + 8;
			
			_bg.setSize(_tf.width + _tf.x * 2, _tf.height + _tf.y * 2);
		}
	}
}