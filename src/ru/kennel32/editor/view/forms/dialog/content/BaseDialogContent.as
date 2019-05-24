package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.display.Sprite;
	import ru.kennel32.editor.view.forms.dialog.DialogForm;
	
	public class BaseDialogContent extends Sprite
	{
		protected var _parentForm:DialogForm;
		
		public function BaseDialogContent()
		{
			super();
		}
		
		public function set parentForm(value:DialogForm):void
		{
			_parentForm = value;
		}
		public function get parentForm():DialogForm
		{
			return _parentForm;
		}
	}
}