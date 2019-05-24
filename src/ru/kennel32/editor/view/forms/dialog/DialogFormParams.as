package ru.kennel32.editor.view.forms.dialog
{
	import flash.display.DisplayObject;
	import flash.text.TextFormatAlign;
	import ru.kennel32.editor.view.forms.dialog.DialogForm;
	
	public class DialogFormParams 
	{
		public static function create():DialogFormParams
		{
			return new DialogFormParams();
		}
		
		public function show():DialogForm
		{
			return DialogForm.show(this);
		}
		
		private var _text:String;
		public function get text():String
		{
			return _text;
		}
		public function setText(value:String):DialogFormParams
		{
			_text = value;
			return this;
		}
		
		private var _content:DisplayObject;
		public function get content():DisplayObject
		{
			return _content;
		}
		public function setContent(value:DisplayObject):DialogFormParams
		{
			_content = value;
			return this;
		}
		
		private var _buttons:Vector.<DialogFormButtonParams> = new Vector.<DialogFormButtonParams>();
		public function get buttons():Vector.<DialogFormButtonParams>
		{
			return _buttons;
		}
		public function addButton(name:String, callback:Function = null, callbackParams:Array = null, keyCode:int = -1):DialogFormParams
		{
			_buttons.push(new DialogFormButtonParams(name, callback, callbackParams, keyCode));
			return this;
		}
		
		private var _important:Boolean;
		public function get important():Boolean
		{
			return _important;
		}
		public function setImportant(value:Boolean):DialogFormParams
		{
			_important = value;
			return this;
		}
		
		private var _textAlign:String = TextFormatAlign.CENTER;
		public function get textAlign():String
		{
			return _textAlign;
		}
		public function setTextAlign(value:String):DialogFormParams
		{
			_textAlign = value;
			return this;
		}
		
		private var _textSize:int = 18;
		public function get textSize():int
		{
			return _textSize;
		}
		public function setTextSize(value:int):DialogFormParams
		{
			_textSize = value;
			return this;
		}
		
		private var _closeCallback:DialogFormButtonParams;
		public function callCloseCallback():void
		{
			if (_closeCallback != null)
			{
				_closeCallback.callCallback();
			}
		}
		public function setCloseCallback(value:DialogFormButtonParams):DialogFormParams
		{
			_closeCallback = value;
			return this;
		}
	}
}