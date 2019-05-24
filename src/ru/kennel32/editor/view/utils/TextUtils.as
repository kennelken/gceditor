package ru.kennel32.editor.view.utils
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ru.kennel32.editor.assets.Assets;
	import ru.kennel32.editor.view.enum.Color;
	
	public class TextUtils
	{
		public static function getText(
			text:String = "",
			color:uint = 0,
			size:int = 20,
			align:String = null,
			wordWrap:Boolean = false,
			leading:int = 0):TextField
		{
			if (align == null)
				align = TextFormatAlign.LEFT;
			
			var format:TextFormat = new TextFormat(Assets.FONT_FAMILY, size, color, null, null, null, null, null, align, null, null, null, leading);
			var label:TextField = new TextField();
			label.defaultTextFormat = format;
			label.embedFonts = true;
			label.multiline = wordWrap;
			label.selectable = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.wordWrap = wordWrap;
			if (text != null)
			{
				label.text = text;
			}
			label.height = size + 5;
			
			return label;
		}
		
		public static function getInputText(
			color:uint = 0,
			size:int = 20,
			width:int = 100,
			wordWrap:Boolean = false,
			leading:int = 0,
			border:Boolean = true):TextField
		{
			var format:TextFormat;
			format = new TextFormat(Assets.FONT_FAMILY, size, color, null, null, null, null, null, TextFormatAlign.LEFT, null, null, null, leading);
			var label:TextField = new TextField();
			label.defaultTextFormat = format;
			label.embedFonts = true;
			label.width = width;
			label.height = size + 5;
			label.multiline = wordWrap;
			label.selectable = true;
			label.autoSize = TextFieldAutoSize.NONE;
			label.wordWrap = wordWrap;
			label.type = TextFieldType.INPUT;
			label.selectable = true;
			label.backgroundColor = Color.INPUT_TEXT_BACKGROUND;
			label.background = true;
			
			if (border)
			{
				label.border = true;
				label.borderColor = Color.BORDER_LIGHT;
			}
			
			return label;
		}
		
		public static function getTextCentered(
			text:String = "",
			color:uint = 0,
			size:int = 20,
			wordWrap:Boolean = false,
			leading:int = 0,
			align:String = null):TextField
		{
			align = align == null ? TextFormatAlign.CENTER : align;
			var format:TextFormat = new TextFormat(Assets.FONT_FAMILY, size, color, null, null, null, null, null, align, null, null, null, leading);
			var label:TextField = new TextField();
			label.defaultTextFormat = format;
			label.embedFonts = true;
			label.multiline = wordWrap;
			label.selectable = false;
			label.autoSize = TextFieldAutoSize.NONE;
			label.wordWrap = wordWrap;
			label.height = size + 5;
			if (text != null)
			{
				label.text = text;
			}
			
			return label;
		}
		
		public static function prefixToLength(src:String, length:int, char:String):String
		{
			var res:String = src;
			var num:int = length - src.length;
			for (var i:int = 0; i < num; i++)
			{
				res = char + res;
			}
			return res;
		}
		
		public static function postfixToLength(src:String, length:int, char:String):String
		{
			var res:String = src;
			var num:int = length - src.length;
			for (var i:int = 0; i < num; i++)
			{
				res = res + char;
			}
			return res;
		}
		
		public static function addColoredText(tf:TextField, text:String, color:int):void
		{
			var format:TextFormat = tf.defaultTextFormat;
			format.color = color;
			
			var index:int = tf.text.length;
			
			tf.defaultTextFormat = format;
			tf.appendText(text);
			tf.setTextFormat(format, index, tf.text.length);
		}
	}
}